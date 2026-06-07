// ─────────────────────────────────────────────────────────────────────────────
//  PaymentGateway — Abstraktion über den Zahlungsdienstleister (Stripe)
//
//  Warum ein Interface? So bleibt der BookingService testbar (FakePaymentGateway)
//  und der Anbieter austauschbar. Der Service kennt nur diese Methoden, nie das
//  Stripe-SDK direkt.
//
//  WICHTIG: Alle Beträge in MINOR UNITS (Cent) als Integer — niemals Float.
// ─────────────────────────────────────────────────────────────────────────────

export interface CreateEscrowInput {
  bookingId: string;
  /** Gesamtbetrag in Cent (itemPrice + serviceFee). */
  amountMinor: number;
  currency: string; // "eur"
  /** Stripe Customer des Senders (Zahler). */
  customerId: string;
  /**
   * Gruppiert Charge & späteren Transfer (Stripe `transfer_group`).
   * Konvention: "booking_<id>".
   */
  transferGroup: string;
}

export interface CreateEscrowResult {
  paymentIntentId: string;
  /** Für den Client (Flutter) zur Bestätigung der Zahlung. */
  clientSecret: string;
}

export interface ReleaseEscrowInput {
  bookingId: string;
  paymentIntentId: string;
  /** An den Traveler auszuzahlender Betrag in Cent (= itemPrice, ohne serviceFee). */
  payoutMinor: number;
  currency: string;
  /** Connected Account des Travelers (Empfänger). */
  destinationAccountId: string;
  transferGroup: string;
  /** Idempotenz-Schlüssel, damit ein doppelter Aufruf nicht doppelt auszahlt. */
  idempotencyKey: string;
}

export interface ReleaseEscrowResult {
  transferId: string;
}

export interface RefundInput {
  bookingId: string;
  paymentIntentId: string;
  /** Optional: Teilrückerstattung in Cent. Default: volle Erstattung. */
  amountMinor?: number;
  idempotencyKey: string;
}

export interface RefundResult {
  refundId: string;
}

export interface PaymentGateway {
  /**
   * Legt den Escrow an: erstellt einen PaymentIntent über den Gesamtbetrag.
   * Das Geld liegt nach Bestätigung auf dem Plattform-Account (Escrow),
   * der Transfer an den Traveler erfolgt erst bei `releaseEscrow`.
   */
  createEscrow(input: CreateEscrowInput): Promise<CreateEscrowResult>;

  /** Zahlt den Traveler-Anteil aus; die serviceFee verbleibt bei der Plattform. */
  releaseEscrow(input: ReleaseEscrowInput): Promise<ReleaseEscrowResult>;

  /** Erstattet den Sender (vollständig oder anteilig). */
  refund(input: RefundInput): Promise<RefundResult>;
}
