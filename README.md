# Meridian Fund — Web-Plattform

Eine moderne, premium gestaltete Verwaltungsplattform für einen internationalen
Fonds: Dashboard, Mitglieder, Zahlungen, Berichte und Administration. Gebaut mit
**Astro 5**, **React-Islands**, **TailwindCSS 4**, **Framer Motion**, **Lucide**
und **Zod** — als statische Site auf GitHub Pages deploybar.

> **Live:** https://sikotjk.github.io/astro-platform-starter/

## Highlights

- **Design-System** mit Token-basierten Farben (Indigo / Deep Blue / Emerald /
  Slate), exzellentem Hell- **und** Dunkelmodus, Glasmorphismus, weichen Schatten.
- **World-class Dashboard** — KPIs mit animierten Zählern, interaktives
  Flächendiagramm, Donut-Allokation, Zu-/Abfluss-Balken, Aktivität, Schnellaktionen.
- **Mitglieder** — Suche, Filter, Sortierung, Pagination, CSV-Export.
- **Zahlungen** — Beiträge, Auszahlungen, Gebühren mit Status & Referenzen.
- **Berichte** — Jahresziel-Fortschritt, Mittelverwendung, herunterladbare Exporte.
- **Verwaltung** — Rollen & Berechtigungen, Audit-Log, Systemeinstellungen.
- **Command Palette** (⌘K / Strg+K), animierte Sidebar, responsive bis Mobile.
- **SEO** (OpenGraph, Twitter, JSON-LD, Sitemap, robots), Accessibility, reduce-motion.

## Architektur

```
src/
  components/
    ui/          Wiederverwendbare Primitive (Button, Card, Badge, StatCard, …)
    charts/      Eigene animierte SVG-Diagramme (Area, Bar, Donut, Sparkline)
    app/         Shell: Sidebar, Topbar, CommandPalette, ThemeToggle, PageHeader
    dashboard/ members/ payments/ reports/ settings/   Feature-Views (Islands)
  layouts/       DashboardLayout.astro (SEO + No-Flash-Dark-Mode + Shell)
  lib/           cn, site/base-helper, format, nav, data (Zod-typisierte Mock-Daten)
  pages/         index, members, payments, reports, settings, 404
  styles/        globals.css (Design-Tokens + Utilities)
```

Die Daten sind typisierte Beispiel-Daten (`src/lib/data.ts`, Zod-validiert), damit
die Oberfläche ohne Backend vollständig erlebbar ist.

## Entwicklung

```bash
npm install
npm run dev        # http://localhost:4321/astro-platform-starter
npm run build      # statischer Export nach dist/
npm run preview
```

Deployment erfolgt automatisch via GitHub Actions
(`.github/workflows/pages.yml`) bei Push auf `main`.

---

> Hinweis: Die separaten Ordner `frontend/` (Flutter) und `backend/` (NestJS)
> gehören zum eigenständigen TJ-Shipping-Projekt und sind unabhängig von dieser
> Web-Plattform.
