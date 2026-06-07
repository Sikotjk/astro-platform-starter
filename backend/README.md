# TJ-Shipping Backend

Backend für die P2P-Crowdshipping-Plattform (Tadschikistan-Route).
**Stack:** NestJS · Prisma · PostgreSQL · Stripe Connect/Identity.

## Aufbauphasen

- [x] **Schritt 1 — Daten-Fundament:** Prisma-Schema (`prisma/schema.prisma`)
- [x] **Schritt 2 — Booking-State-Machine:** erlaubte Statusübergänge + Guards (`src/bookings/booking.machine.ts`, 15 Unit-Tests grün)
- [x] **Schritt 3 — Escrow-Flow:** Stripe Connect hinter `PaymentGateway`-Interface (`src/payments/`), `BookingService`-Orchestrierung + Webhook-Idempotenz (`src/bookings/booking.service.ts`, 22 Tests grün)
- [ ] **Schritt 4 — Compliance-Gate:** Zoll-Deklaration + Manifest-PDF
- [ ] **Schritt 5 — API-Module:** auth · users · trips · packages · bookings · chat

## Setup (lokal)

```bash
cd backend
cp .env.example .env        # Werte ausfüllen (DATABASE_URL etc.)
npm install
npm run prisma:generate
npm run prisma:migrate -- --name init
npm run prisma:studio       # DB-Browser
npm test                    # Unit-Tests (State Machine)
```

## Datenmodell — Kernidee

| Entität   | Bedeutung                                                        |
| --------- | --------------------------------------------------------------- |
| `Trip`    | Angebot eines Travelers (freier Gepäckplatz auf einer Route)    |
| `Package` | Versandgut eines Senders inkl. Zoll-Deklaration (`PackageItem`) |
| `Booking` | Vertrag + Geld-Anker (Stripe Escrow) + Compliance-Gate          |
| `BookingStatusEvent` | Append-only Audit-Log jedes Statuswechsels           |

## Escrow-Flow (Schritt 3)

```
ACCEPTED ──createEscrow()──> PaymentIntent (Geld auf Plattform-Account)
   │                              │
   │        Stripe-Webhook payment_intent.succeeded (idempotent)
   ▼                              ▼
 PAID  (paymentStatus = ESCROW_HELD)
   │  ... HANDED_OVER → IN_TRANSIT → DELIVERED ...
   ▼
CONFIRMED ──releaseEscrow()──> Transfer itemPrice an Traveler-Connect-Account
                               (serviceFee bleibt bei der Plattform)
```

- **Stripe-Modell:** Separate Charges & Transfers, verknüpft via `transfer_group = booking_<id>`.
- **Idempotenz:** Webhooks über `ProcessedWebhookEvent`; Geld-Calls über feste `idempotencyKey`s (`release_<id>`, `refund_<id>`).
- **Testbar ohne Stripe:** `FakePaymentGateway` + `InMemoryBookingRepository`.

> Geldbeträge stets als `Decimal`, niemals `Float`. KYC-Rohdaten werden nicht
> gespeichert — nur Stripe-Identity-Referenzen und Verifizierungs-Claims.
