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

describe('Dispute & Mediation', () => {
  it('richtet einen Admin ein und treibt eine 2. Buchung bis DELIVERED', async () => {
    // Admin registrieren -> Rolle in DB auf ADMIN -> neu einloggen (JWT trägt Rolle)
    await request(http()).post('/auth/register').send({
      email: 'admin@e2e.de',
      password: 'password123',
      firstName: 'Admin',
      lastName: 'Mediator',
    });
    await prisma.user.update({ where: { email: 'admin@e2e.de' }, data: { role: 'ADMIN' } });
    const login = await request(http())
      .post('/auth/login')
      .send({ email: 'admin@e2e.de', password: 'password123' });
    state.adminToken = login.body.accessToken;

    const pkg = await request(http())
      .post('/packages')
      .set(auth(state.senderToken))
      .send({
        title: 'Zweitpaket',
        weightKg: 2,
        declaredValueEur: 40,
        recipientName: 'R',
        recipientPhone: '+992',
        recipientCity: 'Dushanbe',
        items: [
          {
            category: 'CLOTHING',
            description: 'Pullover',
            quantity: 1,
            unitValueEur: 40,
            isSealed: false,
          },
        ],
      });
    const booking = await request(http()).post('/bookings').set(auth(state.senderToken)).send({
      tripId: state.tripId,
      packageId: pkg.body.package.id,
      agreedWeightKg: 2,
    });
    state.bookingId2 = booking.body.id;

    await request(http())
      .post(`/bookings/${state.bookingId2}/accept`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId2}/escrow`)
      .set(auth(state.senderToken))
      .expect(201);
    await prisma.booking.update({
      where: { id: state.bookingId2 },
      data: { status: 'PAID', paymentStatus: 'ESCROW_HELD' },
    });
    await request(http())
      .post(`/bookings/${state.bookingId2}/accept-terms`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId2}/handover`)
      .set(auth(state.senderToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId2}/transit`)
      .set(auth(state.travelerToken))
      .expect(201);
    await request(http())
      .post(`/bookings/${state.bookingId2}/delivered`)
      .set(auth(state.travelerToken))
      .expect(201);
  });

  it('Sender eröffnet einen Streitfall -> DISPUTED', async () => {
    const r = await request(http())
      .post(`/bookings/${state.bookingId2}/dispute`)
      .set(auth(state.senderToken))
      .send({ reason: 'Paket wurde nie zugestellt.' });
    expect(r.status).toBe(201);
    const b = await prisma.booking.findUniqueOrThrow({ where: { id: state.bookingId2 } });
    expect(b.status).toBe('DISPUTED');
  });

  it('Dispute ohne Begründung wird abgelehnt (400)', async () => {
    // anderer Booking-Kontext nicht nötig: leere Begründung verletzt DTO
    const r = await request(http())
      .post(`/bookings/${state.bookingId2}/dispute`)
      .set(auth(state.senderToken))
      .send({ reason: 'x' });
    expect(r.status).toBe(400);
  });

  it('Nicht-Admin darf die Dispute-Liste nicht sehen (403)', async () => {
    const r = await request(http()).get('/admin/disputes').set(auth(state.senderToken));
    expect(r.status).toBe(403);
  });

  it('Admin sieht offene Streitfälle', async () => {
    const r = await request(http()).get('/admin/disputes').set(auth(state.adminToken));
    expect(r.status).toBe(200);
    expect(r.body.length).toBeGreaterThanOrEqual(1);
    expect(r.body[0].status).toBe('OPEN');
  });

  it('Admin löst zugunsten des Travelers auf (RELEASE -> CONFIRMED, Auszahlung)', async () => {
    const r = await request(http())
      .post(`/admin/disputes/${state.bookingId2}/resolve`)
      .set(auth(state.adminToken))
      .send({ resolution: 'RELEASE', note: 'Zustellnachweis vorgelegt.' });
    expect(r.status).toBe(201);
    expect(r.body.status).toBe('RESOLVED_RELEASE');

    const b = await prisma.booking.findUniqueOrThrow({ where: { id: state.bookingId2 } });
    expect(b.status).toBe('CONFIRMED');
    expect(b.paymentStatus).toBe('RELEASED');
  });

  it('erneutes Auflösen wird abgelehnt (409)', async () => {
    const r = await request(http())
      .post(`/admin/disputes/${state.bookingId2}/resolve`)
      .set(auth(state.adminToken))
      .send({ resolution: 'REFUND' });
    expect(r.status).toBe(409);
  });
});

describe('Saved Searches & Match-Benachrichtigungen', () => {
  it('Sender legt eine passende und eine unpassende Suche an', async () => {
    const match = await request(http())
      .post('/saved-searches')
      .set(auth(state.senderToken))
      .send({ originAirport: 'FRA', destinationAirport: 'DYU', minFreeKg: 5 });
    expect(match.status).toBe(201);

    const noMatch = await request(http())
      .post('/saved-searches')
      .set(auth(state.senderToken))
      .send({ originAirport: 'MUC', destinationAirport: 'IST' });
    expect(noMatch.status).toBe(201);

    const list = await request(http()).get('/saved-searches').set(auth(state.senderToken));
    expect(list.body.length).toBe(2);
  });

  it('ein neuer passender Trip erzeugt genau eine Benachrichtigung', async () => {
    // Vorher keine Benachrichtigungen.
    const before = await request(http()).get('/notifications').set(auth(state.senderToken));
    expect(before.body.length).toBe(0);

    // Traveler stellt einen passenden Trip ein.
    await request(http())
      .post('/trips')
      .set(auth(state.travelerToken))
      .send({
        originAirport: 'FRA',
        destinationAirport: 'DYU',
        departureAt: '2026-10-01T10:00:00Z',
        capacityKgTotal: 12,
        pricePerKg: 7,
      })
      .expect(201);

    const after = await request(http()).get('/notifications').set(auth(state.senderToken));
    expect(after.body.length).toBe(1);
    expect(after.body[0].type).toBe('TRIP_MATCH');
    expect(after.body[0].readAt).toBeNull();
  });

  it('der Trip-Ersteller selbst wird nicht benachrichtigt', async () => {
    const travelerNotifs = await request(http())
      .get('/notifications')
      .set(auth(state.travelerToken));
    expect(travelerNotifs.body.length).toBe(0);
  });

  it('markiert alle Benachrichtigungen als gelesen', async () => {
    const res = await request(http()).post('/notifications/read-all').set(auth(state.senderToken));
    expect(res.body.updated).toBe(1);
    const unread = await request(http())
      .get('/notifications?unread=true')
      .set(auth(state.senderToken));
    expect(unread.body.length).toBe(0);
  });
});

describe('Push-Geräteregistrierung', () => {
  it('registriert ein Geräte-Token (idempotent) und listet es', async () => {
    const reg = await request(http())
      .post('/devices')
      .set(auth(state.senderToken))
      .send({ token: 'fcm-token-abcdefghij', platform: 'ANDROID' });
    expect(reg.status).toBe(201);
    state.deviceId = reg.body.id;

    // gleiches Token erneut -> kein Duplikat (upsert)
    await request(http())
      .post('/devices')
      .set(auth(state.senderToken))
      .send({ token: 'fcm-token-abcdefghij', platform: 'ANDROID' })
      .expect(201);

    const list = await request(http()).get('/devices').set(auth(state.senderToken));
    expect(list.body.length).toBe(1);
    expect(list.body[0].platform).toBe('ANDROID');
  });

  it('lehnt zu kurze Tokens ab (400)', async () => {
    const r = await request(http())
      .post('/devices')
      .set(auth(state.senderToken))
      .send({ token: 'short', platform: 'IOS' });
    expect(r.status).toBe(400);
  });

  it('entfernt ein Gerät', async () => {
    await request(http())
      .delete(`/devices/${state.deviceId}`)
      .set(auth(state.senderToken))
      .expect(200);
    const list = await request(http()).get('/devices').set(auth(state.senderToken));
    expect(list.body.length).toBe(0);
  });
});

describe('Account & Dashboard', () => {
  it('GET /me liefert das Profil ohne sensible Felder', async () => {
    const r = await request(http()).get('/me').set(auth(state.senderToken));
    expect(r.status).toBe(200);
    expect(r.body.email).toBe('sender@e2e.de');
    expect(r.body.passwordHash).toBeUndefined();
    expect(r.body.kycSessionId).toBeUndefined();
  });

  it('PATCH /me aktualisiert Name und Sprache', async () => {
    const r = await request(http())
      .patch('/me')
      .set(auth(state.senderToken))
      .send({ firstName: 'Anvar', preferredLocale: 'ru' });
    expect(r.status).toBe(200);
    expect(r.body.firstName).toBe('Anvar');
    expect(r.body.preferredLocale).toBe('ru');
  });

  it('PATCH /me lehnt ungültige Sprache ab (400)', async () => {
    const r = await request(http())
      .patch('/me')
      .set(auth(state.senderToken))
      .send({ preferredLocale: 'fr' });
    expect(r.status).toBe(400);
  });

  it('GET /bookings listet die eigenen Buchungen des Senders', async () => {
    const r = await request(http()).get('/bookings').set(auth(state.senderToken));
    expect(r.status).toBe(200);
    expect(r.body.length).toBe(2);
    expect(r.body[0].package.title).toBeDefined();
    expect(r.body[0].trip.originAirport).toBeDefined();
  });

  it('GET /bookings?role=TRAVELER liefert für den Sender nichts', async () => {
    const r = await request(http()).get('/bookings?role=TRAVELER').set(auth(state.senderToken));
    expect(r.body.length).toBe(0);
  });

  it('GET /bookings?status=... filtert nach Status', async () => {
    const confirmed = await request(http())
      .get('/bookings?status=CONFIRMED')
      .set(auth(state.senderToken));
    expect(confirmed.body.length).toBe(2);
    const paid = await request(http()).get('/bookings?status=PAID').set(auth(state.senderToken));
    expect(paid.body.length).toBe(0);
  });
});

describe('Wunsch-Board (umgekehrter Marktplatz)', () => {
  it('Sender veröffentlicht einen Liefer-Wunsch', async () => {
    const r = await request(http()).post('/requests').set(auth(state.senderToken)).send({
      title: 'Suche jemanden für Medikamente',
      originAirport: 'fra',
      destinationAirport: 'dyu',
      weightKg: 2,
      rewardOffered: 40,
      category: 'MEDICINE',
      notes: 'Bitte kühl transportieren.',
    });
    expect(r.status).toBe(201);
    expect(r.body.originAirport).toBe('FRA'); // normalisiert
    expect(r.body.status).toBe('OPEN');
    state.requestId = r.body.id;
  });

  it('lehnt einen Wunsch ohne Auth ab (401)', async () => {
    const r = await request(http()).post('/requests').send({
      title: 'X',
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      weightKg: 1,
      rewardOffered: 10,
    });
    expect(r.status).toBe(401);
  });

  it('Board listet offene Wünsche inkl. Sender-Reputation', async () => {
    const r = await request(http()).get('/requests?originAirport=FRA&destinationAirport=DYU');
    expect(r.status).toBe(200);
    expect(r.body.length).toBeGreaterThanOrEqual(1);
    expect(r.body[0].sender.firstName).toBeDefined();
    expect(r.body[0].sender.passwordHash).toBeUndefined();
  });

  it('Board filtert nach Route (kein Treffer)', async () => {
    const r = await request(http()).get('/requests?originAirport=MUC&destinationAirport=IST');
    expect(r.status).toBe(200);
    expect(r.body.length).toBe(0);
  });

  it('GET /requests/mine liefert die eigenen Wünsche', async () => {
    const r = await request(http()).get('/requests/mine').set(auth(state.senderToken));
    expect(r.status).toBe(200);
    expect(r.body.length).toBe(1);
  });

  it('GET /requests/:id liefert den Wunsch', async () => {
    const r = await request(http()).get(`/requests/${state.requestId}`);
    expect(r.status).toBe(200);
    expect(r.body.title).toContain('Medikamente');
  });
});
