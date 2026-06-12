import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePackageRequestDto, CreateOfferDto, SearchRequestsDto } from './dto/request.dto';

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

  // ── Angebote (Reisender reagiert auf einen Wunsch) ─────────────────────────

  /** Ein Reisender gibt ein Angebot auf einen offenen Wunsch ab (idempotent). */
  async createOffer(travelerId: string, requestId: string, dto: CreateOfferDto) {
    const req = await this.prisma.packageRequest.findUnique({
      where: { id: requestId },
    });
    if (!req) throw new NotFoundException('Wunsch nicht gefunden.');
    if (req.senderId === travelerId) {
      throw new BadRequestException('Du kannst nicht auf deinen eigenen Wunsch bieten.');
    }
    if (req.status !== 'OPEN') {
      throw new ConflictException('Dieser Wunsch nimmt keine Angebote mehr an.');
    }
    return this.prisma.requestOffer.upsert({
      where: { requestId_travelerId: { requestId, travelerId } },
      create: { requestId, travelerId, message: dto.message },
      update: { message: dto.message, status: 'PENDING' },
    });
  }

  /** Angebote eines Wunsches — nur der Sender (Eigentümer) darf sie sehen. */
  async listOffers(userId: string, requestId: string) {
    const req = await this.prisma.packageRequest.findUnique({
      where: { id: requestId },
    });
    if (!req) throw new NotFoundException('Wunsch nicht gefunden.');
    if (req.senderId !== userId) {
      throw new ForbiddenException('Nur der Ersteller sieht die Angebote.');
    }
    return this.prisma.requestOffer.findMany({
      where: { requestId },
      orderBy: { createdAt: 'desc' },
      include: { traveler: { select: senderSelect } },
    });
  }

  /**
   * Der Sender nimmt ein Angebot an: Angebot -> ACCEPTED, alle anderen
   * -> DECLINED, der Wunsch -> MATCHED. Append-frei, atomar in einer Transaktion.
   */
  async acceptOffer(userId: string, requestId: string, offerId: string) {
    const req = await this.prisma.packageRequest.findUnique({
      where: { id: requestId },
    });
    if (!req) throw new NotFoundException('Wunsch nicht gefunden.');
    if (req.senderId !== userId) {
      throw new ForbiddenException('Nur der Ersteller kann Angebote annehmen.');
    }
    const offer = await this.prisma.requestOffer.findUnique({
      where: { id: offerId },
    });
    if (!offer || offer.requestId !== requestId) {
      throw new NotFoundException('Angebot nicht gefunden.');
    }
    if (req.status !== 'OPEN') {
      throw new ConflictException('Der Wunsch ist bereits vergeben.');
    }
    await this.prisma.$transaction([
      this.prisma.requestOffer.update({
        where: { id: offerId },
        data: { status: 'ACCEPTED' },
      }),
      this.prisma.requestOffer.updateMany({
        where: { requestId, id: { not: offerId } },
        data: { status: 'DECLINED' },
      }),
      this.prisma.packageRequest.update({
        where: { id: requestId },
        data: { status: 'MATCHED' },
      }),
    ]);
    return this.prisma.requestOffer.findUniqueOrThrow({
      where: { id: offerId },
      include: { traveler: { select: senderSelect } },
    });
  }
}
