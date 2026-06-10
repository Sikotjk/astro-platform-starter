@echo off
REM Doppelklick startet die App im Chrome-Browser.
REM Voraussetzung: Flutter ist installiert (https://docs.flutter.dev/get-started/install/windows).
cd /d "%~dp0frontend"
echo == Abhaengigkeiten laden ==
call flutter pub get
echo == App startet im Chrome (Fenster offen lassen) ==
call flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
pause
