import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PushService } from '../push/push.service';
import { tripMatchesSearch } from './match';

export interface NewTripEvent {
  id: string;
  travelerId: string;
  originAirport: string;
  destinationAirport: string;
  departureAt: Date;
  freeKg: number;
}

@Injectable()
export class AlertDispatcherService {
  private readonly logger = new Logger('AlertDispatcher');

  constructor(
    private readonly prisma: PrismaService,
    private readonly push: PushService,
  ) {}

  /**
   * Erzeugt Match-Benachrichtigungen für alle gespeicherten Suchen, die zum
   * neuen Trip passen (außer der des Trip-Erstellers). Gibt die Trefferzahl
   * zurück. Bewusst best-effort: Fehler dürfen die Trip-Erstellung nicht stoppen.
   */
  async dispatchForNewTrip(trip: NewTripEvent): Promise<number> {
    // MVP-Skala: aktive Suchen laden und präzise mit dem puren Matcher prüfen.
    const candidates = await this.prisma.savedSearch.findMany({
      where: { active: true, userId: { not: trip.travelerId } },
    });

    const matched = candidates.filter((s) =>
      tripMatchesSearch(
        {
          originAirport: trip.originAirport,
          destinationAirport: trip.destinationAirport,
          departureAt: trip.departureAt,
          freeKg: trip.freeKg,
        },
        { ...s, minFreeKg: s.minFreeKg != null ? Number(s.minFreeKg) : null },
      ),
    );
    if (matched.length === 0) return 0;

    const day = trip.departureAt.toISOString().slice(0, 10);
    const title = `Neuer Trip ${trip.originAirport} → ${trip.destinationAirport}`;
    const body = `Ein passender Trip wurde eingestellt (Abflug ${day}).`;

    await this.prisma.notification.createMany({
      data: matched.map((s) => ({
        userId: s.userId,
        type: 'TRIP_MATCH',
        tripId: trip.id,
        title,
        body,
      })),
    });

    // Zusätzlich Push an die registrierten Geräte (best-effort).
    try {
      await this.push.pushToUsers(
        matched.map((s) => s.userId),
        { title, body, data: { type: 'TRIP_MATCH', tripId: trip.id } },
      );
    } catch (e) {
      this.logger.warn(`Push-Dispatch fehlgeschlagen für Trip ${trip.id}: ${(e as Error).message}`);
    }

    this.logger.debug(`Trip ${trip.id}: ${matched.length} Match-Benachrichtigung(en) erstellt.`);
    return matched.length;
  }
}
