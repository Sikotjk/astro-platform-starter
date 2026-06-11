# Deployment-Runbook (Backend)

Diese Anleitung deckt alles ab, was **ohne** externe Konten vorbereitet ist.
Was noch Konten/Schlüssel braucht, ist unten unter „Vor dem echten Launch"
markiert.

## Image bauen & starten

```bash
# Aus backend/
docker build -t tj-shipping-api .
docker run --rm -p 3000:3000 \
  -e DATABASE_URL=postgresql://USER:PASS@HOST:5432/DBNAME \
  -e JWT_ACCESS_SECRET=$(openssl rand -hex 32) \
  tj-shipping-api
```

Der Container wendet beim Start automatisch ausstehende Migrationen an
(`prisma migrate deploy`) und startet dann die API. Ein **HEALTHCHECK** ist im
Image hinterlegt (siehe unten).

Lokales All-in-One (App + Postgres):

```bash
docker compose up --build
```

## Pflicht-Umgebungsvariablen

| Variable | Zweck | Beispiel / Default |
|---|---|---|
| `DATABASE_URL` | Managed-Postgres-Verbindung | `postgresql://u:p@host:5432/db` |
| `JWT_ACCESS_SECRET` | Signatur der Access-Tokens | `openssl rand -hex 32` |
| `PORT` | Listen-Port | `3000` |
| `PLATFORM_FEE_RATE` | Plattformgebühr | `0.15` |

## Optionale Umgebungsvariablen

| Variable | Zweck |
|---|---|
| `CORS_ORIGIN` | Kommagetrennte Origins für ein **Web**-Frontend (mobil nicht nötig). Ohne Wert ist CORS aus. |
| `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET` / `STRIPE_IDENTITY_WEBHOOK_SECRET` | Stripe live; ohne diese laufen Zahlungen/KYC im Fake-Modus |
| `MANIFEST_FONT_DIR` | Pfad zu den DejaVu-Fonts (im Image unter `assets/`) |
| `PUSH_WEBHOOK_URL` | Outbound-Webhook für Push (FCM/APNs-Bridge) |

## Health-Endpunkte (für Load-Balancer / Orchestrator)

| Pfad | Bedeutung | Antwort |
|---|---|---|
| `GET /health` | **Liveness** — Prozess nimmt Requests an | `200 {"status":"ok"}` |
| `GET /health/ready` | **Readiness** — zusätzlich DB erreichbar | `200 {"status":"ok","db":"up"}` bzw. `503` |

- Kubernetes: `/health` als `livenessProbe`, `/health/ready` als `readinessProbe`.
- Der Docker-`HEALTHCHECK` pingt `/health` (kein zusätzliches Tool nötig).

## Rate-Limiting

- **Global**: Ein `ThrottlerGuard` läuft app-weit (`APP_GUARD`) mit großzügigem
  Default von 200 Requests/Minute je IP (In-Memory, pro Instanz).
- **Strenger limitierte Endpunkte** (per `@Throttle`):
  - `/auth/*` → 20/min (Brute-Force-Schutz für Login/Register).
  - `/customs/evaluate` → 30/min (öffentlich, auth-frei).
  - `GET /bookings/:id/manifest` → 20/min (teure PDF-Erzeugung, CPU-DoS-Schutz).
  - `/health*` ist via `@SkipThrottle()` ausgenommen (LB/Orchestrator-Probes).
- **Verteilt**: Der In-Memory-Store zählt pro Instanz. Für mehrere Instanzen
  zusätzlich am Reverse-Proxy/LB (z. B. nginx `limit_req`) oder Redis-gestützt.
- Hinter einem Proxy `app.set('trust proxy', …)` beachten, damit die echte
  Client-IP gezählt wird (sonst limitiert man den Proxy).

## Härtung (HTTP)

- **helmet**: sichere Default-Header (HSTS, X-Frame-Options, CSP …) via
  `app.use(helmet())`.
- **Body-Size-Limit**: JSON/urlencoded auf 256 KB begrenzt (Speicher-DoS-Schutz).
- **Eingabe-Validierung**: `ValidationPipe` mit `whitelist` +
  `forbidNonWhitelisted`; alle DTOs mit Längen-/Wert-/Array-Grenzen.
- **WebSocket-CORS**: Der Chat-Gateway nutzt dieselbe `CORS_ORIGIN`-Whitelist
  wie die REST-API (leer ⇒ keine Cross-Origin-Browser-Verbindungen).
- **JWT-Secret Fail-Fast**: Die App startet nicht ohne starkes
  `JWT_ACCESS_SECRET` (kein Default, Platzhalter und zu kurze Werte werden
  beim Boot abgelehnt).

## Migrationen

- **Automatisch** beim Containerstart via `prisma migrate deploy`.
- Manuell (z.B. im CI vor dem Rollout):
  ```bash
  DATABASE_URL=... npx prisma migrate deploy
  ```
- Neue Migration in der Entwicklung: `npm run prisma:migrate` (erzeugt + wendet
  an), dann committen. **Nie** `migrate dev` gegen Produktion.

## Vor dem echten Launch (braucht Konten/Entscheidungen)

| Thema | Was zu tun ist |
|---|---|
| **Postgres** | Managed-Instanz anlegen, `DATABASE_URL` setzen, Backups aktivieren |
| **HTTPS** | TLS-Terminierung (Reverse-Proxy / Plattform); App selbst spricht HTTP intern |
| **Stripe live** | Live-Keys setzen, **Webhook-Endpoint** `POST /webhooks/stripe` mit öffentlicher HTTPS-URL bei Stripe registrieren, `STRIPE_WEBHOOK_SECRET` eintragen |
| **Stripe Identity** | Identity-Webhook `POST /webhooks/stripe-identity` registrieren, `STRIPE_IDENTITY_WEBHOOK_SECRET` setzen |
| **Secrets-Management** | `JWT_ACCESS_SECRET` & Stripe-Secrets über den Secret-Store der Plattform, nicht im Image |
| **CORS** | Bei Web-Frontend `CORS_ORIGIN` auf die echte Domain setzen |
