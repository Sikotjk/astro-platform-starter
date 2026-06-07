import { describe, it, expect } from 'vitest';
import {
  checkTransition,
  assertTransition,
  allowedTargets,
  isTerminal,
  BookingTransitionError,
  type BookingContext,
} from './booking.machine';

const ESCROW: Partial<BookingContext> = { escrowHeld: true };
const READY_FOR_HANDOVER: Partial<BookingContext> = {
  customsDeclared: true,
  travelerAcceptedTerms: true,
};

describe('Happy Path', () => {
  it('erlaubt den vollständigen Standard-Ablauf', () => {
    expect(checkTransition('REQUESTED', 'ACCEPTED', 'TRAVELER').ok).toBe(true);
    expect(checkTransition('ACCEPTED', 'PAID', 'SYSTEM', ESCROW).ok).toBe(true);
    expect(checkTransition('PAID', 'HANDED_OVER', 'SENDER', READY_FOR_HANDOVER).ok).toBe(true);
    expect(checkTransition('HANDED_OVER', 'IN_TRANSIT', 'TRAVELER').ok).toBe(true);
    expect(checkTransition('IN_TRANSIT', 'DELIVERED', 'TRAVELER').ok).toBe(true);
    expect(checkTransition('DELIVERED', 'CONFIRMED', 'SENDER').ok).toBe(true);
  });

  it('liefert die korrekten Geld-Nebenwirkungen', () => {
    expect(checkTransition('ACCEPTED', 'PAID', 'SYSTEM', ESCROW).effect).toBe('HOLD_ESCROW');
    expect(checkTransition('DELIVERED', 'CONFIRMED', 'SENDER').effect).toBe('RELEASE_ESCROW');
    expect(checkTransition('PAID', 'CANCELLED', 'SENDER').effect).toBe('REFUND');
  });
});

describe('Compliance-Gate (PAID → HANDED_OVER)', () => {
  it('blockt ohne abgeschlossene Zoll-Deklaration', () => {
    const r = checkTransition('PAID', 'HANDED_OVER', 'SENDER', { travelerAcceptedTerms: true });
    expect(r.ok).toBe(false);
    expect(r.reason).toMatch(/Zoll-Deklaration/);
  });

  it('blockt ohne Traveler-Bestätigung', () => {
    const r = checkTransition('PAID', 'HANDED_OVER', 'SENDER', { customsDeclared: true });
    expect(r.ok).toBe(false);
    expect(r.reason).toMatch(/Traveler/);
  });

  it('erlaubt nur mit beidem', () => {
    expect(checkTransition('PAID', 'HANDED_OVER', 'TRAVELER', READY_FOR_HANDOVER).ok).toBe(true);
  });
});

describe('Escrow-Guard (ACCEPTED → PAID)', () => {
  it('blockt, wenn Escrow nicht gehalten wird', () => {
    const r = checkTransition('ACCEPTED', 'PAID', 'SYSTEM', { escrowHeld: false });
    expect(r.ok).toBe(false);
    expect(r.reason).toMatch(/Escrow/);
  });
});

describe('Aktor-Berechtigungen', () => {
  it('Sender darf eine Anfrage nicht für den Traveler akzeptieren', () => {
    expect(checkTransition('REQUESTED', 'ACCEPTED', 'SENDER').ok).toBe(false);
  });

  it('nur Admin darf Disputes auflösen', () => {
    expect(checkTransition('DISPUTED', 'REFUNDED', 'SENDER').ok).toBe(false);
    expect(checkTransition('DISPUTED', 'REFUNDED', 'ADMIN').ok).toBe(true);
    expect(checkTransition('DISPUTED', 'CONFIRMED', 'ADMIN').effect).toBe('RELEASE_ESCROW');
  });
});

describe('Verbotene & undefinierte Übergänge', () => {
  it('verbietet das Überspringen von Schritten', () => {
    expect(checkTransition('REQUESTED', 'PAID', 'SYSTEM', ESCROW).ok).toBe(false);
    expect(checkTransition('PAID', 'DELIVERED', 'TRAVELER').ok).toBe(false);
  });

  it('verbietet Übergänge aus Endzuständen', () => {
    expect(checkTransition('CONFIRMED', 'DISPUTED', 'ADMIN').ok).toBe(false);
    expect(checkTransition('CANCELLED', 'PAID', 'SYSTEM', ESCROW).ok).toBe(false);
  });

  it('behandelt No-op (gleicher Status) als nicht erlaubt', () => {
    expect(checkTransition('PAID', 'PAID', 'SYSTEM').ok).toBe(false);
  });
});

describe('Hilfsfunktionen', () => {
  it('allowedTargets liefert erreichbare Zielzustände', () => {
    expect(allowedTargets('REQUESTED').sort()).toEqual(['ACCEPTED', 'CANCELLED', 'REJECTED']);
    expect(allowedTargets('CONFIRMED')).toEqual([]);
  });

  it('isTerminal erkennt Endzustände', () => {
    expect(isTerminal('CONFIRMED')).toBe(true);
    expect(isTerminal('REFUNDED')).toBe(true);
    expect(isTerminal('PAID')).toBe(false);
  });
});

describe('assertTransition', () => {
  it('gibt den Effekt bei Erfolg zurück', () => {
    expect(assertTransition('DELIVERED', 'CONFIRMED', 'SENDER').effect).toBe('RELEASE_ESCROW');
  });

  it('wirft BookingTransitionError bei Verstoß', () => {
    expect(() => assertTransition('PAID', 'HANDED_OVER', 'SENDER')).toThrow(BookingTransitionError);
  });
});
