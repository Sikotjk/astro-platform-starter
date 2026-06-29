# CLAUDE.md — Tadschikistan-Route (Crowdshipping / P2P-Delivery)

Plattform, die Tadschiken in Deutschland, die Pakete senden wollen, mit
Reisenden verbindet, die mit freiem Gepäck nach Tadschikistan fliegen. Ziel:
ein vertrauenswürdiger, sicherer Ersatz für unstrukturierte Facebook-/Telegram-
Gruppen — mit KYC, Treuhand (Escrow), Bewertungen, Chat, Zoll-Manifest und
Streitbeilegung.

> Hinweis: Die Datei `README.md` im Repo-Root stammt noch vom ursprünglichen
> Astro/Netlify-Template und ist **nicht** relevant für dieses Projekt.

## Repo-Layout

| Pfad | Inhalt |
|---|---|
| `backend/` | NestJS-API (modularer Monolith), Prisma + PostgreSQL, Stripe |
| `frontend/` | Flutter-App `tj_shipping_app` (Android/iOS/Web), Riverpod |
| `.github/workflows/` | `backend-ci.yml`, `frontend-ci.yml` |

## Architektur

**Backend** (NestJS, TypeScript)
- Module: `auth`, `users`, `trips`, `packages`, `customs`, `bookings`,
  `kyc`, `manifest-pdf`, `chat`, `reviews`, `disputes`, `alerts`, `push`,
  `payments`, `prisma`, `common`.
- **Geld**: immer `Decimal` (nie Float). `total = itemPrice + serviceFee`,
  `serviceFee = itemPrice * PLATFORM_FEE_RATE` (Default 0.15).
- **Zahlung**: Stripe Connect (Separate Charges & Transfers, Escrow).
  `POST /bookings/:id/escrow` legt einen PaymentIntent an und gibt
  `clientSecret` zurück; auf `PAID` wechselt die Buchung erst per **Webhook**.
- **State Machine** (`bookings/booking.machine.ts`): erlaubte Übergänge +
  Akteure; append-only Audit-Log (`BookingStatusEvent`).
- **Idempotenz**: Stripe-Webhooks via `ProcessedWebhookEvent` (at-least-once).
- **Muster**: Ports/Interfaces + Fakes für Testbarkeit, reine Logik (z.B.
  `booking.machine`, `reviews.rules`, `disputes.rules`) framework-unabhängig.

**Frontend** (Flutter, Dart)
- `lib/core/` — `config`, `api_client` (Dio + Bearer-Interceptor + 401→Logout),
  `providers` (Riverpod-DI), `locale_controller`, `formatting` (intl-Datum +
  `timeAgo`), `customs` (Kategorie-Labels), `l10n_ext`.
- `lib/features/<feature>/` — je Feature `*_repository` (Interface + Dio-Impl),
  `*_controller` (StateNotifier, `AsyncValue`), `*_screen`.
- `lib/models/` — JSON-Modelle. `lib/widgets/` — wiederverwendbar
  (`StarRating`, `UserAvatar`, `ErrorRetry`, `ConfirmDialog`,
  `TravelerReputation`).
- **Navigation**: `go_router` mit Auth-Redirect (`router.dart`).
- **i18n**: `flutter gen-l10n` aus `lib/l10n/app_{de,ru,tg}.arb`. Tadschikisch
  (`tg`) wird intern als Sprachcode geführt, in der UI als **„TJ"** angezeigt;
  `intl`/Material kennen kein `tg` → Fallback auf `ru`
  (`localization_delegates.dart`, `formatting.dart`).
- **Zustände**: jeder ladende Screen nutzt `AsyncValue.when` mit `ErrorRetry`
  (einheitlicher Fehler + Wiederholen).

## Befehle

**Backend** (aus `backend/`)
```bash
docker compose up -d            # PostgreSQL
cp .env.example .env            # Secrets/Config setzen
npm ci && npm run prisma:generate && npx prisma migrate deploy
npm run start:dev               # Dev-Server (Port 3000)
npm test                        # Unit (vitest)
npm run test:e2e                # E2E (vitest + supertest, braucht Postgres)
npm run typecheck && npm run lint && npm run format:check
```

**Frontend** (aus `frontend/`, Flutter 3.44.1 / Dart 3.12.x)
```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter gen-l10n                # nach jeder ARB-Änderung
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_…   # leer => Zahlungen aus
dart format lib test
flutter analyze
flutter test
```
Android-Emulator: `API_BASE_URL=http://10.0.2.2:3000`.

## Konfiguration

- **Frontend** (`--dart-define`): `API_BASE_URL`, `STRIPE_PUBLISHABLE_KEY`
  (leer = Zahlungen deaktiviert, App läuft trotzdem). Datei `lib/core/config.dart`.
- **Backend** (`.env`, siehe `.env.example`): `DATABASE_URL`,
  `JWT_ACCESS_SECRET`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`,
  `STRIPE_IDENTITY_WEBHOOK_SECRET`, `PLATFORM_FEE_RATE` (Default `0.15`),
  `MANIFEST_FONT_DIR`, `PUSH_WEBHOOK_URL`, `PORT`.

## Native (flutter_stripe)

Bereits konfiguriert in `frontend/android` / `frontend/ios`:
`MainActivity : FlutterFragmentActivity`, App-Theme `MaterialComponents`,
`minSdk 23`, `INTERNET`-Permission, iOS-Deployment-Target 13.0. Debug-Cleartext
nur im `src/debug`-Source-Set (Release bleibt HTTPS-only); iOS
`NSAllowsLocalNetworking`. Auf macOS einmalig `cd ios && pod install`.

## Konventionen (für Beiträge / Agenten)

- **Vor jedem Commit**: `dart format` + `flutter analyze` (muss „No issues"
  sein — auch Infos wie `use_null_aware_elements` bricht die CI) + `flutter test`
  (alle grün). Bei Backend zusätzlich `typecheck` + `lint` + `format:check`.
- Kleine, fokussierte Commits. Tests zu jeder Änderung.
- Geld nie als Float; neue Status/Übergänge zuerst in der State Machine.
- Frontend: neue Repos als Interface + Dio-Impl + Fake im Test; Provider in
  `core/providers.dart`. Neue Strings in alle drei ARB-Dateien + `gen-l10n`.
- Build-Artefakte (`frontend/build/`) sind gitignored.

## Tests & CI

- Frontend: ~50 Testdateien, 140+ Tests (`flutter test`).
- Backend: Unit (vitest) + E2E (supertest gegen echtes Postgres).
- CI: `frontend-ci.yml` (Format · Analyze · Test + nativer Debug-APK-Build),
  `backend-ci.yml` (migrate → lint → typecheck → build → unit → e2e). Beide grün.

## Was bis zum Launch fehlt (braucht Konten/Entscheidungen, nicht Code)

| Thema | Blocker |
|---|---|
| Stripe live + Auszahlungen (Connect-Onboarding, Webhooks registrieren) | Stripe-Konto |
| Stripe Identity live (echtes KYC) | Stripe-Konto |
| Push-Benachrichtigungen (FCM/APNs) | Firebase-Projekt |
| Deployment (Managed Postgres, HTTPS, Secrets, Migrationen) | Hosting-Konto |
| Rechtliches: AGB, Datenschutz (DSGVO), Impressum, Zoll-/Transportrecht | anwaltliche Prüfung |
| Store-Submission (Assets, Review) | Apple-/Google-Developer-Konten |

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
