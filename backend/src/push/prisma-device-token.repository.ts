import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { DeviceTokenRepository } from './device-token.repository';

@Injectable()
export class PrismaDeviceTokenRepository implements DeviceTokenRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findTokensForUsers(userIds: string[]): Promise<string[]> {
    const rows = await this.prisma.deviceToken.findMany({
      where: { userId: { in: userIds } },
      select: { token: true },
    });
    return rows.map((r) => r.token);
  }
}
