# App ansehen

## Am einfachsten: Demo-Modus (ohne Backend, ohne Docker)

Du brauchst nur **Flutter**:
https://docs.flutter.dev/get-started/install/windows
(danach im Terminal `flutter --version` testen).

- **Doppelklick auf `Demo-ansehen.bat`**
- Chrome öffnet sich und die App startet **direkt angemeldet** mit
  Beispieldaten (oben rechts ein orangenes **„DEMO"**-Banner).
- Du kannst **alles durchklicken**: Trip-Suche, Buchungen mit Status-Verlauf,
  Chat, Profile/Bewertungen, Benachrichtigungen, gespeicherte Suchen, sogar
  das Zoll-Manifest als PDF. Sprache oben auf **DE / RU / TJ** umschaltbar.
- Nichts wird ins Netz gesendet — alle Daten leben nur im Browser-Tab.

> Hinweis: „Bezahlen" ist im Demo deaktiviert (kein Stripe). Buchungen, die
> auf eine Zahlung warten, kannst du im Demo nicht weiter bezahlen — der
> übrige Ablauf (Annehmen, Übergabe, Transit, Zustellung, Bestätigen,
> Bewerten) funktioniert vollständig.

## Mit echtem Backend (Login, echte Daten)

1. **Docker Desktop** installieren:
   https://www.docker.com/products/docker-desktop/
2. **Doppelklick auf `Backend-starten.bat`** → Fenster offen lassen
   (startet Datenbank + API; beim ersten Mal dauert es ein paar Minuten).
3. **Doppelklick auf `App-ansehen.bat`** → Chrome öffnet sich.
4. Jetzt **Registrieren** und durchklicken.

## Häufige Fragen
- **„flutter wird nicht erkannt"** → Flutter ist noch nicht installiert / nicht
  im PATH. Siehe Link oben.
- **„docker wird nicht erkannt"** → nur für das echte Backend nötig; für den
  Demo-Modus brauchst du Docker nicht.
