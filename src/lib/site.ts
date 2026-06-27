/** Zentrale Seiten-Metadaten + Basis-Pfad-Helfer (für GitHub Pages Unterpfad). */
export const SITE = {
    name: 'Meridian Fund',
    tagline: 'Internationale Fonds-Verwaltung',
    description:
        'Meridian — die offizielle Verwaltungsplattform unseres internationalen Fonds. Mitglieder, Beiträge, Auszahlungen und Berichte in einer vertrauenswürdigen, modernen Oberfläche.',
    url: 'https://sikotjk.github.io/astro-platform-starter',
    locale: 'de_DE'
} as const;

const RAW_BASE = import.meta.env.BASE_URL || '/';

/** Hängt den Deploy-Basispfad an einen internen Pfad an (GitHub Pages Unterordner). */
export function withBase(path: string): string {
    const base = RAW_BASE.endsWith('/') ? RAW_BASE.slice(0, -1) : RAW_BASE;
    const clean = path.startsWith('/') ? path : `/${path}`;
    return `${base}${clean}` || '/';
}

/** Prüft, ob `href` dem aktuellen Pfad entspricht (für aktive Navigation). */
export function isActivePath(current: string, href: string): boolean {
    const norm = (p: string) => {
        const noBase = p.startsWith(RAW_BASE) ? p.slice(RAW_BASE.length - 1) : p;
        return ('/' + noBase.replace(/^\/+|\/+$/g, '')).toLowerCase();
    };
    const c = norm(current);
    const h = norm(href);
    if (h === '/') return c === '/';
    return c === h || c.startsWith(h + '/');
}
