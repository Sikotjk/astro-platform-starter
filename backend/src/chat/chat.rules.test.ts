import { describe, it, expect } from 'vitest';
import { assertCanMessage, assertCanRead, participantRole, ChatAuthError } from './chat.rules';
import type { BookingParticipants } from './chat.rules';

const b = (status: BookingParticipants['status']): BookingParticipants => ({
  senderId: 's1', travelerId: 't1', status,
});

describe('participantRole', () => {
  it('erkennt Sender und Traveler', () => {
    expect(participantRole('s1', b('PAID'))).toBe('SENDER');
    expect(participantRole('t1', b('PAID'))).toBe('TRAVELER');
    expect(participantRole('x', b('PAID'))).toBeNull();
  });
});

describe('assertCanMessage', () => {
  it('erlaubt Beteiligten in aktiven Status', () => {
    expect(assertCanMessage('s1', b('REQUESTED'))).toBe('SENDER');
    expect(assertCanMessage('t1', b('IN_TRANSIT'))).toBe('TRAVELER');
  });
  it('verbietet Aussenstehende', () => {
    expect(() => assertCanMessage('x', b('PAID'))).toThrow(ChatAuthError);
  });
  it('verbietet Senden bei beendetem Booking', () => {
    expect(() => assertCanMessage('s1', b('CANCELLED'))).toThrow(/nicht mehr verfügbar/);
    expect(() => assertCanMessage('s1', b('REJECTED'))).toThrow(ChatAuthError);
  });
});

describe('assertCanRead', () => {
  it('erlaubt Lesen auch bei beendetem Booking', () => {
    expect(assertCanRead('s1', b('CANCELLED'))).toBe('SENDER');
  });
  it('verbietet Aussenstehende', () => {
    expect(() => assertCanRead('x', b('CONFIRMED'))).toThrow(ChatAuthError);
  });
});
