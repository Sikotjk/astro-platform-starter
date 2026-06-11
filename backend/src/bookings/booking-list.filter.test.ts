import { describe, it, expect } from 'vitest';
import { buildBookingListWhere, parseStatusFilter } from './booking-list.filter';

describe('buildBookingListWhere', () => {
  it('ohne Rolle: Nutzer als Sender ODER Traveler', () => {
    expect(buildBookingListWhere('u1', {})).toEqual({
      OR: [{ senderId: 'u1' }, { travelerId: 'u1' }],
    });
  });

  it('role=SENDER bzw. TRAVELER schränkt ein', () => {
    expect(buildBookingListWhere('u1', { role: 'SENDER' })).toEqual({ senderId: 'u1' });
    expect(buildBookingListWhere('u1', { role: 'TRAVELER' })).toEqual({ travelerId: 'u1' });
  });

  it('ergänzt den Statusfilter', () => {
    expect(
      buildBookingListWhere('u1', { role: 'SENDER', statuses: ['PAID', 'DELIVERED'] }),
    ).toEqual({ senderId: 'u1', status: { in: ['PAID', 'DELIVERED'] } });
  });

  it('leere Statusliste fügt keinen Filter hinzu', () => {
    expect(buildBookingListWhere('u1', { role: 'SENDER', statuses: [] })).toEqual({
      senderId: 'u1',
    });
  });
});

describe('parseStatusFilter', () => {
  it('parst kommaseparierte Werte (getrimmt, Großschreibung)', () => {
    expect(parseStatusFilter(' paid , delivered ')).toEqual(['PAID', 'DELIVERED']);
  });
  it('liefert undefined bei leer/undefiniert', () => {
    expect(parseStatusFilter(undefined)).toBeUndefined();
    expect(parseStatusFilter('')).toBeUndefined();
    expect(parseStatusFilter('  ,  ')).toBeUndefined();
  });
});
