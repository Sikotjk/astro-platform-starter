// In-Memory-Implementierung des PaymentGateway für Tests & lokale Entwicklung.
// Protokolliert alle Aufrufe und prüft Idempotenz, ohne Stripe zu kontaktieren.

import { randomBytes } from 'node:crypto';
import type {
  PaymentGateway,
  CreateEscrowInput,
  CreateEscrowResult,
  ReleaseEscrowInput,
  ReleaseEscrowResult,
  RefundInput,
  RefundResult,
} from './payment.gateway';

// Zufallssuffix, damit Fake-IDs auch über App-Neustarts hinweg eindeutig sind
// (paymentIntentId/transferId sind in der DB unique).
const rand = () => randomBytes(6).toString('hex');

export interface FakeCall {
  type: 'createEscrow' | 'releaseEscrow' | 'refund';
  bookingId: string;
  amountMinor?: number;
  idempotencyKey?: string;
}

export class FakePaymentGateway implements PaymentGateway {
  readonly calls: FakeCall[] = [];
  private seq = 0;
  private readonly seenIdempotencyKeys = new Map<string, string>();

  async createEscrow(input: CreateEscrowInput): Promise<CreateEscrowResult> {
    this.calls.push({ type: 'createEscrow', bookingId: input.bookingId, amountMinor: input.amountMinor });
    const id = `pi_fake_${++this.seq}_${rand()}`;
    return { paymentIntentId: id, clientSecret: `${id}_secret` };
  }

  async releaseEscrow(input: ReleaseEscrowInput): Promise<ReleaseEscrowResult> {
    // Idempotenz emulieren: gleicher Key -> gleiches Ergebnis, kein Doppel-Transfer.
    const cached = this.seenIdempotencyKeys.get(input.idempotencyKey);
    if (cached) return { transferId: cached };

    this.calls.push({
      type: 'releaseEscrow',
      bookingId: input.bookingId,
      amountMinor: input.payoutMinor,
      idempotencyKey: input.idempotencyKey,
    });
    const id = `tr_fake_${++this.seq}_${rand()}`;
    this.seenIdempotencyKeys.set(input.idempotencyKey, id);
    return { transferId: id };
  }

  async refund(input: RefundInput): Promise<RefundResult> {
    const cached = this.seenIdempotencyKeys.get(input.idempotencyKey);
    if (cached) return { refundId: cached };

    this.calls.push({
      type: 'refund',
      bookingId: input.bookingId,
      amountMinor: input.amountMinor,
      idempotencyKey: input.idempotencyKey,
    });
    const id = `re_fake_${++this.seq}_${rand()}`;
    this.seenIdempotencyKeys.set(input.idempotencyKey, id);
    return { refundId: id };
  }

  /** Test-Helfer: zählt Aufrufe eines Typs. */
  countOf(type: FakeCall['type']): number {
    return this.calls.filter((c) => c.type === type).length;
  }
}
