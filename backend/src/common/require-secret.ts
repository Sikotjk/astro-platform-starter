/**
 * Erzwingt, dass ein sicherheitskritisches Secret beim Boot gesetzt und nicht
 * ein bekannter Platzhalter ist. Reine Funktion → leicht testbar.
 *
 * Wirft beim Start (fail-fast), damit die App nie versehentlich mit einem
 * Default-/Dev-Secret in Produktion läuft.
 */
const WEAK_DEFAULTS = new Set([
  'dev-secret-change-me',
  'change-me',
  'changeme',
  'secret',
  'changethis',
  'your-secret-here',
]);

const MIN_LENGTH = 16;

export function requireSecret(value: string | undefined, name: string): string {
  const v = (value ?? '').trim();
  if (v.length === 0) {
    throw new Error(
      `${name} ist nicht gesetzt. Bitte eine starke, zufällige Zeichenkette in der Umgebung setzen.`,
    );
  }
  if (WEAK_DEFAULTS.has(v.toLowerCase())) {
    throw new Error(
      `${name} verwendet einen unsicheren Standardwert. Bitte ein eigenes, zufälliges Secret setzen.`,
    );
  }
  if (v.length < MIN_LENGTH) {
    throw new Error(
      `${name} ist zu kurz (min. ${MIN_LENGTH} Zeichen). Bitte ein längeres, zufälliges Secret setzen.`,
    );
  }
  return v;
}
