/** Einheitliche Formatierung für Geld, Zahlen, Prozente und Daten (de-DE). */

const EUR = new Intl.NumberFormat('de-DE', {
    style: 'currency',
    currency: 'EUR',
    maximumFractionDigits: 0
});

const EUR_CENTS = new Intl.NumberFormat('de-DE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
});

const NUM = new Intl.NumberFormat('de-DE');
const DATE = new Intl.DateTimeFormat('de-DE', { day: '2-digit', month: 'short', year: 'numeric' });
const DATE_SHORT = new Intl.DateTimeFormat('de-DE', { day: '2-digit', month: 'short' });

export const formatEuro = (n: number, cents = false): string => (cents ? EUR_CENTS : EUR).format(n);
export const formatNumber = (n: number): string => NUM.format(n);
export const formatPercent = (n: number, digits = 1): string =>
    `${n > 0 ? '+' : ''}${n.toFixed(digits)}%`;
export const formatDate = (d: string | Date): string => DATE.format(new Date(d));
export const formatDateShort = (d: string | Date): string => DATE_SHORT.format(new Date(d));

/** Kompakte Geldangabe, z.B. 1,2 Mio €. */
export function formatEuroCompact(n: number): string {
    if (Math.abs(n) >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace('.', ',')} Mio €`;
    if (Math.abs(n) >= 1_000) return `${(n / 1_000).toFixed(0)} Tsd €`;
    return formatEuro(n);
}

/** Relative Zeitangabe („vor 3 Std."). */
export function timeAgo(d: string | Date): string {
    const diff = Date.now() - new Date(d).getTime();
    const m = Math.round(diff / 60000);
    if (m < 1) return 'gerade eben';
    if (m < 60) return `vor ${m} Min.`;
    const h = Math.round(m / 60);
    if (h < 24) return `vor ${h} Std.`;
    const days = Math.round(h / 24);
    if (days < 7) return `vor ${days} Tg.`;
    return formatDateShort(d);
}

export function initials(name: string): string {
    return name
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map((p) => p[0]?.toUpperCase() ?? '')
        .join('');
}
