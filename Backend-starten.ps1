# Startet Datenbank + API (Login, Buchungen usw.) per Docker. Fenster offen lassen.
#
# Ausfuehren:
#   Rechtsklick auf diese Datei -> "Mit PowerShell ausfuehren"
#   oder im Terminal:
#   powershell -ExecutionPolicy Bypass -File .\Backend-starten.ps1
#
# Voraussetzung: Docker Desktop ist installiert und laeuft.

$ErrorActionPreference = 'Stop'
Set-Location -Path (Join-Path $PSScriptRoot 'backend')

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker wurde nicht gefunden." -ForegroundColor Red
    Write-Host "Bitte Docker Desktop installieren und starten:"
    Write-Host "  https://www.docker.com/products/docker-desktop/"
    Read-Host "Mit Enter beenden"
    exit 1
}

Write-Host "== Datenbank + API starten (Fenster offen lassen) ==" -ForegroundColor Cyan
Write-Host "   Fertig, sobald 'API laeuft auf http://localhost:3000' erscheint."
Write-Host "   Test im Browser: http://localhost:3000/health -> {""status"":""ok""}"
Write-Host ""

docker compose up --build

Read-Host "Beendet. Mit Enter schliessen"
