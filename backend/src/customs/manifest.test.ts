import { describe, it, expect } from 'vitest';
import {
  buildManifest,
  verifyManifest,
  renderManifestHtml,
  type BuildManifestInput,
} from './manifest';
import { CustomsService } from './customs.service';
import type { DeclarationItemInput } from './customs.types';

const svc = new CustomsService();

const items: DeclarationItemInput[] = [
  {
    category: 'CLOTHING',
    description: 'Winterjacke',
    quantity: 2,
    unitValueEur: 50,
    isSealed: false,
  },
  { category: 'GIFTS', description: 'Tee-Set', quantity: 1, unitValueEur: 30, isSealed: false },
];

function baseInput(): BuildManifestInput {
  return {
    bookingId: 'bk_42',
    sender: { fullName: 'Anvar S.', city: 'Berlin' },
    recipient: { fullName: 'Firuza R.', city: 'Dushanbe', phone: '+992...' },
    traveler: { fullName: 'Karim T.' },
    trip: { originAirport: 'FRA', destinationAirport: 'DYU', departureAt: '2026-07-01T10:00:00Z' },
    items,
    declaration: svc.evaluate(items),
    travelerAcceptedAt: '2026-06-20T09:00:00Z',
    generatedAt: '2026-06-20T09:05:00Z',
  };
}

describe('buildManifest', () => {
  it('erstellt ein Manifest mit deterministischem Hash', () => {
    const m1 = buildManifest(baseInput());
    const m2 = buildManifest(baseInput());
    expect(m1.contentHash).toHaveLength(64);
    expect(m1.contentHash).toBe(m2.contentHash); // deterministisch
  });

  it('verweigert Manifest für BLOCK-Deklaration', () => {
    const blocked = [
      {
        category: 'OTHER' as const,
        description: 'Waffe',
        quantity: 1,
        unitValueEur: 0,
        isSealed: false,
      },
    ];
    const input = { ...baseInput(), items: blocked, declaration: svc.evaluate(blocked) };
    expect(() => buildManifest(input)).toThrow(/BLOCK/);
  });
});

describe('verifyManifest', () => {
  it('bestätigt ein unverändertes Manifest', () => {
    const m = buildManifest(baseInput());
    expect(verifyManifest(m)).toBe(true);
  });

  it('erkennt Manipulation am Inhalt', () => {
    const m = buildManifest(baseInput());
    const tampered = { ...m, totalValueEur: 1 };
    expect(verifyManifest(tampered)).toBe(false);
  });
});

describe('renderManifestHtml', () => {
  it('rendert HTML inkl. Hash und Items', () => {
    const m = buildManifest(baseInput());
    const html = renderManifestHtml(m, 'de');
    expect(html).toContain(m.contentHash);
    expect(html).toContain('Winterjacke');
    expect(html).toContain('Frachtmanifest');
  });

  it('rendert tadschikische Labels', () => {
    const html = renderManifestHtml(buildManifest(baseInput()), 'tg');
    expect(html).toContain('Манифести бор');
  });

  it('escaped HTML-Sonderzeichen in Beschreibungen', () => {
    const evil: DeclarationItemInput[] = [
      {
        category: 'OTHER',
        description: 'T-Shirt <script>x</script> & co',
        quantity: 1,
        unitValueEur: 10,
        isSealed: false,
      },
    ];
    const input = { ...baseInput(), items: evil, declaration: svc.evaluate(evil) };
    const html = renderManifestHtml(buildManifest(input), 'de');
    expect(html).not.toContain('<script>');
    expect(html).toContain('&lt;script&gt;');
  });
});
