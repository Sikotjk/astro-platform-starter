// Persistenz-Port für die KYC-Domäne. Hält KycService unabhängig von Prisma.

export type KycStatus = 'NOT_STARTED' | 'PENDING' | 'VERIFIED' | 'REJECTED';

export interface KycUserView {
  id: string;
  email: string;
  kycStatus: KycStatus;
  kycSessionId: string | null;
}

export interface KycRepository {
  findById(userId: string): Promise<KycUserView | null>;
  findBySessionId(sessionId: string): Promise<KycUserView | null>;

  /** Verifizierungssession verknüpfen + Status auf PENDING. */
  attachSession(userId: string, sessionId: string): Promise<void>;

  /** Endstatus setzen (VERIFIED setzt zusätzlich kycVerifiedAt). */
  setStatus(userId: string, status: KycStatus, verifiedAt?: Date): Promise<void>;

  // Webhook-Idempotenz (geteilt mit Payments via ProcessedWebhookEvent).
  hasProcessedEvent(eventId: string): Promise<boolean>;
  markProcessedEvent(eventId: string, type: string): Promise<void>;
}
