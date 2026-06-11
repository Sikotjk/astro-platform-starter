// ─────────────────────────────────────────────────────────────────────────────
//  StripePaymentGateway — echte Stripe-Connect-Implementierung
//
//  Escrow-Modell: "Separate Charges and Transfers".
//   1. createEscrow: PaymentIntent auf dem PLATTFORM-Account (Geld kommt zur
//      Plattform). transfer_group verknüpft alles zu diesem Booking.
//   2. releaseEscrow: Transfer des Traveler-Anteils an dessen Connected Account.
//      Die serviceFee bleibt automatisch auf dem Plattform-Saldo.
//   3. refund: Rückerstattung an den Sender.
//
//  Diese Datei benötigt das `stripe`-Paket und gültige Keys zur Laufzeit. Im
//  Test wird stattdessen FakePaymentGateway verwendet.
// ─────────────────────────────────────────────────────────────────────────────

import Stripe from 'stripe';
import type {
  PaymentGateway,
  CreateEscrowInput,
  CreateEscrowResult,
  ReleaseEscrowInput,
  ReleaseEscrowResult,
  RefundInput,
  RefundResult,
} from './payment.gateway';

export class StripePaymentGateway implements PaymentGateway {
  constructor(private readonly stripe: Stripe) {}

  static fromEnv(): StripePaymentGateway {
    const key = process.env.STRIPE_SECRET_KEY;
    if (!key) throw new Error('STRIPE_SECRET_KEY ist nicht gesetzt.');
    return new StripePaymentGateway(new Stripe(key));
  }

  async createEscrow(input: CreateEscrowInput): Promise<CreateEscrowResult> {
    const intent = await this.stripe.paymentIntents.create(
      {
        amount: input.amountMinor,
        currency: input.currency,
        customer: input.customerId,
        // Geld bleibt zunächst auf dem Plattform-Account (Escrow).
        transfer_group: input.transferGroup,
        capture_method: 'automatic',
        metadata: { bookingId: input.bookingId },
      },
      // Idempotenz: identische Anfrage erzeugt keinen zweiten Intent.
      { idempotencyKey: `escrow_${input.bookingId}` },
    );

    if (!intent.client_secret) {
      throw new Error('Stripe lieferte kein client_secret zurück.');
    }
    return { paymentIntentId: intent.id, clientSecret: intent.client_secret };
  }

  async releaseEscrow(input: ReleaseEscrowInput): Promise<ReleaseEscrowResult> {
    const transfer = await this.stripe.transfers.create(
      {
        amount: input.payoutMinor,
        currency: input.currency,
        destination: input.destinationAccountId,
        transfer_group: input.transferGroup,
        metadata: { bookingId: input.bookingId },
      },
      { idempotencyKey: input.idempotencyKey },
    );
    return { transferId: transfer.id };
  }

  async refund(input: RefundInput): Promise<RefundResult> {
    const refund = await this.stripe.refunds.create(
      {
        payment_intent: input.paymentIntentId,
        amount: input.amountMinor, // undefined => volle Erstattung
        metadata: { bookingId: input.bookingId },
      },
      { idempotencyKey: input.idempotencyKey },
    );
    return { refundId: refund.id };
  }
}
