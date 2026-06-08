import { describe, it, expect } from 'vitest';
import { PdfKitManifestRenderer } from './pdfkit-renderer';
import { buildManifest } from '../customs/manifest';
import { CustomsService } from '../customs/customs.service';
import type { DeclarationItemInput } from '../customs/customs.types';

const svc = new CustomsService();
const renderer = new PdfKitManifestRenderer();

const items: DeclarationItemInput[] = [
  {
    category: 'CLOTHING',
    description: 'Winterjacke',
    quantity: 2,
    unitValueEur: 45,
    isSealed: false,
  },
  {
    category: 'GIFTS',
    description: 'Чойник (Teekanne)',
    quantity: 1,
    unitValueEur: 30,
    isSealed: false,
  },
];

function manifest() {
  return buildManifest({
    bookingId: 'bk_pdf',
    sender: { fullName: 'Anvar S.', city: 'Berlin' },
    recipient: { fullName: 'Фируза Р.', city: 'Душанбе' },
    traveler: { fullName: 'Karim T.' },
    trip: { originAirport: 'FRA', destinationAirport: 'DYU', departureAt: '2026-07-01T10:00:00Z' },
    items,
    declaration: svc.evaluate(items),
    travelerAcceptedAt: '2026-06-20T09:00:00Z',
    generatedAt: '2026-06-20T09:05:00Z',
  });
}

describe('PdfKitManifestRenderer', () => {
  it('erzeugt ein gültiges PDF (Magic Bytes + Inhalt)', async () => {
    const pdf = await renderer.render(manifest(), 'de');
    expect(pdf.length).toBeGreaterThan(1000);
    expect(pdf.subarray(0, 5).toString('latin1')).toBe('%PDF-');
    expect(pdf.subarray(-6).toString('latin1')).toContain('EOF');
  });

  it('rendert auch kyrillische Locales ohne Fehler', async () => {
    const ru = await renderer.render(manifest(), 'ru');
    const tg = await renderer.render(manifest(), 'tg');
    expect(ru.subarray(0, 5).toString('latin1')).toBe('%PDF-');
    expect(tg.subarray(0, 5).toString('latin1')).toBe('%PDF-');
  });
});
