@echo off
REM ====================================================================
REM  Doppelklick = komplette App im DEMO-Modus ansehen.
REM  KEIN Backend, KEINE Datenbank, KEIN Docker noetig.
REM  Die App startet direkt angemeldet mit Beispieldaten.
REM  Voraussetzung: nur Flutter
REM  (https://docs.flutter.dev/get-started/install/windows).
REM ====================================================================
cd /d "%~dp0frontend"
echo == Abhaengigkeiten laden ==
call flutter pub get
echo == App startet im Chrome im DEMO-Modus (Fenster offen lassen) ==
call flutter run -d chrome --dart-define=DEMO_MODE=true
pause
