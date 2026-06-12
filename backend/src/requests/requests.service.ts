import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePackageRequestDto, SearchRequestsDto } from './dto/request.dto';

/** Felder der Gegenpartei, die wir öffentlich anzeigen (Trust-Signale). */
const senderSelect = {
  id: true,
  firstName: true,
  ratingAvg: true,
  ratingCount: true,
  kycStatus: true,
} satisfies Prisma.UserSelect;

@Injectable()
export class RequestsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(senderId: string, dto: CreatePackageRequestDto) {
    return this.prisma.packageRequest.create({
      data: {
        senderId,
        title: dto.title,
        originAirport: dto.originAirport.toUpperCase(),
        destinationAirport: dto.destinationAirport.toUpperCase(),
        desiredByDate: dto.desiredByDate ? new Date(dto.desiredByDate) : null,
        weightKg: new Prisma.Decimal(dto.weightKg),
        rewardOffered: new Prisma.Decimal(dto.rewardOffered),
        currency: dto.currency ?? 'EUR',
        category: dto.category ?? 'OTHER',
        notes: dto.notes,
      },
    });
  }

  /** Öffentliches Board: offene Wünsche, optional nach Route gefiltert. */
  async search(q: SearchRequestsDto) {
    const where: Prisma.PackageRequestWhereInput = { status: 'OPEN' };
    if (q.originAirport) where.originAirport = q.originAirport.toUpperCase();
    if (q.destinationAirport) {
      where.destinationAirport = q.destinationAirport.toUpperCase();
    }
    return this.prisma.packageRequest.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: { sender: { select: senderSelect } },
    });
  }

  /** Eigene Wünsche des Senders (neueste zuerst). */
  async listMine(senderId: string) {
    return this.prisma.packageRequest.findMany({
      where: { senderId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const req = await this.prisma.packageRequest.findUnique({
      where: { id },
      include: { sender: { select: senderSelect } },
    });
    if (!req) throw new NotFoundException('Wunsch nicht gefunden.');
    return req;
  }
}
