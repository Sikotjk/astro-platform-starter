import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTripDto, SearchTripsDto } from './dto/trip.dto';

@Injectable()
export class TripsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(travelerId: string, dto: CreateTripDto) {
    // Nur verifizierte Nutzer dürfen Trips anbieten (Trust).
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: travelerId } });
    if (user.kycStatus !== 'VERIFIED') {
      throw new ForbiddenException('KYC-Verifizierung erforderlich, um Trips anzubieten.');
    }

    return this.prisma.trip.create({
      data: {
        travelerId,
        originAirport: dto.originAirport.toUpperCase(),
        destinationAirport: dto.destinationAirport.toUpperCase(),
        departureGate: dto.departureGate,
        departureAt: new Date(dto.departureAt),
        arrivalAt: dto.arrivalAt ? new Date(dto.arrivalAt) : null,
        capacityKgTotal: new Prisma.Decimal(dto.capacityKgTotal),
        pricePerKg: new Prisma.Decimal(dto.pricePerKg),
        currency: dto.currency ?? 'EUR',
        acceptedCategories: dto.acceptedCategories ?? [],
        notes: dto.notes,
      },
    });
  }

  /** Zentraler Match-Query. Nutzt den Composite-Index aus dem Schema. */
  async search(q: SearchTripsDto) {
    const where: Prisma.TripWhereInput = { status: 'ACTIVE' };

    if (q.originAirport) where.originAirport = q.originAirport.toUpperCase();
    if (q.destinationAirport) where.destinationAirport = q.destinationAirport.toUpperCase();
    if (q.departureFrom || q.departureTo) {
      where.departureAt = {
        ...(q.departureFrom ? { gte: new Date(q.departureFrom) } : {}),
        ...(q.departureTo ? { lte: new Date(q.departureTo) } : {}),
      };
    } else {
      where.departureAt = { gte: new Date() }; // nur künftige Flüge
    }

    const trips = await this.prisma.trip.findMany({
      where,
      orderBy: { departureAt: 'asc' },
      take: 50,
      include: {
        traveler: { select: { firstName: true, ratingAvg: true, ratingCount: true } },
      },
    });

    // Freie Restkapazität clientfreundlich berechnen + optional filtern.
    return trips
      .map((t) => ({
        ...t,
        freeKg: Number(t.capacityKgTotal) - Number(t.capacityKgUsed),
      }))
      .filter((t) => (q.minFreeKg ? t.freeKg >= q.minFreeKg : true));
  }

  async findOne(id: string) {
    const trip = await this.prisma.trip.findUnique({ where: { id } });
    if (!trip) throw new NotFoundException('Trip nicht gefunden.');
    return trip;
  }
}
