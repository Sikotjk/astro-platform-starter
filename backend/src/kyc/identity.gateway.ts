// IdentityGateway — Abstraktion über den KYC-/Identitätsprüfer (Stripe Identity).
// Wie beim PaymentGateway: Interface hält die Domänenlogik testbar (Fake) und
// den Anbieter austauschbar.

export interface CreateVerificationInput {
  userId: string;
  email: string;
}

export interface CreateVerificationResult {
  /** Stripe Identity VerificationSession-ID (vs_...). */
  sessionId: string;
  /** Für den Client (Flutter) zum Starten des Verifizierungs-Flows. */
  clientSecret: string;
  /** Optionaler Hosted-Flow-Link (Fallback ohne SDK). */
  url?: string;
}

export interface IdentityGateway {
  createVerificationSession(input: CreateVerificationInput): Promise<CreateVerificationResult>;
}
