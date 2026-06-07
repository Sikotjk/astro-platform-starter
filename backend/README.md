# TJ-Shipping Backend

Backend für die P2P-Crowdshipping-Plattform (Tadschikistan-Route).
**Stack:** NestJS · Prisma · PostgreSQL · Stripe Connect/Identity.

## Aufbauphasen

- [x] **Schritt 1 — Daten-Fundament:** Prisma-Schema (`prisma/schema.prisma`)
- [x] **Schritt 2 — Booking-State-Machine:** erlaubte Statusübergänge + Guards (`src/bookings/booking.machine.ts`, 15 Unit-Tests grün)
- [ ] **Schritt 3 — Escrow-Flow:** Stripe Connect (Hold bei Buchung, Release bei Confirm) + Webhook-Idempotenz
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

> Geldbeträge stets als `Decimal`, niemals `Float`. KYC-Rohdaten werden nicht
> gespeichert — nur Stripe-Identity-Referenzen und Verifizierungs-Claims.
