# Echte App aufs iPhone (ohne Apple-Konto, ohne Mac)

Ziel: die **echte** App (echtes Login, echte Daten) als Icon auf dem iPhone —
über eine installierbare Web-App (PWA), die gegen ein **gehostetes Backend** läuft.

## Schritt 1 — Backend hosten (einmalig)

1. Konto auf **https://render.com** anlegen, GitHub verbinden.
2. **New + → Blueprint → dieses Repo wählen.** Render liest `render.yaml`
   und legt **Datenbank + API** an.
3. **Apply** klicken. `DATABASE_URL` und `JWT_ACCESS_SECRET` werden automatisch
   gesetzt, Migrationen laufen beim Start.
4. Nach ein paar Minuten hat die API eine URL, z. B.
   **`https://tj-shipping-api.onrender.com`** — kopieren.
   Test: `…onrender.com/health` → `{"status":"ok"}`.

## Schritt 2 — App auf „echt" umschalten

1. GitHub: **Repo → Settings → Secrets and variables → Actions → Variables →
   New repository variable**
2. Name: **`API_BASE_URL`**, Wert: deine Render-URL (ohne Slash am Ende).
3. **Actions → „App (GitHub Pages)" → Run workflow** (oder einen kleinen Push).
   Der Workflow baut jetzt die **echte** App (kein Demo mehr) und deployt sie.

## Schritt 3 — Aufs iPhone holen

1. In **Safari** öffnen: **https://sikotjk.github.io/astro-platform-starter/**
2. **Teilen-Symbol → „Zum Home-Bildschirm"**.
3. Es erscheint ein **TJ-Shipping-Icon**. Öffnen → **Registrieren** → loslegen.

## Gut zu wissen
- **Kalter Start:** Render-Free-Server „schläft" bei Inaktivität — der erste
  Aufruf dauert ~30 s, danach schnell.
- **Gratis-Postgres** bei Render läuft 30 Tage; für Dauerbetrieb `DATABASE_URL`
  auf eine beständige Gratis-DB (Neon/Supabase) umstellen.
- **Zahlungen & echtes KYC sind aus** (kein Stripe). Registrierung, Wunsch-Board,
  Angebote, Chat, Profile usw. funktionieren voll. „Trip anbieten" ist
  KYC-gesperrt, bis Stripe Identity live ist.
- **CORS:** in `render.yaml` ist `CORS_ORIGIN=https://sikotjk.github.io` gesetzt
  (passend zur Pages-Domain). Eigene Domain? Dort anpassen.
