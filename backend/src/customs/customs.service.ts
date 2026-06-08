// ─────────────────────────────────────────────────────────────────────────────
//  CustomsService — prüft die Zoll-Deklaration eines Pakets gegen das Regelwerk
//
//  Output: DeclarationResult mit Gesamtstufe (ALLOW/WARN/BLOCK), Item-Befunden
//  und lokalisierten Texten. Nur wenn NICHT BLOCK ist `declarable=true` —
//  daran hängt das Compliance-Gate (PAID → HANDED_OVER) aus Schritt 2/3.
// ─────────────────────────────────────────────────────────────────────────────

import {
  CATEGORY_RULES,
  BLOCKLIST,
  RULESET_VERSION,
  GLOBAL_DUTY_FREE_EUR,
  OVER_THRESHOLD_TEXT,
  SEALED_WARNING_TEXT,
  OVER_DUTY_FREE_TEXT,
} from './customs.rules';
import type {
  DeclarationItemInput,
  DeclarationResult,
  ItemFinding,
  Locale,
  ComplianceLevel,
} from './customs.types';

const SEVERITY: Record<ComplianceLevel, number> = { ALLOW: 0, WARN: 1, BLOCK: 2 };

function maxLevel(a: ComplianceLevel, b: ComplianceLevel): ComplianceLevel {
  return SEVERITY[a] >= SEVERITY[b] ? a : b;
}

export class CustomsValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'CustomsValidationError';
  }
}

export class CustomsService {
  /**
   * Prüft die Item-Liste. `locale` bestimmt die Sprache der zurückgegebenen
   * Texte. Wirft bei strukturell ungültiger Eingabe (leer, negative Werte).
   */
  evaluate(items: DeclarationItemInput[], locale: Locale = 'de'): DeclarationResult {
    if (!items || items.length === 0) {
      throw new CustomsValidationError('Deklaration enthält keine Positionen.');
    }

    const findings: ItemFinding[] = [];
    let overall: ComplianceLevel = 'ALLOW';
    let totalValueEur = 0;

    items.forEach((item, index) => {
      this.assertItemValid(item, index);

      const positionValue = round2(item.quantity * item.unitValueEur);
      totalValueEur = round2(totalValueEur + positionValue);

      const messages: string[] = [];
      const codes: string[] = [];
      let level: ComplianceLevel = 'ALLOW';

      // 1) Harte Sperrliste (Beschreibungstext scannen) -> BLOCK
      const haystack = item.description.toLowerCase();
      for (const entry of BLOCKLIST) {
        if (entry.keywords.some((k) => haystack.includes(k))) {
          level = maxLevel(level, 'BLOCK');
          messages.push(entry.reason[locale]);
          codes.push(entry.code);
        }
      }

      // 2) Kategorie-Regel
      const rule = CATEGORY_RULES[item.category];
      level = maxLevel(level, rule.level);
      messages.push(rule.reason[locale]);
      codes.push(rule.code);

      // 2a) Nachweispflicht (z.B. Rezept)
      if (rule.requiresProof) codes.push(`${rule.code}_PROOF_REQUIRED`);

      // 2b) Wert-Schwelle der Kategorie überschritten
      if (rule.thresholdEur !== undefined && positionValue > rule.thresholdEur) {
        level = maxLevel(level, 'WARN');
        messages.push(OVER_THRESHOLD_TEXT[locale]);
        codes.push(`${rule.code}_OVER_THRESHOLD`);
      }

      // 3) Versiegelt -> Warnung (Traveler kann Inhalt nicht prüfen)
      if (item.isSealed) {
        level = maxLevel(level, 'WARN');
        messages.push(SEALED_WARNING_TEXT[locale]);
        codes.push('SEALED');
      }

      overall = maxLevel(overall, level);
      findings.push({ index, category: item.category, level, messages, codes });
    });

    // 4) Globale Regel: Gesamtwert über zollfreier Grenze
    const globalMessages: string[] = [];
    if (totalValueEur > GLOBAL_DUTY_FREE_EUR) {
      overall = maxLevel(overall, 'WARN');
      globalMessages.push(OVER_DUTY_FREE_TEXT[locale]);
    }

    return {
      rulesetVersion: RULESET_VERSION,
      level: overall,
      findings,
      globalMessages,
      totalValueEur,
      declarable: overall !== 'BLOCK',
    };
  }

  private assertItemValid(item: DeclarationItemInput, index: number): void {
    if (!item.description || item.description.trim().length < 3) {
      throw new CustomsValidationError(`Position ${index}: Beschreibung ist zu kurz.`);
    }
    if (!Number.isFinite(item.quantity) || item.quantity < 1) {
      throw new CustomsValidationError(`Position ${index}: Menge muss >= 1 sein.`);
    }
    if (!Number.isFinite(item.unitValueEur) || item.unitValueEur < 0) {
      throw new CustomsValidationError(`Position ${index}: Wert darf nicht negativ sein.`);
    }
  }
}

function round2(n: number): number {
  return Math.round((n + Number.EPSILON) * 100) / 100;
}
