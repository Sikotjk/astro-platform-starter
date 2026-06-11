// Pure, framework-unabhängige Chat-Berechtigungslogik.

import type { BookingStatus, Actor } from '../bookings/booking.machine';

/** Status, in denen kein Chat mehr sinnvoll/erlaubt ist (Booking beendet/abgelehnt). */
export const CHAT_BLOCKED_STATES: ReadonlySet<BookingStatus> = new Set<BookingStatus>([
  'REJECTED',
  'CANCELLED',
  'REFUNDED',
]);

export class ChatAuthError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ChatAuthError';
  }
}

export interface BookingParticipants {
  senderId: string;
  travelerId: string;
  status: BookingStatus;
}

/** Ist `userId` an der Buchung beteiligt? Liefert die Rolle oder null. */
export function participantRole(userId: string, b: BookingParticipants): Actor | null {
  if (userId === b.senderId) return 'SENDER';
  if (userId === b.travelerId) return 'TRAVELER';
  return null;
}

/**
 * Prüft, ob `userId` in dieser Buchung Nachrichten senden darf.
 * Wirft ChatAuthError bei fehlender Beteiligung oder beendetem Booking.
 */
export function assertCanMessage(userId: string, b: BookingParticipants): Actor {
  const role = participantRole(userId, b);
  if (!role) throw new ChatAuthError('Du bist an dieser Buchung nicht beteiligt.');
  if (CHAT_BLOCKED_STATES.has(b.status)) {
    throw new ChatAuthError(`Chat ist im Status ${b.status} nicht mehr verfügbar.`);
  }
  return role;
}

/** Wie assertCanMessage, aber nur Lesen — auch bei beendetem Booking erlaubt. */
export function assertCanRead(userId: string, b: BookingParticipants): Actor {
  const role = participantRole(userId, b);
  if (!role) throw new ChatAuthError('Du bist an dieser Buchung nicht beteiligt.');
  return role;
}
