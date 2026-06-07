// ─────────────────────────────────────────────────────────────────────────────
//  BookingRepository (Port) — Persistenz-Abstraktion für den BookingService
//
//  Der Service hängt an diesem Interface, nicht an Prisma. Die echte
//  Implementierung (PrismaBookingRepository) führt `applyTransition` in EINER
//  Datenbank-Transaktion aus: Status-Update + append-only BookingStatusEvent.
//  Für Tests gibt es InMemoryBookingRepository.
// ─────────────────────────────────────────────────────────────────────────────

import type { BookingStatus, Actor } from './booking.machine';
import type { PaymentStatus } from '../payments/payment.types';

/** Schlanke Sicht auf ein Booking, wie der Service sie braucht. */
export interface BookingRecord {
  id: string;
  status: BookingStatus;
  senderId: string;
  travelerId: string;

  // Geld in Cent (Integer)
  itemPriceMinor: number; // Traveler-Anteil
  serviceFeeMinor: number; // Plattform-Gebühr
  totalAmountMinor: number; // itemPrice + serviceFee
  currency: string;

  // Stripe-Anker
  paymentIntentId: string | null;
  transferId: string | null;
  paymentStatus: PaymentStatus;

  // Compliance-Kontext
  customsDeclared: boolean;
  travelerAcceptedTerms: boolean;

  // Stripe-Verknüpfungen der Parteien
  senderStripeCustomerId: string | null;
  travelerStripeAccountId: string | null;
}

/** Felder, die ein Übergang zusätzlich am Booking setzen darf. */
export interface BookingPatch {
  paymentStatus?: PaymentStatus;
  paymentIntentId?: string | null;
  transferId?: string | null;
}

export interface ApplyTransitionInput {
  bookingId: string;
  from: BookingStatus;
  to: BookingStatus;
  triggeredBy: Actor | string;
  patch?: BookingPatch;
  metadata?: Record<string, unknown>;
}

export interface BookingRepository {
  findById(id: string): Promise<BookingRecord | null>;

  /**
   * Atomar: setzt den neuen Status, schreibt einen BookingStatusEvent
   * (append-only) und wendet optionale Patch-Felder an. Wirft, wenn der
   * Status sich zwischenzeitlich geändert hat (optimistic concurrency über
   * den `from`-Vergleich).
   */
  applyTransition(input: ApplyTransitionInput): Promise<BookingRecord>;

  // ── Webhook-Idempotenz (Stripe liefert at-least-once) ──────────────────────
  hasProcessedEvent(eventId: string): Promise<boolean>;
  markProcessedEvent(eventId: string, type: string): Promise<void>;
}
