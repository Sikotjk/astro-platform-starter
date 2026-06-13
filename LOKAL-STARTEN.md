# Echte App lokal starten (Laptop)

Die **echte** App: echtes Login, echte Datenbank, echte Buchungen/Trips/Chat.
Kein Demo-Modus. Du startest zwei Teile — **Backend** (Server + Datenbank) und
**App** (Oberfläche).

## Voraussetzungen (einmalig installieren)

- **Docker Desktop** — startet Datenbank + Server mit einem Befehl
  (https://www.docker.com/products/docker-desktop/)
- **Flutter** — baut/startet die App
  (https://docs.flutter.dev/get-started/install ; danach im Terminal
  `flutter --version` prüfen)

## Variante A — Chrome im Browser (am einfachsten, Windows)

Es gibt zwei Starter-Sätze — nimm **PowerShell** (`.ps1`) oder
**Eingabeaufforderung** (`.bat`), beide tun dasselbe.

**PowerShell** (empfohlen): Rechtsklick auf das Skript →
**„Mit PowerShell ausführen"**. Falls Windows die Ausführung blockiert, im
PowerShell-Fenster einmalig erlauben:
```powershell
powershell -ExecutionPolicy Bypass -File .\Backend-starten.ps1
```

1. **`Backend-starten.ps1`** (oder `Backend-starten.bat`) ausführen. Docker
   startet PostgreSQL + die API, führt die Migrationen aus und meldet am Ende
   `API läuft auf http://localhost:3000`. **Fenster offen lassen.**
   - Test im Browser: `http://localhost:3000/health` → `{"status":"ok"}`
2. **`App-ansehen.ps1`** (oder `App-ansehen.bat`) ausführen. Chrome öffnet die
   App auf `http://localhost:8080`. **Fenster offen lassen.**
3. Oben rechts **Registrieren** → Konto anlegen → du bist drin. Trips suchen,
   Wünsche posten, Buchungen, Chat, Profil/Bewertungen, Sprache DE/RU/TJ,
   Hell/Dunkel — alles echt.

> Der Web-Port ist fest auf **8080**, weil der Server CORS genau für diese
> Adresse erlaubt (`CORS_ORIGIN=http://localhost:8080` in
> `backend/docker-compose.yml`).

## Variante B — Android-Emulator (App wie auf dem Handy)

1. Backend wie oben starten (`Backend-starten.bat`).
2. In Android Studio einen Emulator starten (Device Manager).
3. Im Terminal aus dem Ordner `frontend`:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
   ```
   `10.0.2.2` ist die Adresse, unter der der **Emulator** den `localhost`
   deines Laptops erreicht. (Mobile Apps brauchen kein CORS.)
   - Echtes Handy per USB: statt `10.0.2.2` die LAN-IP deines Laptops nutzen,
     z. B. `http://192.168.x.x:3000`.

## Ohne Windows (Mac/Linux), manuell

```bash
# 1) Backend
cd backend
docker compose up --build        # Datenbank + API, Port 3000

# 2) App (neues Terminal)
cd frontend
flutter pub get
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000
```

## Zahlungen (optional)

Ohne Stripe-Keys läuft alles außer dem echten Bezahlschritt (die App nutzt dann
Fake-Gateways). Für echtes Bezahlen einen Stripe-Test-Key ergänzen:
`--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_…` und im Backend
`STRIPE_SECRET_KEY` setzen.

## Stoppen

Beide Fenster schließen. Backend zusätzlich: im Backend-Fenster `Strg+C`, oder
`docker compose down` aus dem Ordner `backend` (Daten bleiben im Docker-Volume
`pgdata` erhalten).
