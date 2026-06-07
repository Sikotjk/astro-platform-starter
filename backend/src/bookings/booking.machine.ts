// ─────────────────────────────────────────────────────────────────────────────
//  Booking State Machine — framework-unabhängige Kernlogik
//
//  Diese Datei kennt weder NestJS noch Prisma. Sie definiert ausschließlich,
//  WELCHE Statusübergänge erlaubt sind, WER sie auslösen darf und unter
//  WELCHEN Bedingungen (Guards). Die Ausführung (DB-Transaktion, Schreiben des
//  BookingStatusEvent-Logs, Stripe-Calls) übernimmt später der BookingService.
//
//  Die Status-Strings spiegeln das Prisma-Enum `BookingStatus` 1:1 wider.
// ─────────────────────────────────────────────────────────────────────────────

export type BookingStatus =
  | 'REQUESTED'
  | 'ACCEPTED'
  | 'REJECTED'
  | 'PAID'
  | 'HANDED_OVER'
  | 'IN_TRANSIT'
  | 'DELIVERED'
  | 'CONFIRMED'
  | 'DISPUTED'
  | 'REFUNDED'
  | 'CANCELLED';

/** Wer einen Übergang auslösen darf. SYSTEM/WEBHOOK = von Stripe/Backend. */
export type Actor = 'SENDER' | 'TRAVELER' | 'ADMIN' | 'SYSTEM';

/**
 * Geldseitige Nebenwirkung, die der Service nach einem Übergang ausführen muss.
 * Die Maschine entscheidet NICHT selbst — sie signalisiert nur die Absicht.
 */
export type PaymentEffect = 'HOLD_ESCROW' | 'RELEASE_ESCROW' | 'REFUND' | 'NONE';

/** Kontext, gegen den Guards prüfen. Bewusst minimal & serialisierbar. */
export interface BookingContext {
  /** Zoll-Deklaration abgeschlossen (mind. 1 PackageItem, vom Sender bestätigt). */
  customsDeclared: boolean;
  /** Traveler hat Beförderungsbedingungen/Inhalt akzeptiert (Zeitstempel gesetzt). */
  travelerAcceptedTerms: boolean;
  /** Escrow tatsächlich gehalten (Stripe PaymentIntent erfolgreich). */
  escrowHeld: boolean;
}

export interface TransitionDefinition {
  from: BookingStatus;
  to: BookingStatus;
  /** Rollen, die diesen Übergang anstoßen dürfen. */
  allowedActors: Actor[];
  /** Optionaler Guard. Gibt `true` zurück oder einen Fehlergrund (string). */
  guard?: (ctx: BookingContext) => true | string;
  /** Geldseitige Folge, die der Service ausführen muss. */
  effect: PaymentEffect;
}

/** Endzustände — von hier aus gibt es keinen weiteren Übergang. */
export const TERMINAL_STATES: ReadonlySet<BookingStatus> = new Set<BookingStatus>([
  'REJECTED',
  'CONFIRMED',
  'REFUNDED',
  'CANCELLED',
]);

// ─────────────────────────────── Übergangstabelle ───────────────────────────
//
// Happy Path:
//   REQUESTED → ACCEPTED → PAID → HANDED_OVER → IN_TRANSIT → DELIVERED → CONFIRMED
//
export const TRANSITIONS: ReadonlyArray<TransitionDefinition> = [
  // ── Anfrage-Phase ──────────────────────────────────────────────────────────
  { from: 'REQUESTED', to: 'ACCEPTED', allowedActors: ['TRAVELER'], effect: 'NONE' },
  { from: 'REQUESTED', to: 'REJECTED', allowedActors: ['TRAVELER'], effect: 'NONE' },
  { from: 'REQUESTED', to: 'CANCELLED', allowedActors: ['SENDER'], effect: 'NONE' },

  // ── Zahlung ─────────────────────────────────────────────────────────────────
  // Übergang nach PAID nur, wenn Escrow real gehalten wird (Webhook/System).
  {
    from: 'ACCEPTED',
    to: 'PAID',
    allowedActors: ['SYSTEM', 'SENDER'],
    guard: (c) => c.escrowHeld || 'Escrow ist nicht gehalten (PaymentIntent unbestätigt).',
    effect: 'HOLD_ESCROW',
  },
  { from: 'ACCEPTED', to: 'CANCELLED', allowedActors: ['SENDER', 'TRAVELER'], effect: 'NONE' },

  // ── Compliance-Gate: Übergabe nur mit vollständiger Zoll-Deklaration ─────────
  {
    from: 'PAID',
    to: 'HANDED_OVER',
    allowedActors: ['SENDER', 'TRAVELER'],
    guard: (c) => {
      if (!c.customsDeclared) return 'Zoll-Deklaration ist nicht abgeschlossen.';
      if (!c.travelerAcceptedTerms) return 'Traveler hat den Inhalt nicht bestätigt.';
      return true;
    },
    effect: 'NONE',
  },
  // Rückerstattung vor Übergabe (Sender zieht zurück / Traveler sagt ab).
  { from: 'PAID', to: 'CANCELLED', allowedActors: ['SENDER', 'TRAVELER', 'ADMIN'], effect: 'REFUND' },

  // ── Transport ─────────────────────────────────────────────────────────────
  { from: 'HANDED_OVER', to: 'IN_TRANSIT', allowedActors: ['TRAVELER', 'SYSTEM'], effect: 'NONE' },
  { from: 'HANDED_OVER', to: 'DISPUTED', allowedActors: ['SENDER', 'TRAVELER', 'ADMIN'], effect: 'NONE' },

  { from: 'IN_TRANSIT', to: 'DELIVERED', allowedActors: ['TRAVELER'], effect: 'NONE' },
  { from: 'IN_TRANSIT', to: 'DISPUTED', allowedActors: ['SENDER', 'TRAVELER', 'ADMIN'], effect: 'NONE' },

  // ── Abschluss: Bestätigung löst Auszahlung an Traveler aus ───────────────────
  { from: 'DELIVERED', to: 'CONFIRMED', allowedActors: ['SENDER', 'SYSTEM'], effect: 'RELEASE_ESCROW' },
  { from: 'DELIVERED', to: 'DISPUTED', allowedActors: ['SENDER', 'ADMIN'], effect: 'NONE' },

  // ── Streitbeilegung (nur Admin/Mediation) ────────────────────────────────────
  { from: 'DISPUTED', to: 'CONFIRMED', allowedActors: ['ADMIN'], effect: 'RELEASE_ESCROW' },
  { from: 'DISPUTED', to: 'REFUNDED', allowedActors: ['ADMIN'], effect: 'REFUND' },
];

export class BookingTransitionError extends Error {
  constructor(
    message: string,
    readonly from: BookingStatus,
    readonly to: BookingStatus,
  ) {
    super(message);
    this.name = 'BookingTransitionError';
  }
}

const DEFAULT_CONTEXT: BookingContext = {
  customsDeclared: false,
  travelerAcceptedTerms: false,
  escrowHeld: false,
};

function findTransition(
  from: BookingStatus,
  to: BookingStatus,
): TransitionDefinition | undefined {
  return TRANSITIONS.find((t) => t.from === from && t.to === to);
}

/** Alle Zielzustände, die von `from` aus grundsätzlich erreichbar sind. */
export function allowedTargets(from: BookingStatus): BookingStatus[] {
  return TRANSITIONS.filter((t) => t.from === from).map((t) => t.to);
}

export function isTerminal(status: BookingStatus): boolean {
  return TERMINAL_STATES.has(status);
}

export interface TransitionCheck {
  ok: boolean;
  /** Grund, falls nicht erlaubt. */
  reason?: string;
  /** Auszuführende Geld-Nebenwirkung, falls erlaubt. */
  effect?: PaymentEffect;
}

/**
 * Reine Prüfung ohne Seiteneffekte: Ist der Übergang erlaubt?
 * Prüft Existenz des Übergangs, Aktor-Berechtigung und Guard.
 */
export function checkTransition(
  from: BookingStatus,
  to: BookingStatus,
  actor: Actor,
  ctx: Partial<BookingContext> = {},
): TransitionCheck {
  if (from === to) {
    return { ok: false, reason: `No-op: Booking ist bereits im Status ${from}.` };
  }
  if (isTerminal(from)) {
    return { ok: false, reason: `Status ${from} ist final und kann nicht geändert werden.` };
  }

  const transition = findTransition(from, to);
  if (!transition) {
    return { ok: false, reason: `Übergang ${from} → ${to} ist nicht definiert.` };
  }

  if (!transition.allowedActors.includes(actor)) {
    return {
      ok: false,
      reason: `Rolle ${actor} darf den Übergang ${from} → ${to} nicht auslösen.`,
    };
  }

  if (transition.guard) {
    const guardResult = transition.guard({ ...DEFAULT_CONTEXT, ...ctx });
    if (guardResult !== true) {
      return { ok: false, reason: guardResult };
    }
  }

  return { ok: true, effect: transition.effect };
}

/**
 * Wie `checkTransition`, wirft aber bei Verstoß. Bequem im Service-Code:
 *   const { effect } = assertTransition(b.status, next, actor, ctx);
 */
export function assertTransition(
  from: BookingStatus,
  to: BookingStatus,
  actor: Actor,
  ctx: Partial<BookingContext> = {},
): { effect: PaymentEffect } {
  const result = checkTransition(from, to, actor, ctx);
  if (!result.ok) {
    throw new BookingTransitionError(result.reason ?? 'Übergang nicht erlaubt.', from, to);
  }
  return { effect: result.effect ?? 'NONE' };
}
