import { z } from 'zod';

/* ============================================================
   Schemas — strikt typisierte Domänenmodelle (Zod).
   ============================================================ */
export const MemberRole = z.enum(['Administrator', 'Treasurer', 'Auditor', 'Member']);
export const MemberStatus = z.enum(['active', 'pending', 'inactive']);

export const memberSchema = z.object({
    id: z.string(),
    name: z.string(),
    email: z.string().email(),
    country: z.string(),
    flag: z.string(),
    role: MemberRole,
    status: MemberStatus,
    contributed: z.number().nonnegative(),
    outstanding: z.number().nonnegative(),
    joined: z.string(),
    lastActive: z.string()
});
export type Member = z.infer<typeof memberSchema>;

export const paymentSchema = z.object({
    id: z.string(),
    member: z.string(),
    flag: z.string(),
    type: z.enum(['contribution', 'payout', 'fee']),
    amount: z.number(),
    method: z.enum(['SEPA', 'Card', 'Wire', 'Wallet']),
    status: z.enum(['settled', 'processing', 'failed']),
    date: z.string(),
    reference: z.string()
});
export type Payment = z.infer<typeof paymentSchema>;

export const activitySchema = z.object({
    id: z.string(),
    kind: z.enum(['member', 'payment', 'report', 'security', 'system']),
    title: z.string(),
    detail: z.string(),
    at: z.string()
});
export type Activity = z.infer<typeof activitySchema>;

/* ============================================================
   Mock-Daten
   ============================================================ */
const FIRST = ['Anvar', 'Dilnoza', 'Karim', 'Madina', 'Sunnatullo', 'Gulnora', 'Rustam', 'Sabina', 'Jahongir', 'Nilufar', 'Bobur', 'Zarina', 'Timur', 'Malika', 'Sherzod', 'Oysha', 'Farrukh', 'Kamila', 'Davron', 'Sevara'];
const LAST = ['Karimov', 'Yusupova', 'Rahimov', 'Tosheva', 'Siyakhakov', 'Ergasheva', 'Nazarov', 'Mirzo', 'Saidova', 'Abdullaev', 'Komilova', 'Usmonov', 'Aliyeva', 'Sharipov', 'Ismoilova'];
const COUNTRIES: [string, string][] = [
    ['Deutschland', '🇩🇪'], ['Tadschikistan', '🇹🇯'], ['Usbekistan', '🇺🇿'], ['Russland', '🇷🇺'],
    ['Türkei', '🇹🇷'], ['Kasachstan', '🇰🇿'], ['VAE', '🇦🇪'], ['USA', '🇺🇸']
];
const ROLES = ['Member', 'Member', 'Member', 'Member', 'Treasurer', 'Auditor', 'Administrator'] as const;
const STATUS = ['active', 'active', 'active', 'pending', 'inactive'] as const;

// Deterministischer Pseudo-Zufall (stabil über Builds, kein Date.now()).
function rng(seed: number) {
    let s = seed % 2147483647;
    if (s <= 0) s += 2147483646;
    return () => (s = (s * 16807) % 2147483647) / 2147483647;
}

const DAY = 86400000;
const EPOCH = Date.UTC(2026, 5, 27); // fester Bezugspunkt für stabile Daten

function daysAgo(n: number): string {
    return new Date(EPOCH - n * DAY).toISOString();
}

export const members: Member[] = Array.from({ length: 48 }, (_, i) => {
    const r = rng(i + 7);
    const first = FIRST[Math.floor(r() * FIRST.length)];
    const last = LAST[Math.floor(r() * LAST.length)];
    const [country, flag] = COUNTRIES[Math.floor(r() * COUNTRIES.length)];
    const role = ROLES[Math.floor(r() * ROLES.length)];
    const status = STATUS[Math.floor(r() * STATUS.length)];
    const contributed = Math.round((600 + r() * 9400) / 50) * 50;
    const outstanding = r() > 0.7 ? Math.round((r() * 600) / 25) * 25 : 0;
    return {
        id: `MBR-${(1000 + i).toString()}`,
        name: `${first} ${last}`,
        email: `${first}.${last}`.toLowerCase().replace(/[^a-z.]/g, '') + '@meridian.fund',
        country,
        flag,
        role,
        status,
        contributed,
        outstanding,
        joined: daysAgo(Math.floor(30 + r() * 700)),
        lastActive: daysAgo(Math.floor(r() * 20))
    };
});

const METHODS = ['SEPA', 'Card', 'Wire', 'Wallet'] as const;
const PSTATUS = ['settled', 'settled', 'settled', 'processing', 'failed'] as const;

export const payments: Payment[] = Array.from({ length: 60 }, (_, i) => {
    const r = rng(i + 101);
    const m = members[Math.floor(r() * members.length)];
    const typeRoll = r();
    const type = typeRoll > 0.86 ? 'payout' : typeRoll > 0.78 ? 'fee' : 'contribution';
    const base = type === 'payout' ? -(500 + r() * 4000) : type === 'fee' ? -(20 + r() * 60) : 100 + r() * 1500;
    return {
        id: `TXN-${(50230 + i).toString()}`,
        member: m.name,
        flag: m.flag,
        type,
        amount: Math.round(base / 5) * 5,
        method: METHODS[Math.floor(r() * METHODS.length)],
        status: PSTATUS[Math.floor(r() * PSTATUS.length)],
        date: daysAgo(Math.floor(r() * 90)),
        reference: `REF-${Math.floor(r() * 900000 + 100000)}`
    };
}).sort((a, b) => +new Date(b.date) - +new Date(a.date));

export const activity: Activity[] = [
    { id: 'a1', kind: 'payment', title: 'Beitrag eingegangen', detail: 'Dilnoza Yusupova · 1.250 €', at: daysAgo(0) },
    { id: 'a2', kind: 'member', title: 'Neues Mitglied bestätigt', detail: 'Jahongir Nazarov · 🇹🇯', at: daysAgo(0) },
    { id: 'a3', kind: 'report', title: 'Monatsbericht Mai erstellt', detail: 'Automatischer Export · PDF', at: daysAgo(1) },
    { id: 'a4', kind: 'security', title: 'Neue Sitzung autorisiert', detail: 'Treasurer · 2-Faktor bestätigt', at: daysAgo(1) },
    { id: 'a5', kind: 'payment', title: 'Auszahlung freigegeben', detail: 'Rustam Nazarov · 3.000 €', at: daysAgo(2) },
    { id: 'a6', kind: 'system', title: 'Backup abgeschlossen', detail: 'Verschlüsselt · 11:00 UTC', at: daysAgo(2) },
    { id: 'a7', kind: 'member', title: 'Rolle aktualisiert', detail: 'Sabina Saidova → Auditor', at: daysAgo(3) }
];

/** 12-Monats-Verlauf für Fondsvolumen & Mitglieder. */
export const monthly = [
    { m: 'Jul', volume: 184000, members: 21, inflow: 24000, outflow: 9000 },
    { m: 'Aug', volume: 203000, members: 24, inflow: 28000, outflow: 9000 },
    { m: 'Sep', volume: 229000, members: 27, inflow: 33000, outflow: 7000 },
    { m: 'Okt', volume: 261000, members: 31, inflow: 39000, outflow: 7000 },
    { m: 'Nov', volume: 288000, members: 34, inflow: 35000, outflow: 8000 },
    { m: 'Dez', volume: 332000, members: 37, inflow: 52000, outflow: 8000 },
    { m: 'Jan', volume: 358000, members: 39, inflow: 34000, outflow: 8000 },
    { m: 'Feb', volume: 389000, members: 41, inflow: 39000, outflow: 8000 },
    { m: 'Mär', volume: 421000, members: 43, inflow: 40000, outflow: 8000 },
    { m: 'Apr', volume: 458000, members: 45, inflow: 45000, outflow: 8000 },
    { m: 'Mai', volume: 496000, members: 47, inflow: 46000, outflow: 8000 },
    { m: 'Jun', volume: 542000, members: 48, inflow: 54000, outflow: 8000 }
];

/** Mittelverwendung (Donut). */
export const allocation = [
    { label: 'Reserve', value: 42, color: '#4f46e5' },
    { label: 'Auszahlungen', value: 28, color: '#059669' },
    { label: 'Projekte', value: 18, color: '#2563eb' },
    { label: 'Betrieb', value: 12, color: '#8b5cf6' }
];

/** Audit-Log (Admin). */
export const auditLog = [
    { id: 'L-9001', actor: 'Anvar Karimov', role: 'Administrator', action: 'Rolle geändert', target: 'Sabina Saidova → Auditor', at: daysAgo(3), ip: '85.214.x.x' },
    { id: 'L-9000', actor: 'System', role: 'System', action: 'Backup erstellt', target: 'verschlüsselt', at: daysAgo(2), ip: '—' },
    { id: 'L-8999', actor: 'Madina Tosheva', role: 'Treasurer', action: 'Auszahlung freigegeben', target: 'TXN-50231 · 3.000 €', at: daysAgo(2), ip: '91.10.x.x' },
    { id: 'L-8998', actor: 'Karim Rahimov', role: 'Auditor', action: 'Bericht exportiert', target: 'Mai 2026 · PDF', at: daysAgo(1), ip: '188.40.x.x' },
    { id: 'L-8997', actor: 'Anvar Karimov', role: 'Administrator', action: 'Mitglied eingeladen', target: 'jahongir.nazarov@…', at: daysAgo(1), ip: '85.214.x.x' }
];

/** Rollen & Berechtigungen (Admin). */
export const roles = [
    { name: 'Administrator', members: 2, permissions: ['Voller Zugriff', 'Rollen verwalten', 'Einstellungen', 'Audit-Log'], color: '#4f46e5' },
    { name: 'Treasurer', members: 3, permissions: ['Zahlungen', 'Auszahlungen freigeben', 'Berichte'], color: '#059669' },
    { name: 'Auditor', members: 4, permissions: ['Lesezugriff', 'Berichte', 'Audit-Log'], color: '#2563eb' },
    { name: 'Member', members: 39, permissions: ['Eigenes Profil', 'Eigene Beiträge'], color: '#8b5cf6' }
];

/* ============================================================
   Abgeleitete Kennzahlen (KPIs)
   ============================================================ */
export const kpis = (() => {
    const totalVolume = monthly[monthly.length - 1].volume;
    const prevVolume = monthly[monthly.length - 2].volume;
    const activeMembers = members.filter((m) => m.status === 'active').length;
    const outstanding = members.reduce((s, m) => s + m.outstanding, 0);
    const monthInflow = monthly[monthly.length - 1].inflow;
    return {
        totalVolume,
        volumeChange: ((totalVolume - prevVolume) / prevVolume) * 100,
        activeMembers,
        memberChange: ((48 - 47) / 47) * 100 * 6,
        monthInflow,
        inflowChange: ((monthInflow - monthly[monthly.length - 2].inflow) / monthly[monthly.length - 2].inflow) * 100,
        outstanding,
        outstandingChange: -12.4
    };
})();

// Validierung beim Modul-Load (fängt Datenfehler früh ab, ohne Laufzeitkosten in Prod-Render).
if (import.meta.env.DEV) {
    z.array(memberSchema).parse(members);
    z.array(paymentSchema).parse(payments);
    z.array(activitySchema).parse(activity);
}
