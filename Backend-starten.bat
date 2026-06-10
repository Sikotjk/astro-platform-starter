@echo off
REM Doppelklick startet Datenbank + API (fuer Login, Buchungen usw.).
REM Voraussetzung: Docker Desktop ist installiert und laeuft.
cd /d "%~dp0backend"
echo == Datenbank + API starten (Fenster offen lassen) ==
docker compose up --build
pause
