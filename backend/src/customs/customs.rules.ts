// ─────────────────────────────────────────────────────────────────────────────
//  Prohibited-Items-Regelwerk — VERSIONIERT
//
//  Warum versioniert? Bei einem Zoll-Streit muss nachweisbar sein, WELCHE Regel
//  zum Deklarationszeitpunkt galt. Die Version wird im Manifest gespeichert.
//
//  ⚠️ Die konkreten Schwellen/Kategorien sind ILLUSTRATIV und müssen vor
//     Go-live juristisch (Zoll DE + TJ, Außenwirtschaftsrecht) verifiziert
//     werden. Tadschikische Texte vor Release nativ prüfen lassen.
// ─────────────────────────────────────────────────────────────────────────────

import type { CustomsCategory, LocalizedText, ComplianceLevel } from './customs.types';

export const RULESET_VERSION = '2026-06-01';

/** Globale zollfreie Wertgrenze (illustrativ, in EUR). */
export const GLOBAL_DUTY_FREE_EUR = 1000;

export interface CategoryRule {
  category: CustomsCategory;
  level: ComplianceLevel;
  code: string;
  reason: LocalizedText;
  /** Wert (EUR) der Position, ab dem zusätzlich gewarnt wird (Einfuhrabgaben). */
  thresholdEur?: number;
  /** Erfordert Nachweis (z.B. Rezept) — wird als zusätzliche Warnung ausgegeben. */
  requiresProof?: boolean;
}

export const CATEGORY_RULES: Readonly<Record<CustomsCategory, CategoryRule>> = {
  DOCUMENTS: {
    category: 'DOCUMENTS',
    level: 'ALLOW',
    code: 'DOCUMENTS_OK',
    reason: {
      de: 'Dokumente sind in der Regel unproblematisch.',
      ru: 'Документы обычно не вызывают проблем.',
      tg: 'Ҳуҷҷатҳо одатан мушкилӣ надоранд.',
    },
  },
  CLOTHING: {
    category: 'CLOTHING',
    level: 'ALLOW',
    code: 'CLOTHING_OK',
    reason: {
      de: 'Gebrauchte/neue Kleidung in haushaltsüblicher Menge ist meist zulässig.',
      ru: 'Одежда в бытовом количестве обычно допустима.',
      tg: 'Либос ба миқдори маишӣ одатан иҷозат дода мешавад.',
    },
  },
  FOOD_DRY: {
    category: 'FOOD_DRY',
    level: 'WARN',
    code: 'FOOD_RESTRICTED',
    reason: {
      de: 'Nur trockene, originalverpackte Lebensmittel. Keine verderbliche Ware, kein Fleisch/Milch.',
      ru: 'Только сухие продукты в заводской упаковке. Без скоропортящихся, мяса и молочных продуктов.',
      tg: 'Танҳо хӯроки хушк дар бастаи аслӣ. Маҳсулоти зудвайроншаванда, гӯшт ва шир мумкин нест.',
    },
  },
  ELECTRONICS: {
    category: 'ELECTRONICS',
    level: 'WARN',
    code: 'ELECTRONICS_DUTY',
    thresholdEur: 300,
    reason: {
      de: 'Elektronik über der Freigrenze ist in TJ einfuhrabgabenpflichtig. Kaufbeleg mitführen.',
      ru: 'Электроника сверх лимита облагается пошлиной в Таджикистане. Возьмите чек.',
      tg: 'Электроника зиёда аз ҳадди озод дар Тоҷикистон боҷ дорад. Чек гиред.',
    },
  },
  MEDICINE: {
    category: 'MEDICINE',
    level: 'WARN',
    code: 'MEDICINE_PROOF',
    requiresProof: true,
    reason: {
      de: 'Medikamente benötigen ggf. Rezept/Nachweis. Verschreibungspflichtige Stoffe können verboten sein.',
      ru: 'Для лекарств может потребоваться рецепт. Рецептурные препараты могут быть запрещены.',
      tg: 'Барои доруҳо шояд дорухат лозим бошад. Доруҳои рецептӣ мумкин аст манъ бошанд.',
    },
  },
  GIFTS: {
    category: 'GIFTS',
    level: 'WARN',
    code: 'GIFTS_VALUE',
    thresholdEur: 200,
    reason: {
      de: 'Geschenke über der Wertgrenze können abgabenpflichtig sein.',
      ru: 'Подарки сверх лимита стоимости могут облагаться пошлиной.',
      tg: 'Тӯҳфаҳои зиёда аз ҳадди арзиш мумкин аст боҷ дошта бошанд.',
    },
  },
  COSMETICS: {
    category: 'COSMETICS',
    level: 'ALLOW',
    code: 'COSMETICS_OK',
    reason: {
      de: 'Kosmetika in haushaltsüblicher Menge sind meist zulässig (Mengenbegrenzung beachten).',
      ru: 'Косметика в бытовом количестве обычно допустима (соблюдайте лимиты).',
      tg: 'Косметика ба миқдори маишӣ одатан иҷозат аст (ҳадди миқдорро риоя кунед).',
    },
  },
  OTHER: {
    category: 'OTHER',
    level: 'WARN',
    code: 'OTHER_SPECIFY',
    reason: {
      de: 'Unklassifizierte Ware: Inhalt genau beschreiben, sonst Zollrisiko.',
      ru: 'Неклассифицированный товар: точно опишите содержимое.',
      tg: 'Моли номуайян: мӯҳтаворо дақиқ тавсиф кунед.',
    },
  },
};

/** Zusatztext, wenn eine Position den Wert-Schwellenwert überschreitet. */
export const OVER_THRESHOLD_TEXT: LocalizedText = {
  de: 'Wert über der Freigrenze — Einfuhrabgaben wahrscheinlich.',
  ru: 'Стоимость выше лимита — вероятны таможенные сборы.',
  tg: 'Арзиш аз ҳадди озод зиёд — эҳтимоли боҷи гумрукӣ ҳаст.',
};

/** Zusatztext für versiegelte Pakete (Traveler kann Inhalt nicht prüfen). */
export const SEALED_WARNING_TEXT: LocalizedText = {
  de: 'Versiegelt: Der Traveler kann den Inhalt nicht prüfen — erhöhtes Zollrisiko.',
  ru: 'Запечатано: путешественник не может проверить содержимое — повышенный риск.',
  tg: 'Мӯҳршуда: мусофир мӯҳтаворо тафтиш карда наметавонад — хатари баланд.',
};

export const OVER_DUTY_FREE_TEXT: LocalizedText = {
  de: `Gesamtwert über ${GLOBAL_DUTY_FREE_EUR} € — Verzollung sehr wahrscheinlich.`,
  ru: `Общая стоимость выше ${GLOBAL_DUTY_FREE_EUR} € — растаможка весьма вероятна.`,
  tg: `Арзиши умумӣ зиёда аз ${GLOBAL_DUTY_FREE_EUR} € — гумрук эҳтимоли калон дорад.`,
};

// ── Harte Sperrliste: Schlüsselwörter im Beschreibungstext (mehrsprachig) ─────
// Bei Treffer wird die Position auf BLOCK gesetzt — kein Transport möglich.
export interface BlocklistEntry {
  code: string;
  keywords: string[]; // lowercase, Substring-Match
  reason: LocalizedText;
}

export const BLOCKLIST: ReadonlyArray<BlocklistEntry> = [
  {
    code: 'BLOCK_WEAPONS',
    keywords: ['waffe', 'weapon', 'gun', 'pistol', 'munition', 'ammo', 'оружие', 'патрон', 'силоҳ'],
    reason: {
      de: 'Waffen, Waffenteile und Munition sind strikt verboten.',
      ru: 'Оружие, его части и боеприпасы строго запрещены.',
      tg: 'Силоҳ, қисмҳои он ва лавозимоти ҷангӣ қатъиян манъ аст.',
    },
  },
  {
    code: 'BLOCK_DRUGS',
    keywords: ['drogen', 'drug', 'narcot', 'kokain', 'cocaine', 'heroin', 'cannabis', 'marij', 'наркот'],
    reason: {
      de: 'Betäubungsmittel/Drogen sind strikt verboten.',
      ru: 'Наркотические средства строго запрещены.',
      tg: 'Маводи мухаддир қатъиян манъ аст.',
    },
  },
  {
    code: 'BLOCK_EXPLOSIVES',
    keywords: ['spreng', 'explos', 'feuerwerk', 'firework', 'взрыв', 'таркиш'],
    reason: {
      de: 'Spreng-/Explosivstoffe und Feuerwerk sind verboten.',
      ru: 'Взрывчатые вещества и пиротехника запрещены.',
      tg: 'Маводи тарканда ва пиротехника манъ аст.',
    },
  },
  {
    code: 'BLOCK_CASH',
    keywords: ['bargeld', 'cash', 'banknote', 'наличны', 'пули нақд'],
    reason: {
      de: 'Bargeldtransport für Dritte ist nicht erlaubt (Geldwäsche-/Deklarationsrisiko).',
      ru: 'Перевозка наличных для третьих лиц не допускается.',
      tg: 'Интиқоли пули нақд барои шахсони сеюм иҷозат нест.',
    },
  },
];
