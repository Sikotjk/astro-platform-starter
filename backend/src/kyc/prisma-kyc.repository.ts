import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { KycRepository, KycStatus, KycUserView } from './kyc.repository';

@Injectable()
export class PrismaKycRepository implements KycRepository {
  constructor(private readonly prisma: PrismaService) {}

  private static SELECT = { id: true, email: true, kycStatus: true, kycSessionId: true } as const;

  async findById(userId: string): Promise<KycUserView | null> {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: PrismaKycRepository.SELECT,
    });
  }

  async findBySessionId(sessionId: string): Promise<KycUserView | null> {
    return this.prisma.user.findFirst({
      where: { kycSessionId: sessionId },
      select: PrismaKycRepository.SELECT,
    });
  }

  async attachSession(userId: string, sessionId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { kycSessionId: sessionId, kycStatus: 'PENDING' },
    });
  }

  async setStatus(userId: string, status: KycStatus, verifiedAt?: Date): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { kycStatus: status, kycVerifiedAt: verifiedAt ?? null },
    });
  }

  async hasProcessedEvent(eventId: string): Promise<boolean> {
    const found = await this.prisma.processedWebhookEvent.findUnique({ where: { id: eventId } });
    return found !== null;
  }

  async markProcessedEvent(eventId: string, type: string): Promise<void> {
    await this.prisma.processedWebhookEvent.create({ data: { id: eventId, type } });
  }
}
