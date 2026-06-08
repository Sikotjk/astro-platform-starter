// ─────────────────────────────────────────────────────────────────────────────
//  BookingService — orchestriert State Machine + Persistenz + Geld (Escrow)
//
//  Verantwortung:
//   • Statusübergänge gegen die State Machine prüfen (assertTransition)
//   • Übergang atomar persistieren (Status + append-only Event-Log)
//   • Geld-Nebenwirkung (HOLD/RELEASE/REFUND) über das PaymentGateway ausführen
//   • Stripe-Webhooks idempotent verarbeiten
//
//  Reihenfolge bei Auszahlung/Erstattung (RELEASE/REFUND):
//   Erst Gateway-Call (externe Geldbewegung), DANN DB-Persistierung des
//   Ergebnisses. Grund: keine externen Netz-Calls innerhalb einer offenen
//   DB-Transaktion (würde Locks halten). Idempotenz-Keys + paymentStatus-
//   Guards verhindern Doppel-Ausführung bei Retries. (Skalierung: später
//   via Transactional-Outbox entkoppeln.)
// ─────────────────────────────────────────────────────────────────────────────

import {
  assertTransition,
  type Actor,
  type BookingStatus,
  type BookingContext,
} from './booking.machine';
import type { BookingRecord, BookingRepository } from './booking.repository';
import type { PaymentGateway } from '../payments/payment.gateway';

export class BookingNotFoundError extends Error {
  constructor(id: string) {
    super(`Booking ${id} nicht gefunden.`);
    this.name = 'BookingNotFoundError';
  }
}

export class BookingStateError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'BookingStateError';
  }
}

function toContext(b: BookingRecord): BookingContext {
  return {
    customsDeclared: b.customsDeclared,
    travelerAcceptedTerms: b.travelerAcceptedTerms,
    escrowHeld: b.paymentStatus === 'ESCROW_HELD',
  };
}

const transferGroup = (bookingId: string) => `booking_${bookingId}`;

export class BookingService {
  constructor(
    private readonly repo: BookingRepository,
    private readonly payments: PaymentGateway,
    /** Plattform-Gebühr als Anteil, z.B. 0.15. Nur zur Validierung genutzt. */
    private readonly platformFeeRate = Number(process.env.PLATFORM_FEE_RATE ?? '0.15'),
  ) {}

  // ───────────────────────────────────────────────────────────────────────────
  //  1) Escrow anlegen: erstellt den PaymentIntent (Status bleibt ACCEPTED,
  //     bis der Webhook payment_intent.succeeded eintrifft).
  // ───────────────────────────────────────────────────────────────────────────
  async createEscrow(bookingId: string): Promise<{ clientSecret: string }> {
    const b = await this.requireBooking(bookingId);
    if (b.status !== 'ACCEPTED') {
      throw new BookingStateError(`Escrow nur im Status ACCEPTED möglich (ist: ${b.status}).`);
    }
    if (!b.senderStripeCustomerId) {
      throw new BookingStateError('Sender hat keinen Stripe-Customer.');
    }
    if (b.paymentIntentId) {
      throw new BookingStateError('Für dieses Booking existiert bereits ein PaymentIntent.');
    }

    const { paymentIntentId, clientSecret } = await this.payments.createEscrow({
      bookingId: b.id,
      amountMinor: b.totalAmountMinor,
      currency: b.currency.toLowerCase(),
      customerId: b.senderStripeCustomerId,
      transferGroup: transferGroup(b.id),
    });

    // PaymentIntent merken, Status noch NICHT auf PAID (das macht der Webhook).
    await this.repo.applyTransition({
      bookingId: b.id,
      from: b.status,
      to: b.status, // kein Statuswechsel, nur Patch
      triggeredBy: 'SYSTEM',
      patch: { paymentIntentId, paymentStatus: 'PENDING' },
      metadata: { action: 'createEscrow' },
    });

    return { clientSecret };
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  2) Generischer Übergang für nicht-zahlungsauslösende Schritte
  //     (ACCEPT, REJECT, HANDED_OVER, IN_TRANSIT, DELIVERED, CANCEL …).
  //     CONFIRMED/REFUNDED mit Geld-Effekt laufen über confirm()/cancel().
  // ───────────────────────────────────────────────────────────────────────────
  async transition(
    bookingId: string,
    to: BookingStatus,
    actor: Actor,
    metadata?: Record<string, unknown>,
  ): Promise<BookingRecord> {
    const b = await this.requireBooking(bookingId);
    const { effect } = assertTransition(b.status, to, actor, toContext(b));

    if (effect === 'RELEASE_ESCROW') {
      return this.releaseAndPersist(b, to, actor, metadata);
    }
    if (effect === 'REFUND') {
      return this.refundAndPersist(b, to, actor, metadata);
    }

    // Reiner Statuswechsel ohne Geldbewegung.
    return this.repo.applyTransition({
      bookingId: b.id,
      from: b.status,
      to,
      triggeredBy: actor,
      metadata,
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  3) Stripe-Webhook: payment_intent.succeeded -> ACCEPTED → PAID
  //     Idempotent über ProcessedWebhookEvent.
  // ───────────────────────────────────────────────────────────────────────────
  async handlePaymentSucceeded(
    eventId: string,
    paymentIntentId: string,
  ): Promise<{ processed: boolean }> {
    if (await this.repo.hasProcessedEvent(eventId)) {
      return { processed: false }; // Duplikat – still ignorieren.
    }

    const b = await this.findByPaymentIntent(paymentIntentId);
    if (b && b.status === 'ACCEPTED') {
      assertTransition(b.status, 'PAID', 'SYSTEM', { ...toContext(b), escrowHeld: true });
      await this.repo.applyTransition({
        bookingId: b.id,
        from: b.status,
        to: 'PAID',
        triggeredBy: 'WEBHOOK',
        patch: { paymentStatus: 'ESCROW_HELD' },
        metadata: { eventId, paymentIntentId },
      });
    }

    await this.repo.markProcessedEvent(eventId, 'payment_intent.succeeded');
    return { processed: true };
  }

  // ── interne Helfer ──────────────────────────────────────────────────────────

  private async releaseAndPersist(
    b: BookingRecord,
    to: BookingStatus,
    actor: Actor,
    metadata?: Record<string, unknown>,
  ): Promise<BookingRecord> {
    if (b.paymentStatus === 'RELEASED') {
      throw new BookingStateError('Escrow wurde für dieses Booking bereits ausgezahlt.');
    }
    if (!b.paymentIntentId) throw new BookingStateError('Kein PaymentIntent zum Auszahlen.');
    if (!b.travelerStripeAccountId)
      throw new BookingStateError('Traveler hat keinen Connect-Account.');

    // Externer Call zuerst (idempotent), danach DB-Persistierung.
    const { transferId } = await this.payments.releaseEscrow({
      bookingId: b.id,
      paymentIntentId: b.paymentIntentId,
      payoutMinor: b.itemPriceMinor, // serviceFee bleibt bei der Plattform
      currency: b.currency.toLowerCase(),
      destinationAccountId: b.travelerStripeAccountId,
      transferGroup: transferGroup(b.id),
      idempotencyKey: `release_${b.id}`,
    });

    return this.repo.applyTransition({
      bookingId: b.id,
      from: b.status,
      to,
      triggeredBy: actor,
      patch: { paymentStatus: 'RELEASED', transferId },
      metadata: { ...metadata, transferId },
    });
  }

  private async refundAndPersist(
    b: BookingRecord,
    to: BookingStatus,
    actor: Actor,
    metadata?: Record<string, unknown>,
  ): Promise<BookingRecord> {
    if (b.paymentStatus === 'REFUNDED') {
      throw new BookingStateError('Booking wurde bereits erstattet.');
    }
    // Wurde nie Escrow gehalten? Dann reiner Statuswechsel ohne Geldbewegung.
    if (b.paymentStatus !== 'ESCROW_HELD' || !b.paymentIntentId) {
      return this.repo.applyTransition({
        bookingId: b.id,
        from: b.status,
        to,
        triggeredBy: actor,
        metadata: { ...metadata, note: 'no-escrow-held' },
      });
    }

    const { refundId } = await this.payments.refund({
      bookingId: b.id,
      paymentIntentId: b.paymentIntentId,
      idempotencyKey: `refund_${b.id}`,
    });

    return this.repo.applyTransition({
      bookingId: b.id,
      from: b.status,
      to,
      triggeredBy: actor,
      patch: { paymentStatus: 'REFUNDED' },
      metadata: { ...metadata, refundId },
    });
  }

  private async requireBooking(id: string): Promise<BookingRecord> {
    const b = await this.repo.findById(id);
    if (!b) throw new BookingNotFoundError(id);
    return b;
  }

  // Hilfsmethode; in der Prisma-Impl. via findFirst({ where: { paymentIntentId } }).
  private async findByPaymentIntent(paymentIntentId: string): Promise<BookingRecord | null> {
    const anyRepo = this.repo as BookingRepository & {
      findByPaymentIntent?: (pi: string) => Promise<BookingRecord | null>;
    };
    if (typeof anyRepo.findByPaymentIntent === 'function') {
      return anyRepo.findByPaymentIntent(paymentIntentId);
    }
    throw new Error('Repository unterstützt findByPaymentIntent nicht.');
  }
}
