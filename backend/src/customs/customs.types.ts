// Typen der Zoll-/Compliance-Domäne (framework-unabhängig).

export type CustomsCategory =
  | 'DOCUMENTS'
  | 'CLOTHING'
  | 'FOOD_DRY'
  | 'ELECTRONICS'
  | 'MEDICINE'
  | 'GIFTS'
  | 'COSMETICS'
  | 'OTHER';

export type Locale = 'de' | 'ru' | 'tg';

/** Mehrsprachiger Text. Tadschikisch (Cyrillic) — vor Go-live nativ prüfen lassen. */
export type LocalizedText = Record<Locale, string>;

/** Entscheidungsstufe pro Item bzw. für die Gesamtdeklaration. */
export type ComplianceLevel = 'ALLOW' | 'WARN' | 'BLOCK';

/** Ein Posten der Deklaration, wie ihn der Sender erfasst. */
export interface DeclarationItemInput {
  category: CustomsCategory;
  description: string;
  quantity: number;
  unitValueEur: number; // Euro (Dezimal) — UI-Eingabe
  isSealed: boolean;
}

/** Befund zu einem einzelnen Item. */
export interface ItemFinding {
  index: number;
  category: CustomsCategory;
  level: ComplianceLevel;
  /** Lokalisierte, dem Nutzer anzeigbare Begründungen (kann mehrere sein). */
  messages: string[];
  /** Maschinencodes der ausgelösten Regeln (z.B. "MEDICINE_PROOF"). */
  codes: string[];
}

/** Gesamtergebnis der Deklarationsprüfung. */
export interface DeclarationResult {
  rulesetVersion: string;
  level: ComplianceLevel; // höchste Stufe über alle Items + globale Regeln
  findings: ItemFinding[];
  /** Globale (nicht item-spezifische) Hinweise, z.B. Wert über Freigrenze. */
  globalMessages: string[];
  totalValueEur: number;
  /** Darf das Booking ins Compliance-Gate (customsDeclared=true)? Nur wenn !BLOCK. */
  declarable: boolean;
}
