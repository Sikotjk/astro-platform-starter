import type { KycRepository, KycStatus, KycUserView } from './kyc.repository';

interface Row extends KycUserView {
  kycVerifiedAt?: Date;
}

export class InMemoryKycRepository implements KycRepository {
  private readonly users = new Map<string, Row>();
  private readonly processed = new Set<string>();

  seed(user: KycUserView): void {
    this.users.set(user.id, { ...user });
  }

  async findById(userId: string): Promise<KycUserView | null> {
    const u = this.users.get(userId);
    return u ? { ...u } : null;
  }

  async findBySessionId(sessionId: string): Promise<KycUserView | null> {
    for (const u of this.users.values()) {
      if (u.kycSessionId === sessionId) return { ...u };
    }
    return null;
  }

  async attachSession(userId: string, sessionId: string): Promise<void> {
    const u = this.users.get(userId);
    if (!u) throw new Error('not found');
    u.kycSessionId = sessionId;
    u.kycStatus = 'PENDING';
  }

  async setStatus(userId: string, status: KycStatus, verifiedAt?: Date): Promise<void> {
    const u = this.users.get(userId);
    if (!u) throw new Error('not found');
    u.kycStatus = status;
    u.kycVerifiedAt = verifiedAt;
  }

  async hasProcessedEvent(eventId: string): Promise<boolean> {
    return this.processed.has(eventId);
  }

  async markProcessedEvent(eventId: string): Promise<void> {
    this.processed.add(eventId);
  }
}
