import { describe, it, expect } from 'vitest';
import { CustomsService, CustomsValidationError } from './customs.service';
import type { DeclarationItemInput } from './customs.types';

const svc = new CustomsService();

const item = (over: Partial<DeclarationItemInput> = {}): DeclarationItemInput => ({
  category: 'CLOTHING',
  description: 'Gebrauchte Winterjacke',
  quantity: 1,
  unitValueEur: 40,
  isSealed: false,
  ...over,
});

describe('Grundentscheidungen', () => {
  it('ALLOW bei unkritischer Kleidung', () => {
    const r = svc.evaluate([item()]);
    expect(r.level).toBe('ALLOW');
    expect(r.declarable).toBe(true);
  });

  it('WARN bei Medikamenten (Nachweispflicht)', () => {
    const r = svc.evaluate([item({ category: 'MEDICINE', description: 'Schmerztabletten' })]);
    expect(r.level).toBe('WARN');
    expect(r.findings[0].codes).toContain('MEDICINE_PROOF_PROOF_REQUIRED');
    expect(r.declarable).toBe(true);
  });

  it('WARN bei Elektronik über Wertgrenze', () => {
    const r = svc.evaluate([item({ category: 'ELECTRONICS', description: 'Laptop', unitValueEur: 800 })]);
    expect(r.level).toBe('WARN');
    expect(r.findings[0].codes).toContain('ELECTRONICS_DUTY_OVER_THRESHOLD');
  });

  it('Elektronik unter Wertgrenze warnt nur kategorienbedingt, aber nicht über Schwelle', () => {
    const r = svc.evaluate([item({ category: 'ELECTRONICS', description: 'Kopfhörer', unitValueEur: 50 })]);
    expect(r.findings[0].codes).not.toContain('ELECTRONICS_DUTY_OVER_THRESHOLD');
  });
});

describe('Harte Sperrliste -> BLOCK', () => {
  it('blockt Waffen', () => {
    const r = svc.evaluate([item({ description: 'Antike Waffe als Deko' })]);
    expect(r.level).toBe('BLOCK');
    expect(r.declarable).toBe(false);
    expect(r.findings[0].codes).toContain('BLOCK_WEAPONS');
  });

  it('blockt Bargeld', () => {
    const r = svc.evaluate([item({ category: 'OTHER', description: 'Umschlag mit Bargeld' })]);
    expect(r.level).toBe('BLOCK');
    expect(r.declarable).toBe(false);
  });

  it('erkennt Keywords sprachübergreifend (russisch)', () => {
    const r = svc.evaluate([item({ description: 'наркотики' })]);
    expect(r.findings[0].codes).toContain('BLOCK_DRUGS');
  });
});

describe('Versiegelt & Gesamtwert', () => {
  it('warnt bei versiegeltem Paket', () => {
    const r = svc.evaluate([item({ isSealed: true })]);
    expect(r.level).toBe('WARN');
    expect(r.findings[0].codes).toContain('SEALED');
  });

  it('warnt bei Gesamtwert über zollfreier Grenze', () => {
    const r = svc.evaluate([item({ category: 'GIFTS', description: 'Schmuck', quantity: 1, unitValueEur: 1200 })]);
    expect(r.globalMessages.length).toBeGreaterThan(0);
    expect(r.totalValueEur).toBe(1200);
  });
});

describe('Lokalisierung', () => {
  it('liefert tadschikische Texte', () => {
    const r = svc.evaluate([item({ category: 'MEDICINE', description: 'Доруҳо' })], 'tg');
    expect(r.findings[0].messages.join(' ')).toMatch(/[Ѐ-ӿ]/); // Cyrillic
  });
});

describe('Eingabevalidierung', () => {
  it('wirft bei leerer Liste', () => {
    expect(() => svc.evaluate([])).toThrow(CustomsValidationError);
  });
  it('wirft bei zu kurzer Beschreibung', () => {
    expect(() => svc.evaluate([item({ description: 'x' })])).toThrow(/Beschreibung/);
  });
  it('wirft bei negativem Wert', () => {
    expect(() => svc.evaluate([item({ unitValueEur: -5 })])).toThrow(/negativ/);
  });
});
