import { ForbiddenException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CustomsService } from '../customs/customs.service';
import { buildManifest } from '../customs/manifest';
import { BookingStateError } from '../bookings/booking.service';
import { MANIFEST_PDF_RENDERER } from './manifest-pdf.tokens';
import type { ManifestPdfRenderer } from './pdf-renderer';
import type { Locale, DeclarationItemInput } from '../customs/customs.types';

export interface RenderedManifest {
  pdf: Buffer;
  filename: string;
  contentHash: string;
}

@Injectable()
export class ManifestPdfService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly customs: CustomsService,
    @Inject(MANIFEST_PDF_RENDERER) private readonly renderer: ManifestPdfRenderer,
  ) {}

  async generate(bookingId: string, userId: string, locale: Locale = 'de'): Promise<RenderedManifest> {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        sender: true,
        traveler: true,
        trip: true,
        package: { include: { items: true } },
      },
    });
    if (!booking) throw new NotFoundException('Buchung nicht gefunden.');
    if (booking.senderId !== userId && booking.travelerId !== userId) {
      throw new ForbiddenException('Kein Zugriff auf diese Buchung.');
    }
    // Das offizielle Manifest existiert erst, wenn der Traveler den Inhalt
    // bestätigt hat (Beweiskette). Vorher gibt es nur die Zoll-Vorschau.
    if (!booking.travelerAcceptedTermsAt) {
      throw new BookingStateError('Traveler hat den Inhalt noch nicht bestätigt — Manifest noch nicht verfügbar.');
    }

    const items: DeclarationItemInput[] = booking.package.items.map((i) => ({
      category: i.category,
      description: i.description,
      quantity: i.quantity,
      unitValueEur: Number(i.unitValueEur),
      isSealed: i.isSealed,
    }));

    const declaration = this.customs.evaluate(items, locale);
    const manifest = buildManifest({
      bookingId: booking.id,
      sender: { fullName: `${booking.sender.firstName} ${booking.sender.lastName}` },
      recipient: { fullName: booking.package.recipientName, city: booking.package.recipientCity, phone: booking.package.recipientPhone },
      traveler: { fullName: `${booking.traveler.firstName} ${booking.traveler.lastName}` },
      trip: {
        originAirport: booking.trip.originAirport,
        destinationAirport: booking.trip.destinationAirport,
        departureAt: booking.trip.departureAt.toISOString(),
      },
      items,
      declaration,
      travelerAcceptedAt: booking.travelerAcceptedTermsAt.toISOString(),
    });

    const pdf = await this.renderer.render(manifest, locale);
    return { pdf, filename: `manifest-${booking.id}.pdf`, contentHash: manifest.contentHash };
  }
}
