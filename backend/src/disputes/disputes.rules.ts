// Pure, framework-unabhängige Dispute-Auflösungslogik.

import type { BookingStatus } from '../bookings/booking.machine';

/** Entscheidung des Admins bei der Streitbeilegung. */
export type DisputeResolution = 'REFUND' | 'RELEASE';

/** Ziel-Status der Buchung, der den passenden Geld-Effekt auslöst. */
export function resolutionToBookingStatus(r: DisputeResolution): BookingStatus {
  return r === 'REFUND' ? 'REFUNDED' : 'CONFIRMED';
}

/** Resultierender Dispute-Status (für die Persistenz). */
export function resolutionToDisputeStatus(
  r: DisputeResolution,
): 'RESOLVED_REFUND' | 'RESOLVED_RELEASE' {
  return r === 'REFUND' ? 'RESOLVED_REFUND' : 'RESOLVED_RELEASE';
}
