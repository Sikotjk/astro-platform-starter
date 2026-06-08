import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSavedSearchDto } from './dto/alerts.dto';

@Injectable()
export class SavedSearchService {
  constructor(private readonly prisma: PrismaService) {}

  create(userId: string, dto: CreateSavedSearchDto) {
    return this.prisma.savedSearch.create({
      data: {
        userId,
        originAirport: dto.originAirport?.toUpperCase(),
        destinationAirport: dto.destinationAirport?.toUpperCase(),
        departureFrom: dto.departureFrom ? new Date(dto.departureFrom) : null,
        departureTo: dto.departureTo ? new Date(dto.departureTo) : null,
        minFreeKg: dto.minFreeKg != null ? new Prisma.Decimal(dto.minFreeKg) : null,
      },
    });
  }

  list(userId: string) {
    return this.prisma.savedSearch.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async remove(userId: string, id: string) {
    const search = await this.prisma.savedSearch.findUnique({ where: { id } });
    if (!search) throw new NotFoundException('Gespeicherte Suche nicht gefunden.');
    if (search.userId !== userId) throw new ForbiddenException('Nicht deine Suche.');
    await this.prisma.savedSearch.delete({ where: { id } });
    return { ok: true };
  }
}
