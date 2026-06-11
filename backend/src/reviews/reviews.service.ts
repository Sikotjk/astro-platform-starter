import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveReviewTarget, nextRatingAggregate } from './reviews.rules';
import type { BookingStatus } from '../bookings/booking.machine';

export interface CreateReviewInput {
  rating: number;
  comment?: string;
}

@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(authorId: string, bookingId: string, input: CreateReviewInput) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { senderId: true, travelerId: true, status: true },
    });
    if (!booking) throw new NotFoundException('Buchung nicht gefunden.');

    // Wirft ReviewError (→ 409 via Filter), wenn nicht erlaubt / nicht CONFIRMED.
    const targetId = resolveReviewTarget(authorId, {
      senderId: booking.senderId,
      travelerId: booking.travelerId,
      status: booking.status as BookingStatus,
    });

    // Review anlegen + Rating-Aggregat des Bewerteten atomar fortschreiben.
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.review.findUnique({
        where: { bookingId_authorId: { bookingId, authorId } },
      });
      if (existing) throw new ConflictException('Du hast diese Buchung bereits bewertet.');

      const review = await tx.review.create({
        data: { bookingId, authorId, targetId, rating: input.rating, comment: input.comment },
      });

      const target = await tx.user.findUniqueOrThrow({
        where: { id: targetId },
        select: { ratingAvg: true, ratingCount: true },
      });
      const agg = nextRatingAggregate(
        { ratingAvg: target.ratingAvg, ratingCount: target.ratingCount },
        input.rating,
      );
      await tx.user.update({ where: { id: targetId }, data: agg });

      return review;
    });
  }

  async listForUser(userId: string) {
    return this.prisma.review.findMany({
      where: { targetId: userId },
      orderBy: { createdAt: 'desc' },
      take: 100,
      include: { author: { select: { firstName: true, avatarUrl: true } } },
    });
  }
}
