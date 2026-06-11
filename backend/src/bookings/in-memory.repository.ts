// In-Memory-Implementierung des BookingRepository für Unit-Tests.
// Simuliert die atomare Transition inkl. append-only Event-Log und
// Webhook-Idempotenz, ohne PostgreSQL.

import type { BookingStatus, Actor } from './booking.machine';
import type { BookingRecord, BookingRepository, ApplyTransitionInput } from './booking.repository';

export interface StatusEvent {
  bookingId: string;
  fromStatus: BookingStatus;
  toStatus: BookingStatus;
  triggeredBy: Actor | string;
  metadata?: Record<string, unknown>;
  at: Date;
}

export class InMemoryBookingRepository implements BookingRepository {
  private readonly bookings = new Map<string, BookingRecord>();
  private readonly processedEvents = new Set<string>();
  /** Append-only Audit-Log — Tests können hier die Historie prüfen. */
  readonly events: StatusEvent[] = [];

  seed(record: BookingRecord): void {
    this.bookings.set(record.id, { ...record });
  }

  async findById(id: string): Promise<BookingRecord | null> {
    const b = this.bookings.get(id);
    return b ? { ...b } : null;
  }

  async findByPaymentIntent(paymentIntentId: string): Promise<BookingRecord | null> {
    for (const b of this.bookings.values()) {
      if (b.paymentIntentId === paymentIntentId) return { ...b };
    }
    return null;
  }

  async applyTransition(input: ApplyTransitionInput): Promise<BookingRecord> {
    const current = this.bookings.get(input.bookingId);
    if (!current) throw new Error(`Booking ${input.bookingId} nicht gefunden.`);

    // Optimistic Concurrency: Status muss noch dem erwarteten `from` entsprechen.
    if (current.status !== input.from) {
      throw new Error(`Concurrency-Konflikt: erwartet ${input.from}, ist ${current.status}.`);
    }

    const updated: BookingRecord = {
      ...current,
      status: input.to,
      ...(input.patch ?? {}),
    };
    this.bookings.set(updated.id, updated);

    // Event nur loggen, wenn sich der Status tatsächlich ändert (kein reiner Patch).
    if (input.from !== input.to) {
      this.events.push({
        bookingId: input.bookingId,
        fromStatus: input.from,
        toStatus: input.to,
        triggeredBy: input.triggeredBy,
        metadata: input.metadata,
        at: new Date(),
      });
    }

    return { ...updated };
  }

  async hasProcessedEvent(eventId: string): Promise<boolean> {
    return this.processedEvents.has(eventId);
  }

  async markProcessedEvent(eventId: string): Promise<void> {
    this.processedEvents.add(eventId);
  }
}
