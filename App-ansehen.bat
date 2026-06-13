@echo off
REM Doppelklick startet die ECHTE App im Chrome-Browser (echtes Login, echte Daten).
REM Voraussetzung 1: Backend laeuft (zuerst Backend-starten.bat doppelklicken).
REM Voraussetzung 2: Flutter ist installiert (https://docs.flutter.dev/get-started/install/windows).
cd /d "%~dp0frontend"
echo == Abhaengigkeiten laden ==
call flutter pub get
echo == App startet im Edge-Browser auf festem Port 8080 (Fenster offen lassen) ==
call flutter run -d edge --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000
pause
