// ─────────────────────────────────────────────────────────────────────────────
//  Manifest-Generator — das digitale, signierte Frachtmanifest
//
//  Dieses Dokument ist die SCHUTZURKUNDE des Travelers am Zoll: Es belegt,
//  welchen deklarierten Inhalt er befördert und dass beide Parteien zugestimmt
//  haben. Der SHA-256-Hash über den kanonischen Inhalt macht spätere
//  Manipulation nachweisbar (Integrität).
//
//  Erzeugt strukturierte Daten + einen Hash. Das eigentliche PDF rendert ein
//  dünner Adapter (z.B. Puppeteer/pdfkit) aus dem hier gelieferten HTML.
// ─────────────────────────────────────────────────────────────────────────────

import { createHash } from 'node:crypto';
import type { DeclarationItemInput, DeclarationResult, Locale } from './customs.types';

export interface ManifestParty {
  fullName: string;
  city?: string;
  phone?: string;
}

export interface ManifestTrip {
  originAirport: string;
  destinationAirport: string;
  departureAt: string; // ISO
}

export interface BuildManifestInput {
  bookingId: string;
  sender: ManifestParty;
  recipient: ManifestParty;
  traveler: ManifestParty;
  trip: ManifestTrip;
  items: DeclarationItemInput[];
  declaration: DeclarationResult;
  /** Zeitpunkt der Traveler-Zustimmung (ISO) — Teil der Beweiskette. */
  travelerAcceptedAt: string;
  generatedAt?: string; // ISO, default: jetzt
}

export interface Manifest extends Omit<BuildManifestInput, 'generatedAt'> {
  rulesetVersion: string;
  totalValueEur: number;
  generatedAt: string;
  /** SHA-256 über den kanonischen Manifest-Inhalt (ohne den Hash selbst). */
  contentHash: string;
}

/**
 * Kanonische Serialisierung: Schlüssel rekursiv sortiert, damit der Hash
 * deterministisch und unabhängig von der Feld-Reihenfolge ist.
 */
function canonicalize(value: unknown): string {
  return JSON.stringify(sortDeep(value));
}

function sortDeep(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sortDeep);
  if (value && typeof value === 'object') {
    return Object.keys(value as Record<string, unknown>)
      .sort()
      .reduce<Record<string, unknown>>((acc, key) => {
        acc[key] = sortDeep((value as Record<string, unknown>)[key]);
        return acc;
      }, {});
  }
  return value;
}

export function buildManifest(input: BuildManifestInput): Manifest {
  if (!input.declaration.declarable) {
    throw new Error('Manifest kann für eine BLOCK-Deklaration nicht erstellt werden.');
  }

  const generatedAt = input.generatedAt ?? new Date().toISOString();
  const core = {
    bookingId: input.bookingId,
    sender: input.sender,
    recipient: input.recipient,
    traveler: input.traveler,
    trip: input.trip,
    items: input.items,
    rulesetVersion: input.declaration.rulesetVersion,
    totalValueEur: input.declaration.totalValueEur,
    travelerAcceptedAt: input.travelerAcceptedAt,
    generatedAt,
  };

  const contentHash = createHash('sha256').update(canonicalize(core)).digest('hex');

  return { ...core, declaration: input.declaration, contentHash };
}

/** Verifiziert die Integrität eines Manifests (z.B. beim erneuten Abruf). */
export function verifyManifest(manifest: Manifest): boolean {
  // `declaration` ist nicht Teil des gehashten Kerns -> beim Verifizieren ausschließen.
  const { contentHash, declaration: _declaration, ...core } = manifest;
  const recomputed = createHash('sha256').update(canonicalize(core)).digest('hex');
  return recomputed === contentHash;
}

// ── Mehrsprachige PDF-Vorlage (HTML) ─────────────────────────────────────────

const LABELS: Record<Locale, Record<string, string>> = {
  de: {
    title: 'Frachtmanifest / Zoll-Deklaration',
    booking: 'Buchung',
    sender: 'Absender',
    recipient: 'Empfänger',
    traveler: 'Transporteur (Reisender)',
    route: 'Route',
    departure: 'Abflug',
    items: 'Inhalt',
    category: 'Kategorie',
    description: 'Beschreibung',
    qty: 'Menge',
    value: 'Wert (EUR)',
    total: 'Gesamtwert',
    accepted: 'Vom Reisenden bestätigt am',
    ruleset: 'Regelwerk-Version',
    hash: 'Integritäts-Hash (SHA-256)',
    disclaimer:
      'Der Absender bestätigt die Richtigkeit dieser Angaben. Der Reisende befördert ausschließlich den deklarierten Inhalt.',
  },
  ru: {
    title: 'Грузовой манифест / Таможенная декларация',
    booking: 'Бронирование',
    sender: 'Отправитель',
    recipient: 'Получатель',
    traveler: 'Перевозчик (путешественник)',
    route: 'Маршрут',
    departure: 'Вылет',
    items: 'Содержимое',
    category: 'Категория',
    description: 'Описание',
    qty: 'Кол-во',
    value: 'Стоимость (EUR)',
    total: 'Общая стоимость',
    accepted: 'Подтверждено путешественником',
    ruleset: 'Версия правил',
    hash: 'Хеш целостности (SHA-256)',
    disclaimer:
      'Отправитель подтверждает достоверность данных. Путешественник перевозит только заявленное содержимое.',
  },
  tg: {
    title: 'Манифести бор / Декларатсияи гумрукӣ',
    booking: 'Фармоиш',
    sender: 'Фиристанда',
    recipient: 'Гиранда',
    traveler: 'Интиқолдиҳанда (мусофир)',
    route: 'Масир',
    departure: 'Парвоз',
    items: 'Мӯҳтаво',
    category: 'Категория',
    description: 'Тавсиф',
    qty: 'Шумора',
    value: 'Арзиш (EUR)',
    total: 'Арзиши умумӣ',
    accepted: 'Аз ҷониби мусофир тасдиқ шуд',
    ruleset: 'Версияи қоидаҳо',
    hash: 'Ҳэши яклухтӣ (SHA-256)',
    disclaimer:
      'Фиристанда дурустии маълумотро тасдиқ мекунад. Мусофир танҳо мӯҳтавои эъломшударо мебарад.',
  },
};

function esc(s: string): string {
  return s.replace(
    /[&<>"]/g,
    (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]!,
  );
}

/** Rendert das Manifest als HTML (Vorlage für die PDF-Erzeugung). */
export function renderManifestHtml(manifest: Manifest, locale: Locale = 'de'): string {
  const t = LABELS[locale];
  const rows = manifest.items
    .map(
      (it) => `<tr>
        <td>${esc(it.category)}</td>
        <td>${esc(it.description)}</td>
        <td style="text-align:right">${it.quantity}</td>
        <td style="text-align:right">${(it.quantity * it.unitValueEur).toFixed(2)}</td>
      </tr>`,
    )
    .join('');

  return `<!doctype html>
<html lang="${locale}"><head><meta charset="utf-8">
<style>
  body{font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#111}
  h1{font-size:18px;margin:0 0 12px}
  .meta{margin-bottom:12px}
  table{width:100%;border-collapse:collapse;margin:12px 0}
  th,td{border:1px solid #999;padding:6px;text-align:left}
  .hash{font-family:monospace;font-size:10px;word-break:break-all}
  .disclaimer{margin-top:16px;font-size:11px;color:#444;border-top:1px solid #ccc;padding-top:8px}
</style></head>
<body>
  <h1>${t.title}</h1>
  <div class="meta">
    <strong>${t.booking}:</strong> ${esc(manifest.bookingId)}<br>
    <strong>${t.sender}:</strong> ${esc(manifest.sender.fullName)}<br>
    <strong>${t.recipient}:</strong> ${esc(manifest.recipient.fullName)} (${esc(manifest.recipient.city ?? '')})<br>
    <strong>${t.traveler}:</strong> ${esc(manifest.traveler.fullName)}<br>
    <strong>${t.route}:</strong> ${esc(manifest.trip.originAirport)} → ${esc(manifest.trip.destinationAirport)}<br>
    <strong>${t.departure}:</strong> ${esc(manifest.trip.departureAt)}
  </div>
  <h2>${t.items}</h2>
  <table>
    <thead><tr><th>${t.category}</th><th>${t.description}</th><th>${t.qty}</th><th>${t.value}</th></tr></thead>
    <tbody>${rows}</tbody>
    <tfoot><tr><td colspan="3" style="text-align:right"><strong>${t.total}</strong></td>
      <td style="text-align:right"><strong>${manifest.totalValueEur.toFixed(2)}</strong></td></tr></tfoot>
  </table>
  <div class="meta">
    <strong>${t.accepted}:</strong> ${esc(manifest.travelerAcceptedAt)}<br>
    <strong>${t.ruleset}:</strong> ${esc(manifest.rulesetVersion)}<br>
    <strong>${t.hash}:</strong> <span class="hash">${manifest.contentHash}</span>
  </div>
  <div class="disclaimer">${t.disclaimer}</div>
</body></html>`;
}
