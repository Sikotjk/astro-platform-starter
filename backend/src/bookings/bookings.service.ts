import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { BookingService } from './booking.service';
import type { Actor, BookingStatus } from './booking.machine';
import { CreateBookingDto } from './dto/booking.dto';

@Injectable()
export class BookingsService {
  private readonly feeRate: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly domain: BookingService,
    config: ConfigService,
  ) {
    this.feeRate = Number(config.get<string>('PLATFORM_FEE_RATE', '0.15'));
  }

  // ── Buchungsanfrage durch den Sender ────────────────────────────────────────
  async create(senderId: string, dto: CreateBookingDto) {
    const [trip, pkg] = await Promise.all([
      this.prisma.trip.findUnique({ where: { id: dto.tripId } }),
      this.prisma.package.findUnique({ where: { id: dto.packageId } }),
    ]);
    if (!trip) throw new NotFoundException('Trip nicht gefunden.');
    if (!pkg) throw new NotFoundException('Paket nicht gefunden.');
    if (pkg.senderId !== senderId) throw new ForbiddenException('Paket gehört nicht dir.');
    if (trip.status !== 'ACTIVE') throw new BadRequestException('Trip ist nicht buchbar.');

    const freeKg = Number(trip.capacityKgTotal) - Number(trip.capacityKgUsed);
    if (dto.agreedWeightKg > freeKg) {
      throw new BadRequestException(`Nicht genug Kapazität (frei: ${freeKg} kg).`);
    }

    // Preis-Snapshot zum Buchungszeitpunkt.
    const itemPrice = round2(Number(trip.pricePerKg) * dto.agreedWeightKg);
    const serviceFee = round2(itemPrice * this.feeRate);
    const total = round2(itemPrice + serviceFee);

    return this.prisma.booking.create({
      data: {
        tripId: trip.id,
        packageId: pkg.id,
        senderId,
        travelerId: trip.travelerId,
        status: 'REQUESTED',
        agreedWeightKg: new Prisma.Decimal(dto.agreedWeightKg),
        itemPrice: new Prisma.Decimal(itemPrice),
        serviceFee: new Prisma.Decimal(serviceFee),
        totalAmount: new Prisma.Decimal(total),
        currency: trip.currency,
        customsDeclared: true, // Paket war bei Erstellung bereits zoll-deklariert
        conversation: { create: {} },
      },
    });
  }

  // ── Traveler akzeptiert: Status + Kapazität reservieren (atomar) ─────────────
  async accept(userId: string, bookingId: string) {
    const booking = await this.requireBooking(bookingId);
    if (booking.travelerId !== userId) throw new ForbiddenException('Nicht dein Trip.');

    await this.prisma.$transaction(async (tx) => {
      const b = await tx.booking.findUniqueOrThrow({ where: { id: bookingId } });
      await tx.trip.update({
        where: { id: b.tripId },
        data: { capacityKgUsed: { increment: b.agreedWeightKg } },
      });
    });
    return this.domain.transition(bookingId, 'ACCEPTED', 'TRAVELER');
  }

  // ── Traveler bestätigt Inhalt/Bedingungen -> entriegelt das Compliance-Gate ──
  async acceptTerms(userId: string, bookingId: string) {
    const booking = await this.requireBooking(bookingId);
    if (booking.travelerId !== userId) throw new ForbiddenException('Nicht dein Trip.');
    await this.prisma.booking.update({
      where: { id: bookingId },
      data: { travelerAcceptedTermsAt: new Date() },
    });
    return { ok: true };
  }

  // ── Escrow anlegen (Sender zahlt) ────────────────────────────────────────────
  async createEscrow(userId: string, bookingId: string) {
    const booking = await this.requireBooking(bookingId);
    if (booking.senderId !== userId) throw new ForbiddenException('Nicht deine Buchung.');
    return this.domain.createEscrow(bookingId);
  }

  // ── Generischer Statuswechsel mit Rollenauflösung ────────────────────────────
  async transition(userId: string, role: string, bookingId: string, to: BookingStatus) {
    const booking = await this.requireBooking(bookingId);
    const actor = this.resolveActor(userId, role, booking.senderId, booking.travelerId);
    return this.domain.transition(bookingId, to, actor);
  }

  async findOne(userId: string, bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        statusEvents: { orderBy: { createdAt: 'asc' } },
        package: { include: { items: true } },
      },
    });
    if (!booking) throw new NotFoundException('Buchung nicht gefunden.');
    if (booking.senderId !== userId && booking.travelerId !== userId) {
      throw new ForbiddenException('Kein Zugriff auf diese Buchung.');
    }
    return booking;
  }

  private resolveActor(userId: string, role: string, senderId: string, travelerId: string): Actor {
    if (role === 'ADMIN') return 'ADMIN';
    if (userId === senderId) return 'SENDER';
    if (userId === travelerId) return 'TRAVELER';
    throw new ForbiddenException('Du bist an dieser Buchung nicht beteiligt.');
  }

  private async requireBooking(id: string) {
    const b = await this.prisma.booking.findUnique({ where: { id } });
    if (!b) throw new NotFoundException('Buchung nicht gefunden.');
    return b;
  }
}

function round2(n: number): number {
  return Math.round((n + Number.EPSILON) * 100) / 100;
}
