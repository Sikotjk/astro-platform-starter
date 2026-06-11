import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/device.dto';

@Injectable()
export class DeviceTokenService {
  constructor(private readonly prisma: PrismaService) {}

  /** Registriert (oder aktualisiert) ein Geräte-Token für den Nutzer. */
  register(userId: string, dto: RegisterDeviceDto) {
    return this.prisma.deviceToken.upsert({
      where: { token: dto.token },
      update: { userId, platform: dto.platform },
      create: { userId, token: dto.token, platform: dto.platform },
    });
  }

  list(userId: string) {
    return this.prisma.deviceToken.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async remove(userId: string, id: string) {
    const row = await this.prisma.deviceToken.findUnique({ where: { id } });
    if (!row) throw new NotFoundException('Geräte-Token nicht gefunden.');
    if (row.userId !== userId) throw new ForbiddenException('Nicht dein Gerät.');
    await this.prisma.deviceToken.delete({ where: { id } });
    return { ok: true };
  }
}
