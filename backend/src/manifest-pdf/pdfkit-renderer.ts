// ─────────────────────────────────────────────────────────────────────────────
//  PdfKitManifestRenderer — erzeugt das Zoll-Manifest-PDF programmatisch.
//
//  Kein Browser nötig. DejaVu-Font wird eingebettet (deckt Lateinisch +
//  Kyrillisch ab → korrekte Darstellung von Russisch/Tadschikisch).
// ─────────────────────────────────────────────────────────────────────────────

import { join } from 'node:path';
import PDFDocument from 'pdfkit';
import type { ManifestPdfRenderer } from './pdf-renderer';
import type { Manifest } from '../customs/manifest';
import type { Locale } from '../customs/customs.types';

const LABELS: Record<Locale, Record<string, string>> = {
  de: {
    title: 'Frachtmanifest / Zoll-Deklaration',
    booking: 'Buchung',
    sender: 'Absender',
    recipient: 'Empfänger',
    traveler: 'Transporteur',
    route: 'Route',
    departure: 'Abflug',
    category: 'Kategorie',
    description: 'Beschreibung',
    qty: 'Menge',
    value: 'Wert (EUR)',
    total: 'Gesamtwert',
    accepted: 'Bestätigt vom Reisenden am',
    ruleset: 'Regelwerk',
    hash: 'Integritäts-Hash (SHA-256)',
    disclaimer:
      'Der Absender bestätigt die Richtigkeit dieser Angaben. Der Reisende befördert ausschließlich den deklarierten Inhalt.',
  },
  ru: {
    title: 'Грузовой манифест / Таможенная декларация',
    booking: 'Бронирование',
    sender: 'Отправитель',
    recipient: 'Получатель',
    traveler: 'Перевозчик',
    route: 'Маршрут',
    departure: 'Вылет',
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
    traveler: 'Интиқолдиҳанда',
    route: 'Масир',
    departure: 'Парвоз',
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

export interface PdfKitRendererOptions {
  /** Verzeichnis mit DejaVuSans.ttf / DejaVuSans-Bold.ttf. */
  fontDir?: string;
}

export class PdfKitManifestRenderer implements ManifestPdfRenderer {
  private readonly fontRegular: string;
  private readonly fontBold: string;

  constructor(opts: PdfKitRendererOptions = {}) {
    const dir = opts.fontDir ?? join(process.cwd(), 'assets', 'fonts');
    this.fontRegular = join(dir, 'DejaVuSans.ttf');
    this.fontBold = join(dir, 'DejaVuSans-Bold.ttf');
  }

  render(manifest: Manifest, locale: Locale): Promise<Buffer> {
    const t = LABELS[locale];
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    doc.registerFont('body', this.fontRegular);
    doc.registerFont('bold', this.fontBold);

    const chunks: Buffer[] = [];
    const done = new Promise<Buffer>((resolve, reject) => {
      doc.on('data', (c: Buffer) => chunks.push(c));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);
    });

    // Kopf
    doc.font('bold').fontSize(18).text(t.title);
    doc.moveDown(0.5);
    doc.font('body').fontSize(10);

    const line = (label: string, val: string) =>
      doc.font('bold').text(`${label}: `, { continued: true }).font('body').text(val);

    line(t.booking, manifest.bookingId);
    line(t.sender, manifest.sender.fullName);
    line(
      t.recipient,
      `${manifest.recipient.fullName}${manifest.recipient.city ? ` (${manifest.recipient.city})` : ''}`,
    );
    line(t.traveler, manifest.traveler.fullName);
    line(t.route, `${manifest.trip.originAirport} → ${manifest.trip.destinationAirport}`);
    line(t.departure, manifest.trip.departureAt);
    doc.moveDown(0.8);

    // Tabelle
    const cols = { cat: 50, desc: 160, qty: 380, val: 450 };
    const header = (y: number) => {
      doc.font('bold').fontSize(10);
      doc.text(t.category, cols.cat, y);
      doc.text(t.description, cols.desc, y);
      doc.text(t.qty, cols.qty, y, { width: 50, align: 'right' });
      doc.text(t.value, cols.val, y, { width: 90, align: 'right' });
      doc
        .moveTo(50, y + 14)
        .lineTo(545, y + 14)
        .stroke();
    };
    let y = doc.y;
    header(y);
    y += 20;
    doc.font('body').fontSize(10);
    for (const it of manifest.items) {
      doc.text(it.category, cols.cat, y, { width: 105 });
      doc.text(it.description, cols.desc, y, { width: 215 });
      doc.text(String(it.quantity), cols.qty, y, { width: 50, align: 'right' });
      doc.text((it.quantity * it.unitValueEur).toFixed(2), cols.val, y, {
        width: 90,
        align: 'right',
      });
      y += 20;
      if (y > 720) {
        doc.addPage();
        y = 50;
        header(y);
        y += 20;
      }
    }
    doc.moveTo(50, y).lineTo(545, y).stroke();
    y += 6;
    doc.font('bold').text(t.total, cols.qty - 100, y, { width: 200, align: 'right' });
    doc.text(manifest.totalValueEur.toFixed(2), cols.val, y, { width: 90, align: 'right' });
    doc.moveDown(2);

    // Fuß: Zustimmung, Regelwerk, Hash, Haftungshinweis
    doc.font('body').fontSize(9);
    doc.x = 50;
    line(t.accepted, manifest.travelerAcceptedAt);
    line(t.ruleset, manifest.rulesetVersion);
    doc.font('bold').text(`${t.hash}:`);
    doc.font('body').fontSize(8).text(manifest.contentHash);
    doc.moveDown(1);
    doc.fontSize(9).fillColor('#444').text(t.disclaimer, { align: 'left' });

    doc.end();
    return done;
  }
}
