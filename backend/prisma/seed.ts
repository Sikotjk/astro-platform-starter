// Seed: realistische Demo-Daten für lokale Entwicklung.
// Aufruf: npm run db:seed  (DATABASE_URL muss gesetzt sein)

import { PrismaClient, Prisma } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const passwordHash = await bcrypt.hash('password123', 12);

  // ── Traveler (verifiziert, hat Connect-Account) ────────────────────────────
  const traveler = await prisma.user.upsert({
    where: { email: 'karim@example.com' },
    update: {},
    create: {
      email: 'karim@example.com',
      passwordHash,
      firstName: 'Karim',
      lastName: 'Toshmatov',
      role: 'TRAVELER',
      preferredLocale: 'tg',
      kycStatus: 'VERIFIED',
      kycVerifiedAt: new Date(),
      stripeAccountId: 'acct_demo_traveler',
      payoutsEnabled: true,
      ratingAvg: 4.8,
      ratingCount: 12,
    },
  });

  // ── Sender (hat Stripe-Customer) ───────────────────────────────────────────
  const sender = await prisma.user.upsert({
    where: { email: 'anvar@example.com' },
    update: {},
    create: {
      email: 'anvar@example.com',
      passwordHash,
      firstName: 'Anvar',
      lastName: 'Sharipov',
      role: 'SENDER',
      preferredLocale: 'ru',
      kycStatus: 'VERIFIED',
      kycVerifiedAt: new Date(),
      stripeCustomerId: 'cus_demo_sender',
    },
  });

  // ── Trip: FRA -> DYU ───────────────────────────────────────────────────────
  const trip = await prisma.trip.create({
    data: {
      travelerId: traveler.id,
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureGate: 'Terminal 1, Gate B',
      departureAt: new Date(Date.now() + 14 * 24 * 3600 * 1000),
      arrivalAt: new Date(Date.now() + 14 * 24 * 3600 * 1000 + 8 * 3600 * 1000),
      capacityKgTotal: new Prisma.Decimal('15.00'),
      pricePerKg: new Prisma.Decimal('8.00'),
      currency: 'EUR',
      acceptedCategories: ['DOCUMENTS', 'CLOTHING', 'GIFTS', 'ELECTRONICS'],
      notes: 'Keine verderblichen Lebensmittel.',
    },
  });

  // ── Package mit Zoll-Deklaration ───────────────────────────────────────────
  const pkg = await prisma.package.create({
    data: {
      senderId: sender.id,
      title: 'Geschenke für die Familie',
      weightKg: new Prisma.Decimal('4.50'),
      dimensionsCm: '40x30x20',
      declaredValueEur: new Prisma.Decimal('180.00'),
      recipientName: 'Firuza Rahimova',
      recipientPhone: '+992 90 123 45 67',
      recipientCity: 'Dushanbe',
      items: {
        create: [
          {
            category: 'CLOTHING',
            description: 'Winterjacke',
            quantity: 2,
            unitValueEur: new Prisma.Decimal('45.00'),
            isSealed: false,
          },
          {
            category: 'GIFTS',
            description: 'Tee-Set',
            quantity: 1,
            unitValueEur: new Prisma.Decimal('30.00'),
            isSealed: false,
          },
          {
            category: 'ELECTRONICS',
            description: 'Kopfhörer',
            quantity: 2,
            unitValueEur: new Prisma.Decimal('30.00'),
            isSealed: false,
          },
        ],
      },
    },
  });

  // ── Booking (REQUESTED) inkl. Preis-Snapshot + Conversation ────────────────
  const agreedKg = 4.5;
  const itemPrice = 8.0 * agreedKg; // 36,00
  const serviceFee = Math.round(itemPrice * 0.15 * 100) / 100; // 5,40
  await prisma.booking.create({
    data: {
      tripId: trip.id,
      packageId: pkg.id,
      senderId: sender.id,
      travelerId: traveler.id,
      status: 'REQUESTED',
      agreedWeightKg: new Prisma.Decimal(agreedKg),
      itemPrice: new Prisma.Decimal(itemPrice.toFixed(2)),
      serviceFee: new Prisma.Decimal(serviceFee.toFixed(2)),
      totalAmount: new Prisma.Decimal((itemPrice + serviceFee).toFixed(2)),
      currency: 'EUR',
      customsDeclared: true,
      conversation: { create: {} },
    },
  });

  console.log('Seed fertig:');
  console.log(`  Traveler: ${traveler.email} (verifiziert)`);
  console.log(`  Sender:   ${sender.email}`);
  console.log(`  Trip:     ${trip.originAirport} -> ${trip.destinationAirport}`);
  console.log(`  Login-Passwort für beide: password123`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
