# SECURITY.md — Tadschikistan-Route

Dieses Dokument fasst das Sicherheitsmodell der Plattform, die umgesetzten
Schutzmaßnahmen und die offenen Empfehlungen zusammen. Es ist Arbeitsgrundlage
für Reviews und das spätere Penetration-Testing vor dem Launch.

> Geltungsbereich: Backend (NestJS-API) und Flutter-Client. Betrieb/Hosting,
> Stripe-Live-Konfiguration und rechtliche Aspekte (DSGVO-Verträge, AGB) sind
> kontogebunden und in `backend/DEPLOYMENT.md` bzw. `CLAUDE.md` notiert.

## Sicherheits-Schwachstellen melden

Bitte Schwachstellen **nicht** über öffentliche Issues melden, sondern
vertraulich an die im Repository hinterlegte Kontaktadresse. Wir bestätigen den
Eingang zeitnah und koordinieren eine verantwortungsvolle Offenlegung.

---

## 1. Umgesetzte Schutzmaßnahmen (Stand: aktuell)

### Authentifizierung & Sessions
- **Passwörter**: bcrypt (Cost 12). Klartext wird nie gespeichert oder geloggt.
- **JWT-Access-Token**: kurzlebig (15 Min), signiert mit `JWT_ACCESS_SECRET`.
- **Refresh-Token-Rotation**: zufälliges Token (nur als SHA-256-Hash
  gespeichert), 30 Tage TTL, Single-Use. **Reuse-Detection**: Wird ein bereits
  rotiertes Token erneut benutzt, werden alle Tokens des Nutzers widerrufen.
- **JWT-Secret Fail-Fast**: Die App bootet nicht mit fehlendem, zu kurzem oder
  Platzhalter-Secret (`backend/src/common/require-secret.ts`).
- **Client-Speicher**: Tokens in `flutter_secure_storage` (Keychain/Keystore),
  nicht in SharedPreferences. Bei 401 automatischer, single-flight Refresh;
  schlägt der fehl → Logout.

### Autorisierung
- **RolesGuard** + `@Roles` für Admin-Routen (z. B. Dispute-Mediation).
- **Ownership-Checks** im Service-Layer: Chat, Buchungen, Manifest und Reviews
  prüfen die Beteiligung des Nutzers, bevor Daten herausgegeben werden.
- **State-Machine** (`bookings/booking.machine.ts`): erlaubte Übergänge **und**
  zulässige Akteure pro Übergang; append-only Audit-Log (`BookingStatusEvent`).

### Eingabe-Validierung & API-Härtung
- **ValidationPipe** global: `whitelist` (unbekannte Felder verwerfen) +
  `forbidNonWhitelisted` (Extrafelder ⇒ Fehler) + Typ-Transformation.
- **DTO-Grenzen**: Längen (`@MaxLength`), Werte (`@Min`/`@Max`) und Array-Größen
  (`@ArrayMaxSize`) auf allen schreibenden Endpunkten; URLs via `@IsUrl`.
- **helmet**: sichere HTTP-Default-Header.
- **Body-Size-Limit**: 256 KB für JSON/urlencoded.
- **Rate-Limiting**: globaler `ThrottlerGuard` (200/min) + strengere Limits auf
  Auth (20/min), Zoll-Vorschau (30/min) und Manifest-PDF (20/min);
  Health-Checks ausgenommen. Details in `backend/DEPLOYMENT.md`.

### Zahlungen (Stripe)
- **Escrow** über Stripe Connect (Separate Charges & Transfers). Geld immer als
  `Decimal`, nie Float.
- **Statuswechsel auf PAID nur per Webhook** — der Client kann den Zahlstatus
  nicht selbst setzen.
- **Webhook-Idempotenz**: `ProcessedWebhookEvent` (at-least-once-sicher).
- **Signaturprüfung**: Roh-Body (`rawBody`) für die Stripe-Signaturprüfung
  erhalten.

### Datensparsamkeit / PII
- API-Antworten enthalten **nie** `passwordHash`, Stripe-Secrets oder
  `kycSessionId` (durch E2E-Test abgesichert).
- **KYC** über Stripe Identity: die Plattform speichert **keine** Ausweisbilder,
  nur Status + Verifikationszeitpunkt.

### Transport & Netzwerk
- **CORS**: Whitelist via `CORS_ORIGIN` (REST **und** WebSocket); leer ⇒ keine
  Cross-Origin-Browser-Verbindungen. Mobile Clients senden keinen Origin.
- **TLS**: Release-Builds sprechen ausschließlich HTTPS; Cleartext-HTTP nur im
  Debug-Source-Set (Android `src/debug`, iOS `NSAllowsLocalNetworking`).

### WebSocket (Chat)
- JWT-Pflicht im Handshake; ungültige Verbindungen werden getrennt.
- Pro Buchung ein Raum; dieselben Berechtigungsregeln wie REST (über den
  `ChatService`), inkl. Lese-/Schreibprüfung.

---

## 2. Jüngste Härtung (dieser Durchlauf)

| # | Maßnahme | Schwere | Datei(en) |
|---|---|---|---|
| 1 | JWT-Secret Fail-Fast (kein Default mehr) | Kritisch | `common/require-secret.ts`, `auth/auth.module.ts` |
| 2 | `helmet`-Header aktiviert | Hoch | `main.ts` |
| 3 | Globaler `ThrottlerGuard` + strengere Endpunkt-Limits | Hoch | `app.module.ts`, `auth/customs/manifest/health`-Controller |
| 4 | Body-Size-Limit (256 KB) + DTO-Array-/Längen-/Wert-Grenzen | Hoch | `main.ts`, `*/dto/*.ts` |
| 5 | WebSocket-CORS auf `CORS_ORIGIN`-Whitelist | Mittel | `chat/chat.gateway.ts` |

---

## 3. Offene Empfehlungen (brauchen Konten/Entscheidungen oder größeren Umbau)

### Hoch
- **PII-Verschlüsselung at rest**: Empfänger-Name/-Telefon/-Adresse und
  Chat-Inhalte sind personenbezogen. Empfehlung: spaltenweise Verschlüsselung
  (pgcrypto) oder application-level Envelope-Encryption mit KMS. Voraussetzung:
  Schlüsselverwaltung (KMS/Secret-Store) → Hosting-Entscheidung.
- **Verteiltes Rate-Limiting**: Der In-Memory-Throttler zählt pro Instanz. Bei
  mehreren Instanzen Redis-gestützten Store (`@nestjs/throttler` Storage) oder
  Limits am Reverse-Proxy/LB ergänzen.
- **Foto-/Datei-Uploads** (Paketfotos, Chat-Anhänge): Aktuell nur URL-Felder.
  Vor Aktivierung: signierte Upload-URLs, Content-Type-/Größen-Whitelist,
  Viren-/Malware-Scan, getrennter Storage-Bucket, keine öffentliche Indexierung.

### Mittel
- **Refresh-Token-Secret**: `JWT_REFRESH_SECRET` ist in der `.env` vorgesehen;
  da Refresh-Tokens als Zufallswerte (gehasht) gespeichert werden, ist es heute
  nicht signaturkritisch — beim Einführen signierter Refresh-JWTs ebenfalls über
  `requireSecret` fail-fast absichern.
- **`trust proxy`**: Hinter einem LB setzen, damit der Throttler die echte
  Client-IP zählt (sonst wird der Proxy limitiert).
- **Audit-Logging/Monitoring**: strukturierte Security-Logs (fehlgeschlagene
  Logins, Reuse-Detection-Trigger, Dispute-Resolutions) an ein zentrales
  Logging/Alerting anbinden.
- **Account-Lockout / CAPTCHA**: Bei wiederholten Fehl-Logins zusätzlich zum
  Rate-Limit (z. B. progressive Delays).

### Niedrig / laufend
- **Dependency-Scanning**: `npm audit` / Dependabot im CI aktivieren.
- **Security-Header-Feintuning**: CSP für ein künftiges Web-Frontend explizit
  konfigurieren (die API liefert kein HTML).
- **DSGVO-Betroffenenrechte**: Export/Löschung von Nutzerdaten als Prozess
  (rechtliche + Produktentscheidung).

---

## 4. Bewusste Nicht-Ziele / Annahmen
- Die `README.md` im Repo-Root stammt vom Ursprungs-Template und ist nicht
  Teil des Sicherheitsmodells.
- Secrets werden nie ins Repository committet; `.env.example` enthält nur
  Platzhalter. Produktions-Secrets gehören in den Secret-Store der Plattform.
