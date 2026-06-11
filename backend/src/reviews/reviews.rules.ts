// Pure, framework-unabhängige Bewertungslogik.

import type { BookingStatus } from '../bookings/booking.machine';

export class ReviewError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ReviewError';
  }
}

export interface ReviewableBooking {
  senderId: string;
  travelerId: string;
  status: BookingStatus;
}

/**
 * Prüft, ob `authorId` diese Buchung bewerten darf, und liefert die ID der zu
 * bewertenden Gegenpartei (target). Bewertungen sind erst nach erfolgreichem
 * Abschluss (CONFIRMED) möglich — das verhindert Erpressungs-/Fake-Reviews.
 */
export function resolveReviewTarget(authorId: string, b: ReviewableBooking): string {
  if (b.status !== 'CONFIRMED') {
    throw new ReviewError('Bewertungen sind erst nach Abschluss (CONFIRMED) möglich.');
  }
  if (authorId === b.senderId) return b.travelerId;
  if (authorId === b.travelerId) return b.senderId;
  throw new ReviewError('Du bist an dieser Buchung nicht beteiligt.');
}

/** Neuberechnung des Durchschnitts beim Hinzufügen einer Bewertung. */
export function nextRatingAggregate(
  current: { ratingAvg: number; ratingCount: number },
  newRating: number,
): { ratingAvg: number; ratingCount: number } {
  const count = current.ratingCount + 1;
  const avg = (current.ratingAvg * current.ratingCount + newRating) / count;
  return { ratingAvg: Math.round(avg * 100) / 100, ratingCount: count };
}
