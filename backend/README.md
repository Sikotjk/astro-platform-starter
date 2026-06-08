# TJ-Shipping Backend

Backend für die P2P-Crowdshipping-Plattform (Tadschikistan-Route).
**Stack:** NestJS · Prisma · PostgreSQL · Stripe Connect/Identity.

## Aufbauphasen

- [x] **Schritt 1 — Daten-Fundament:** Prisma-Schema (`prisma/schema.prisma`)
- [x] **Schritt 2 — Booking-State-Machine:** erlaubte Statusübergänge + Guards (`src/bookings/booking.machine.ts`, 15 Unit-Tests grün)
- [x] **Schritt 3 — Escrow-Flow:** Stripe Connect hinter `PaymentGateway`-Interface (`src/payments/`), `BookingService`-Orchestrierung + Webhook-Idempotenz (`src/bookings/booking.service.ts`, 22 Tests grün)
- [x] **Schritt 4 — Compliance-Gate (Zoll):** versionierte Regel-Engine + `CustomsService` + signiertes Manifest (`src/customs/`, 42 Tests grün)
- [x] **Schritt 5 — NestJS-API:** Module auth · trips · packages · customs · bookings + Stripe-Webhook; `PrismaBookingRepository` (echte DB-Impl); `tsc`/Build/Boot verifiziert
- [x] **DB-Migration + Seed + E2E** gegen echte PostgreSQL verifiziert (Happy-Path REQUESTED..CONFIRMED)
- [x] **KYC (Stripe Identity):** `IdentityGateway` + `KycService` + idempotenter Identity-Webhook (`src/kyc/`, E2E: KYC-Gate 403→201)
- [x] **Manifest-PDF:** pdfkit-Renderer mit eingebettetem DejaVu-Font (DE/RU/TG), `GET /bookings/:id/manifest` (`src/manifest-pdf/`, E2E: echtes PDF + Hash-Header)

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

## Zoll-Compliance (Schritt 4)

`src/customs/` prüft die digitale Inhaltsdeklaration und schützt den Traveler:

- **Versionierte Regel-Engine** (`customs.rules.ts`, `RULESET_VERSION`): Kategorie-Regeln (ALLOW/WARN/BLOCK), Wert-Schwellen, Nachweispflichten + harte mehrsprachige Sperrliste (Waffen, Drogen, Sprengstoff, Bargeld).
- **`CustomsService.evaluate()`**: liefert Gesamtstufe + Item-Befunde + lokalisierte Texte (de/ru/tg). `declarable = level !== BLOCK` → entriegelt das Compliance-Gate aus Schritt 2/3.
- **Signiertes Manifest** (`manifest.ts`): kanonischer SHA-256-Hash (manipulationssicher), `verifyManifest()`, mehrsprachiges HTML als PDF-Vorlage (XSS-escaped). Dies ist die Schutzurkunde des Travelers am Zoll.

> ⚠️ Schwellen/Kategorien sind illustrativ — vor Go-live zoll-/rechtlich
> verifizieren; tadschikische Texte nativ prüfen lassen.

## API-Endpunkte (Schritt 5)

| Methode & Pfad | Auth | Zweck |
| --- | --- | --- |
| `POST /auth/register` · `POST /auth/login` | – | JWT erhalten |
| `POST /kyc/session` | JWT | Identitätsprüfung starten → `clientSecret`, Status PENDING |
| `GET /kyc/status` | JWT | aktuellen KYC-Status abfragen |
| `POST /webhooks/stripe-identity` | Signatur | `…verified` → `kycStatus=VERIFIED` (idempotent) |
| `GET /bookings/:id/manifest?locale=de\|ru\|tg` | JWT | Zoll-Manifest als PDF (erst nach Traveler-Bestätigung) |
| `POST /trips` | JWT (KYC) | Trip anbieten |
| `GET /trips` | – | Match-Suche (Route/Datum/freie kg) |
| `GET /trips/:id` | – | Trip-Detail |
| `POST /packages` | JWT | Paket + Zoll-Deklaration anlegen (BLOCK ⇒ 422) |
| `POST /customs/evaluate` | – | Zoll-Vorschau vor dem Buchen |
| `POST /bookings` | JWT | Buchungsanfrage (Preis-Snapshot) |
| `POST /bookings/:id/accept` | JWT (Traveler) | annehmen + Kapazität reservieren |
| `POST /bookings/:id/escrow` | JWT (Sender) | zahlen → `clientSecret` |
| `POST /bookings/:id/accept-terms` | JWT (Traveler) | Inhalt bestätigen (Compliance-Gate) |
| `POST /bookings/:id/handover\|transit\|delivered\|confirm\|cancel\|dispute` | JWT | Statuswechsel über die State Machine |
| `POST /webhooks/stripe` | Signatur | `payment_intent.succeeded` → PAID (idempotent) |

> Fresh-Clone-Reihenfolge: `npm install` → `npm run prisma:generate` →
> `npm run prisma:migrate -- --name init` → `npm run start:dev`.

> Geldbeträge stets als `Decimal`, niemals `Float`. KYC-Rohdaten werden nicht
> gespeichert — nur Stripe-Identity-Referenzen und Verifizierungs-Claims.
