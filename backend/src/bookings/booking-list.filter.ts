// Pure, framework-unabhängige Filterlogik für die "Meine Buchungen"-Liste.

import type { BookingStatus } from './booking.machine';

export type BookingListRole = 'SENDER' | 'TRAVELER';

export interface BookingListQuery {
  /** Nur als Sender bzw. als Traveler; ohne Angabe: beide Rollen. */
  role?: BookingListRole;
  /** Optionaler Statusfilter. */
  statuses?: BookingStatus[];
}

/**
 * Baut die Prisma-`where`-Bedingung für die Buchungsliste eines Nutzers.
 * Ergebnis ist ein einfaches Objekt (keine DB-Abhängigkeit) und damit testbar.
 */
export function buildBookingListWhere(
  userId: string,
  query: BookingListQuery,
): Record<string, unknown> {
  const participant =
    query.role === 'SENDER'
      ? { senderId: userId }
      : query.role === 'TRAVELER'
        ? { travelerId: userId }
        : { OR: [{ senderId: userId }, { travelerId: userId }] };

  const where: Record<string, unknown> = { ...participant };
  if (query.statuses && query.statuses.length > 0) {
    where.status = { in: query.statuses };
  }
  return where;
}

/** Parst einen kommaseparierten Statusfilter ("PAID,DELIVERED") robust. */
export function parseStatusFilter(raw: string | undefined): BookingStatus[] | undefined {
  if (!raw) return undefined;
  const parsed = raw
    .split(',')
    .map((s) => s.trim().toUpperCase())
    .filter(Boolean) as BookingStatus[];
  return parsed.length > 0 ? parsed : undefined;
}
