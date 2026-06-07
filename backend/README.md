# TJ-Shipping Backend

Backend für die P2P-Crowdshipping-Plattform (Tadschikistan-Route).
**Stack:** NestJS · Prisma · PostgreSQL · Stripe Connect/Identity.

## Aufbauphasen

- [x] **Schritt 1 — Daten-Fundament:** Prisma-Schema (`prisma/schema.prisma`)
- [ ] **Schritt 2 — Booking-State-Machine:** erlaubte Statusübergänge + Guards
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
