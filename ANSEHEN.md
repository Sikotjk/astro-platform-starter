# App ansehen — in 3 Schritten

## Was du einmalig installieren musst
1. **Flutter** (für die App): https://docs.flutter.dev/get-started/install/windows
   → danach im Terminal `flutter --version` testen.
2. **Docker Desktop** (für Login/Daten, optional fürs reine Anschauen):
   https://www.docker.com/products/docker-desktop/

## Nur die App-Oberfläche ansehen (ohne Daten)
- **Doppelklick auf `App-ansehen.bat`**
- Es öffnet sich Chrome mit dem **Login-/Registrierungs-Screen**.
- Oben rechts kannst du die Sprache auf **DE / RU / TJ** umschalten.
- (Anmelden geht erst, wenn auch das Backend läuft — siehe unten.)

## Die komplette App durchklicken (mit Login)
1. **Doppelklick auf `Backend-starten.bat`** → Fenster offen lassen
   (startet Datenbank + API; beim ersten Mal dauert es ein paar Minuten).
2. **Doppelklick auf `App-ansehen.bat`** → Chrome öffnet sich.
3. Jetzt **Registrieren** und durchklicken.

## Häufige Fragen
- **„flutter wird nicht erkannt"** → Flutter ist noch nicht installiert / nicht
  im PATH. Schritt 1 oben.
- **„docker wird nicht erkannt"** → Docker Desktop installieren und starten.
- **Zahlung („Bezahlen")** ist ohne Stripe-Schlüssel deaktiviert — der restliche
  Ablauf (Suche, Buchung, Chat, Status, Bewertung) funktioniert trotzdem.
