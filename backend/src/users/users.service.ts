import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateMeDto } from './dto/update-me.dto';

// Sichere, nach außen sichtbare Profilfelder (kein passwordHash, keine
// internen Stripe-/KYC-Session-IDs).
const PUBLIC_SELECT = {
  id: true,
  email: true,
  phone: true,
  role: true,
  firstName: true,
  lastName: true,
  preferredLocale: true,
  avatarUrl: true,
  kycStatus: true,
  payoutsEnabled: true,
  ratingAvg: true,
  ratingCount: true,
  createdAt: true,
} as const;

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  getMe(userId: string) {
    return this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: PUBLIC_SELECT,
    });
  }

  updateMe(userId: string, dto: UpdateMeDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        firstName: dto.firstName,
        lastName: dto.lastName,
        preferredLocale: dto.preferredLocale,
        avatarUrl: dto.avatarUrl,
      },
      select: PUBLIC_SELECT,
    });
  }
}
