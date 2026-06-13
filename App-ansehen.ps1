# Startet die ECHTE App im Chrome-Browser (echtes Login, echte Daten).
#
# Ausfuehren:
#   Rechtsklick auf diese Datei -> "Mit PowerShell ausfuehren"
#   oder im Terminal:
#   powershell -ExecutionPolicy Bypass -File .\App-ansehen.ps1
#
# Voraussetzung 1: Backend laeuft (zuerst Backend-starten.ps1 ausfuehren).
# Voraussetzung 2: Flutter ist installiert
#                  (https://docs.flutter.dev/get-started/install).

$ErrorActionPreference = 'Stop'
Set-Location -Path (Join-Path $PSScriptRoot 'frontend')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter wurde nicht gefunden." -ForegroundColor Red
    Write-Host "Bitte installieren: https://docs.flutter.dev/get-started/install"
    Read-Host "Mit Enter beenden"
    exit 1
}

Write-Host "== Abhaengigkeiten laden ==" -ForegroundColor Cyan
flutter pub get

Write-Host "== App startet im Edge-Browser auf http://localhost:8080 (Fenster offen lassen) ==" -ForegroundColor Cyan
flutter run -d edge --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000

Read-Host "Beendet. Mit Enter schliessen"
