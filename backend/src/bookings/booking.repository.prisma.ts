// PrismaBookingRepository — echte Persistenz-Implementierung des Ports.
// applyTransition läuft in EINER DB-Transaktion: atomarer Status-Wechsel
// (mit optimistic-concurrency via updateMany.where.status) + append-only Event.

import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { eurosToMinor } from '../common/money';
import type { BookingStatus } from './booking.machine';
import type { BookingRecord, BookingRepository, ApplyTransitionInput } from './booking.repository';

type BookingWithParties = Prisma.BookingGetPayload<{
  include: { sender: true; traveler: true };
}>;

@Injectable()
export class PrismaBookingRepository implements BookingRepository {
  constructor(private readonly prisma: PrismaService) {}

  private map(b: BookingWithParties): BookingRecord {
    return {
      id: b.id,
      status: b.status as BookingStatus,
      senderId: b.senderId,
      travelerId: b.travelerId,
      itemPriceMinor: eurosToMinor(b.itemPrice),
      serviceFeeMinor: eurosToMinor(b.serviceFee),
      totalAmountMinor: eurosToMinor(b.totalAmount),
      currency: b.currency,
      paymentIntentId: b.paymentIntentId,
      transferId: b.transferId,
      paymentStatus: b.paymentStatus,
      customsDeclared: b.customsDeclared,
      travelerAcceptedTerms: b.travelerAcceptedTermsAt !== null,
      senderStripeCustomerId: b.sender.stripeCustomerId,
      travelerStripeAccountId: b.traveler.stripeAccountId,
    };
  }

  async findById(id: string): Promise<BookingRecord | null> {
    const b = await this.prisma.booking.findUnique({
      where: { id },
      include: { sender: true, traveler: true },
    });
    return b ? this.map(b) : null;
  }

  async findByPaymentIntent(paymentIntentId: string): Promise<BookingRecord | null> {
    const b = await this.prisma.booking.findFirst({
      where: { paymentIntentId },
      include: { sender: true, traveler: true },
    });
    return b ? this.map(b) : null;
  }

  async applyTransition(input: ApplyTransitionInput): Promise<BookingRecord> {
    return this.prisma.$transaction(async (tx) => {
      const data: Prisma.BookingUpdateManyMutationInput = { status: input.to };
      if (input.patch?.paymentStatus !== undefined) data.paymentStatus = input.patch.paymentStatus;
      if (input.patch?.paymentIntentId !== undefined)
        data.paymentIntentId = input.patch.paymentIntentId;
      if (input.patch?.transferId !== undefined) data.transferId = input.patch.transferId;

      // Optimistic concurrency: nur aktualisieren, wenn Status noch `from` ist.
      const res = await tx.booking.updateMany({
        where: { id: input.bookingId, status: input.from },
        data,
      });
      if (res.count !== 1) {
        throw new Error(
          `Concurrency-Konflikt für Booking ${input.bookingId}: erwartet ${input.from}.`,
        );
      }

      // Append-only Event nur bei echtem Statuswechsel (nicht bei reinem Patch).
      if (input.from !== input.to) {
        await tx.bookingStatusEvent.create({
          data: {
            bookingId: input.bookingId,
            fromStatus: input.from,
            toStatus: input.to,
            triggeredBy: String(input.triggeredBy),
            metadata: (input.metadata ?? undefined) as Prisma.InputJsonValue,
          },
        });
      }

      const updated = await tx.booking.findUniqueOrThrow({
        where: { id: input.bookingId },
        include: { sender: true, traveler: true },
      });
      return this.map(updated);
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
