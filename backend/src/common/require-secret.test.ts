import { describe, it, expect } from 'vitest';
import { requireSecret } from './require-secret';

describe('requireSecret', () => {
  it('gibt ein gültiges, ausreichend langes Secret zurück (getrimmt)', () => {
    expect(requireSecret('  a-very-strong-secret-123  ', 'JWT_ACCESS_SECRET')).toBe(
      'a-very-strong-secret-123',
    );
  });

  it('wirft, wenn das Secret fehlt oder leer ist', () => {
    expect(() => requireSecret(undefined, 'JWT_ACCESS_SECRET')).toThrow(/nicht gesetzt/);
    expect(() => requireSecret('', 'JWT_ACCESS_SECRET')).toThrow(/nicht gesetzt/);
    expect(() => requireSecret('   ', 'JWT_ACCESS_SECRET')).toThrow(/nicht gesetzt/);
  });

  it('wirft bei bekannten unsicheren Standardwerten (case-insensitiv)', () => {
    for (const weak of ['dev-secret-change-me', 'change-me', 'CHANGEME', 'secret']) {
      expect(() => requireSecret(weak, 'JWT_ACCESS_SECRET')).toThrow(/unsicheren Standardwert/);
    }
  });

  it('wirft, wenn das Secret zu kurz ist (< 16 Zeichen)', () => {
    expect(() => requireSecret('short-123', 'JWT_ACCESS_SECRET')).toThrow(/zu kurz/);
  });

  it('nennt den Variablennamen in der Fehlermeldung', () => {
    expect(() => requireSecret('', 'MY_TOKEN')).toThrow(/MY_TOKEN/);
  });
});
