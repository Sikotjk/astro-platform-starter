import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BookingService } from '../bookings/booking.service';
import {
  resolutionToBookingStatus,
  resolutionToDisputeStatus,
  type DisputeResolution,
} from './disputes.rules';
import type { Actor } from '../bookings/booking.machine';

@Injectable()
export class DisputesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly bookings: BookingService,
  ) {}

  /** Streitfall durch einen Beteiligten eröffnen -> Booking nach DISPUTED. */
  async open(userId: string, role: string, bookingId: string, reason: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { senderId: true, travelerId: true },
    });
    if (!booking) throw new NotFoundException('Buchung nicht gefunden.');

    const actor = this.resolveActor(userId, role, booking.senderId, booking.travelerId);

    // Statuswechsel zuerst (validiert, ob aus dem aktuellen Status erlaubt).
    await this.bookings.transition(bookingId, 'DISPUTED', actor, { reason });

    return this.prisma.dispute.upsert({
      where: { bookingId },
      update: {}, // bereits eröffnet -> unverändert lassen
      create: { bookingId, openedById: userId, reason },
    });
  }

  /** Admin: offene Streitfälle auflisten. */
  listOpen() {
    return this.prisma.dispute.findMany({
      where: { status: 'OPEN' },
      orderBy: { createdAt: 'asc' },
      include: {
        booking: {
          select: { id: true, status: true, totalAmount: true, senderId: true, travelerId: true },
        },
      },
    });
  }

  /** Admin: Streitfall auflösen -> Escrow freigeben (RELEASE) oder erstatten (REFUND). */
  async resolve(adminId: string, bookingId: string, resolution: DisputeResolution, note?: string) {
    const dispute = await this.prisma.dispute.findUnique({ where: { bookingId } });
    if (!dispute) throw new NotFoundException('Kein Streitfall zu dieser Buchung.');
    if (dispute.status !== 'OPEN') {
      throw new ConflictException('Streitfall ist bereits aufgelöst.');
    }

    // Geld-Effekt (REFUND/RELEASE_ESCROW) läuft über die State Machine.
    await this.bookings.transition(bookingId, resolutionToBookingStatus(resolution), 'ADMIN', {
      resolution,
      note,
      resolvedById: adminId,
    });

    return this.prisma.dispute.update({
      where: { bookingId },
      data: {
        status: resolutionToDisputeStatus(resolution),
        resolutionNote: note,
        resolvedById: adminId,
        resolvedAt: new Date(),
      },
    });
  }

  private resolveActor(userId: string, role: string, senderId: string, travelerId: string): Actor {
    if (userId === senderId) return 'SENDER';
    if (userId === travelerId) return 'TRAVELER';
    if (role === 'ADMIN') return 'ADMIN';
    throw new ForbiddenException('Du bist an dieser Buchung nicht beteiligt.');
  }
}
