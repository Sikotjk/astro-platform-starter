// ─────────────────────────────────────────────────────────────────────────────
//  KycService — orchestriert Identitätsprüfung (framework-unabhängig)
//
//   • startVerification: erstellt eine Verification-Session, verknüpft sie,
//     setzt den User auf PENDING.
//   • handleEvent: verarbeitet Stripe-Identity-Webhooks idempotent und setzt
//     den finalen kycStatus (VERIFIED / REJECTED).
//
//  WICHTIG (DSGVO): Wir speichern KEINE Ausweis-Rohdaten — nur die Session-ID
//  und den resultierenden Status. Die Rohdaten verbleiben bei Stripe.
// ─────────────────────────────────────────────────────────────────────────────

import type { IdentityGateway } from './identity.gateway';
import type { KycRepository, KycStatus } from './kyc.repository';

export class KycUserNotFoundError extends Error {
  constructor(id: string) {
    super(`User ${id} nicht gefunden.`);
    this.name = 'KycUserNotFoundError';
  }
}

export class KycStateError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'KycStateError';
  }
}

/** Stripe-Identity-Eventtypen, die wir auf einen Status abbilden. */
const EVENT_STATUS_MAP: Record<string, KycStatus> = {
  'identity.verification_session.verified': 'VERIFIED',
  'identity.verification_session.requires_input': 'REJECTED',
  'identity.verification_session.canceled': 'REJECTED',
};

export class KycService {
  constructor(
    private readonly repo: KycRepository,
    private readonly identity: IdentityGateway,
  ) {}

  async startVerification(userId: string): Promise<{ clientSecret: string; sessionId: string }> {
    const user = await this.repo.findById(userId);
    if (!user) throw new KycUserNotFoundError(userId);
    if (user.kycStatus === 'VERIFIED') {
      throw new KycStateError('Nutzer ist bereits verifiziert.');
    }

    const { sessionId, clientSecret } = await this.identity.createVerificationSession({
      userId: user.id,
      email: user.email,
    });

    await this.repo.attachSession(user.id, sessionId);
    return { clientSecret, sessionId };
  }

  /**
   * Idempotente Webhook-Verarbeitung. Liefert {processed:false} bei Duplikaten
   * oder unbekannten Eventtypen ohne Statusänderung.
   */
  async handleEvent(
    eventId: string,
    eventType: string,
    sessionId: string,
  ): Promise<{ processed: boolean; status?: KycStatus }> {
    if (await this.repo.hasProcessedEvent(eventId)) {
      return { processed: false };
    }

    const status = EVENT_STATUS_MAP[eventType];
    let applied: KycStatus | undefined;

    if (status) {
      const user = await this.repo.findBySessionId(sessionId);
      if (user && user.kycStatus !== 'VERIFIED') {
        await this.repo.setStatus(user.id, status, status === 'VERIFIED' ? new Date() : undefined);
        applied = status;
      }
    }

    await this.repo.markProcessedEvent(eventId, eventType);
    return { processed: true, status: applied };
  }

  async getStatus(userId: string): Promise<KycStatus> {
    const user = await this.repo.findById(userId);
    if (!user) throw new KycUserNotFoundError(userId);
    return user.kycStatus;
  }
}
