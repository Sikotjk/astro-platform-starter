// ─────────────────────────────────────────────────────────────────────────────
//  End-to-End-Integrationstests — booten die echte Nest-App gegen PostgreSQL.
//
//  Erfordert DATABASE_URL. Ohne Stripe-Keys nutzt die App automatisch die
//  Fake-Gateways. Der PAID-Übergang (sonst per Stripe-Webhook) wird hier direkt
//  über die DB simuliert — die Webhook-Idempotenz selbst ist unit-getestet.
// ─────────────────────────────────────────────────────────────────────────────

import { beforeAll, afterAll, describe, it, expect } from 'vitest';
import { Test } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { DomainExceptionFilter } from '../common/domain-exception.filter';

let app: INestApplication;
let prisma: PrismaService;
let http: () => import('http').Server;

// gemeinsamer Zustand über die (seriell laufenden) Tests
const state: Record<string, string> = {};

const auth = (token: string) => ({ Authorization: `Bearer ${token}` });

beforeAll(async () => {
  const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
  app = moduleRef.createNestApplication();
  app.useGlobalFilters(new DomainExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  await app.init();
  prisma = app.get(PrismaService);
  http = () => app.getHttpServer();

  // sauberer Ausgangszustand
  await prisma.$executeRawUnsafe(
    'TRUNCATE "Review","Message","Conversation","BookingStatusEvent","Booking","PackageItem","Package","Trip","ProcessedWebhookEvent","User" RESTART IDENTITY CASCADE;',
  );
});

afterAll(async () => {
  await app?.close();
});

describe('Auth & KYC-Gate', () => {
  it('registriert Sender und Traveler', async () => {
    const s = await request(http()).post('/auth/register').send({
      email: 'sender@e2e.de',
      password: 'password123',
      firstName: 'Sender',
      lastName: 'Test',
      role: 'SENDER',
    });
    expect(s.status).toBe(201);
    state.senderToken = s.body.accessToken;
    state.senderId = s.body.userId;

    const t = await request(http()).post('/auth/register').send({
      email: 'traveler@e2e.de',
      password: 'password123',
      firstName: 'Traveler',
      lastName: 'Test',
      role: 'TRAVELER',
    });
    expect(t.status).toBe(201);
    state.travelerToken = t.body.accessToken;
    state.travelerId = t.body.userId;
  });

  it('lehnt doppelte Registrierung ab (409)', async () => {
    const r = await request(http()).post('/auth/register').send({
      email: 'sender@e2e.de',
      password: 'password123',
      firstName: 'X',
      lastName: 'Y',
    });
    expect(r.status).toBe(409);
  });

  it('blockt Trip-Erstellung ohne KYC (403)', async () => {
    const r = await request(http()).post('/trips').set(auth(state.travelerToken)).send({
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureAt: '2026-09-01T10:00:00Z',
      capacityKgTotal: 10,
      pricePerKg: 8,
    });
    expect(r.status).toBe(403);
  });

  it('startet KYC -> PENDING', async () => {
    const r = await request(http()).post('/kyc/session').set(auth(state.travelerToken));
    expect(r.status).toBe(201);
    expect(r.body.clientSecret).toContain('secret');
    const status = await request(http()).get('/kyc/status').set(auth(state.travelerToken));
    expect(status.body.status).toBe('PENDING');
  });
});

describe('Zoll-Compliance', () => {
  it('Vorschau: blockt Bargeld (BLOCK, declarable=false)', async () => {
    const r = await request(http())
      .post('/customs/evaluate')
      .send({
        items: [
          {
            category: 'OTHER',
            description: 'Umschlag mit Bargeld',
            quantity: 1,
            unitValueEur: 500,
            isSealed: false,
          },
        ],
      });
    expect(r.status).toBe(201);
    expect(r.body.level).toBe('BLOCK');
    expect(r.body.declarable).toBe(false);
  });

  it('lehnt Paket mit verbotenem Inhalt ab (422)', async () => {
    const r = await request(http())
      .post('/packages')
      .set(auth(state.senderToken))
      .send({
        title: 'Verboten',
        weightKg: 1,
        declaredValueEur: 10,
        recipientName: 'R',
        recipientPhone: '+992',
        recipientCity: 'DYU',
        items: [
          {
            category: 'OTHER',
            description: 'Waffe',
            quantity: 1,
            unitValueEur: 0,
            isSealed: false,
          },
        ],
      });
    expect(r.status).toBe(422);
  });
});

describe('Kompletter Buchungs-Lebenszyklus', () => {
  it('verifizierter Traveler kann einen Trip anlegen', async () => {
    // KYC verifizieren + Stripe-Verknüpfungen setzen (sonst nur über Webhooks)
    await prisma.user.update({
      where: { id: state.travelerId },
      data: {
        kycStatus: 'VERIFIED',
        kycVerifiedAt: new Date(),
        stripeAccountId: 'acct_e2e',
        payoutsEnabled: true,
      },
    });
    await prisma.user.update({
      where: { id: state.senderId },
      data: { stripeCustomerId: 'cus_e2e' },
    });

    const r = await request(http())
      .post('/trips')
      .set(auth(state.travelerToken))
      .send({
        originAirport: 'fra',
        destinationAirport: 'dyu',
        departureAt: '2026-09-01T10:00:00Z',
        capacityKgTotal: 15,
        pricePerKg: 8,
        acceptedCategories: ['CLOTHING', 'GIFTS'],
      });
    expect(r.status).toBe(201);
    expect(r.body.originAirport).toBe('FRA'); // normalisiert
    state.tripId = r.body.id;
  });

  it('Suche findet den Trip mit freier Kapazität', async () => {
    const r = await request(http()).get('/trips?originAirport=FRA&destinationAirport=DYU');
    expect(r.status).toBe(200);
    expect(r.body.length).toBeGreaterThanOrEqual(1);
    expect(r.body[0].freeKg).toBe(15);
  });

  it('Sender legt Paket an (Zoll ALLOW)', async () => {
    const r = await request(http())
      .post('/packages')
      .set(auth(state.senderToken))
      .send({
        title: 'Geschenke',
        weightKg: 3,
        declaredValueEur: 90,
        recipientName: 'Firuza',
        recipientPhone: '+992',
        recipientCity: 'Dushanbe',
        items: [
          {
            category: 'CLOTHING',
            description: 'Jacke neu',
            quantity: 1,
            unitValueEur: 60,
            isSealed: false,
          },
        ],
      });
    expect(r.status).toBe(201);
    expect(r.body.declaration.level).toBe('ALLOW');
    state.packageId = r.body.package.id;
  });

  it('Buchung mit korrektem Preis-Snapshot (item+fee)', async () => {
    const r = await request(http()).post('/bookings').set(auth(state.senderToken)).send({
      tripId: state.tripId,
      packageId: state.packageId,
      agreedWeightKg: 3,
    });
    expect(r.status).toBe(201);
    expect(Number(r.body.itemPrice)).toBe(24); // 8 €/kg * 3
    expect(Number(r.body.serviceFee)).toBe(3.6); // 15 %
    expect(Number(r.body.totalAmount)).toBe(27.6);
    state.bookingId = r.body.id;
  });

  it('Compliance-Gate: Übergabe vor Bestätigung scheitert (409)', async () => {
    await request(http())
      .post(`/bookings/${state.bookingId}/accept`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId}/escrow`)
      .set(auth(state.senderToken))
      .expect(201);
    // PAID simulieren (Webhook-Effekt)
    await prisma.booking.update({
      where: { id: state.bookingId },
      data: { status: 'PAID', paymentStatus: 'ESCROW_HELD' },
    });

    const r = await request(http())
      .post(`/bookings/${state.bookingId}/handover`)
      .set(auth(state.senderToken));
    expect(r.status).toBe(409); // Traveler hat Inhalt noch nicht bestätigt
  });

  it('durchläuft HANDED_OVER..CONFIRMED und zahlt nur itemPrice aus', async () => {
    await request(http())
      .post(`/bookings/${state.bookingId}/accept-terms`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId}/handover`)
      .set(auth(state.senderToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId}/transit`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId}/delivered`)
      .set(auth(state.travelerToken))
      .expect(201);

    const r = await request(http())
      .post(`/bookings/${state.bookingId}/confirm`)
      .set(auth(state.senderToken));
    expect(r.status).toBe(201);
    expect(r.body.status).toBe('CONFIRMED');
    expect(r.body.paymentStatus).toBe('RELEASED');
    expect(r.body.transferId).toMatch(/^tr_fake_/);
    expect(r.body.itemPriceMinor).toBe(2400); // serviceFee bleibt bei der Plattform
  });

  it('schreibt ein lückenloses Audit-Log', async () => {
    const r = await request(http())
      .get(`/bookings/${state.bookingId}`)
      .set(auth(state.senderToken));
    const chain = r.body.statusEvents.map((e: { toStatus: string }) => e.toStatus);
    expect(chain).toEqual(['ACCEPTED', 'HANDED_OVER', 'IN_TRANSIT', 'DELIVERED', 'CONFIRMED']);
  });
});

describe('Chat', () => {
  it('Teilnehmer senden & lesen', async () => {
    await request(http())
      .post(`/bookings/${state.bookingId}/messages`)
      .set(auth(state.senderToken))
      .send({ body: 'Hallo' })
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId}/messages`)
      .set(auth(state.travelerToken))
      .send({ body: 'Servus' })
      .expect(201);
    const r = await request(http())
      .get(`/bookings/${state.bookingId}/messages`)
      .set(auth(state.senderToken));
    expect(r.body.length).toBe(2);
  });

  it('Aussenstehender wird abgewiesen (403)', async () => {
    const outsider = await request(http()).post('/auth/register').send({
      email: 'outsider@e2e.de',
      password: 'password123',
      firstName: 'Out',
      lastName: 'Sider',
    });
    const r = await request(http())
      .get(`/bookings/${state.bookingId}/messages`)
      .set(auth(outsider.body.accessToken));
    expect(r.status).toBe(403);
  });
});

describe('Reviews', () => {
  it('Sender bewertet Traveler nach Abschluss', async () => {
    const r = await request(http())
      .post(`/bookings/${state.bookingId}/review`)
      .set(auth(state.senderToken))
      .send({ rating: 5, comment: 'Top' });
    expect(r.status).toBe(201);
    expect(r.body.rating).toBe(5);
  });

  it('verhindert doppelte Bewertung (409)', async () => {
    const r = await request(http())
      .post(`/bookings/${state.bookingId}/review`)
      .set(auth(state.senderToken))
      .send({ rating: 1 });
    expect(r.status).toBe(409);
  });

  it('pflegt das Rating-Aggregat des Travelers', async () => {
    const u = await prisma.user.findUniqueOrThrow({ where: { id: state.travelerId } });
    expect(u.ratingCount).toBe(1);
    expect(u.ratingAvg).toBe(5);
    const profile = await request(http()).get(`/users/${state.travelerId}/reviews`);
    expect(profile.body.length).toBe(1);
  });
});
