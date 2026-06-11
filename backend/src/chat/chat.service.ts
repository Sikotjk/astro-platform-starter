import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { assertCanMessage, assertCanRead } from './chat.rules';
import type { BookingStatus } from '../bookings/booking.machine';

export interface SendMessageInput {
  body: string;
  attachmentUrl?: string;
}

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async listMessages(userId: string, bookingId: string) {
    const booking = await this.requireParticipantsView(bookingId);
    assertCanRead(userId, booking);
    return this.prisma.message.findMany({
      where: { bookingId },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  async sendMessage(userId: string, bookingId: string, input: SendMessageInput) {
    const booking = await this.requireParticipantsView(bookingId);
    assertCanMessage(userId, booking);

    // Conversation sicherstellen (wird normalerweise bei Buchung angelegt).
    const conversation = await this.prisma.conversation.upsert({
      where: { bookingId },
      update: {},
      create: { bookingId },
    });

    return this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        bookingId,
        senderId: userId,
        body: input.body,
        attachmentUrl: input.attachmentUrl,
      },
    });
  }

  private async requireParticipantsView(bookingId: string): Promise<{
    senderId: string;
    travelerId: string;
    status: BookingStatus;
  }> {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { senderId: true, travelerId: true, status: true },
    });
    if (!booking) throw new NotFoundException('Buchung nicht gefunden.');
    return { ...booking, status: booking.status as BookingStatus };
  }
}
