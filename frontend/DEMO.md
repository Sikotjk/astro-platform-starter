# Demo-Modus

Die App kann komplett **ohne Backend** ausgeführt werden — gegen ein
zustandsbehaftetes In-Memory-Backend mit Beispieldaten.

## Lokal starten

```bash
flutter run -d chrome --dart-define=DEMO_MODE=true
```

(Auf Windows: Doppelklick auf `../Demo-ansehen.bat`.)

## Online ansehen (GitHub Pages)

Bei jedem Push am Frontend baut der Workflow `.github/workflows/demo-pages.yml`
die Web-App im Demo-Modus und veröffentlicht sie auf GitHub Pages:

<https://sikotjk.github.io/astro-platform-starter/>

Die Demo enthält ausschließlich erfundene Beispieldaten — keine echten
Nutzerdaten, keine Secrets. Zahlungen (Stripe) sind im Demo deaktiviert.
