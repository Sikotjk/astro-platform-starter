import { useMemo, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Search,
    Download,
    ArrowUpDown,
    ChevronLeft,
    ChevronRight,
    Users,
    UserCheck,
    Clock,
    Wallet
} from 'lucide-react';
import { Avatar } from '../ui/Avatar';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { members as ALL, type Member } from '../../lib/data';
import { formatEuro, formatDate, timeAgo } from '../../lib/format';
import { cn } from '../../lib/cn';

const ROLES = ['Alle', 'Administrator', 'Treasurer', 'Auditor', 'Member'] as const;
const STATUS_LABEL: Record<Member['status'], string> = { active: 'Aktiv', pending: 'Ausstehend', inactive: 'Inaktiv' };
const STATUS_TONE = { active: 'success', pending: 'warning', inactive: 'neutral' } as const;
const PER_PAGE = 8;

type SortKey = 'name' | 'contributed' | 'joined';

export function MembersView() {
    const [query, setQuery] = useState('');
    const [role, setRole] = useState<(typeof ROLES)[number]>('Alle');
    const [status, setStatus] = useState<'Alle' | Member['status']>('Alle');
    const [sort, setSort] = useState<SortKey>('contributed');
    const [dir, setDir] = useState<'asc' | 'desc'>('desc');
    const [page, setPage] = useState(0);

    const filtered = useMemo(() => {
        const q = query.trim().toLowerCase();
        const out = ALL.filter((m) => {
            if (role !== 'Alle' && m.role !== role) return false;
            if (status !== 'Alle' && m.status !== status) return false;
            if (q && !(m.name + m.email + m.country).toLowerCase().includes(q)) return false;
            return true;
        });
        out.sort((a, b) => {
            let cmp = 0;
            if (sort === 'name') cmp = a.name.localeCompare(b.name);
            else if (sort === 'contributed') cmp = a.contributed - b.contributed;
            else cmp = +new Date(a.joined) - +new Date(b.joined);
            return dir === 'asc' ? cmp : -cmp;
        });
        return out;
    }, [query, role, status, sort, dir]);

    const pages = Math.max(1, Math.ceil(filtered.length / PER_PAGE));
    const current = Math.min(page, pages - 1);
    const rows = filtered.slice(current * PER_PAGE, current * PER_PAGE + PER_PAGE);

    const toggleSort = (k: SortKey) => {
        if (sort === k) setDir((d) => (d === 'asc' ? 'desc' : 'asc'));
        else {
            setSort(k);
            setDir('desc');
        }
        setPage(0);
    };

    const exportCsv = () => {
        const head = ['ID', 'Name', 'E-Mail', 'Land', 'Rolle', 'Status', 'Beigetragen', 'Offen'];
        const lines = filtered.map((m) =>
            [m.id, m.name, m.email, m.country, m.role, m.status, m.contributed, m.outstanding].join(',')
        );
        const blob = new Blob([[head.join(','), ...lines].join('\n')], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'mitglieder.csv';
        a.click();
        URL.revokeObjectURL(url);
    };

    const stats = useMemo(
        () => ({
            total: ALL.length,
            active: ALL.filter((m) => m.status === 'active').length,
            pending: ALL.filter((m) => m.status === 'pending').length,
            contributed: ALL.reduce((s, m) => s + m.contributed, 0)
        }),
        []
    );

    return (
        <div className="space-y-5">
            {/* Mini-Statistiken */}
            <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
                {[
                    { label: 'Mitglieder', value: stats.total, icon: Users, tone: 'var(--primary)' },
                    { label: 'Aktiv', value: stats.active, icon: UserCheck, tone: 'var(--accent)' },
                    { label: 'Ausstehend', value: stats.pending, icon: Clock, tone: 'var(--warning)' },
                    { label: 'Beiträge gesamt', value: formatEuro(stats.contributed), icon: Wallet, tone: 'var(--info)' }
                ].map((s) => {
                    const Icon = s.icon;
                    return (
                        <div key={s.label} className="card-premium flex items-center gap-3 p-4">
                            <span
                                className="flex size-10 items-center justify-center rounded-xl"
                                style={{ background: `color-mix(in oklab, ${s.tone} 14%, transparent)`, color: s.tone }}
                            >
                                <Icon size={18} />
                            </span>
                            <div>
                                <div className="text-lg font-bold leading-none tracking-tight">{s.value}</div>
                                <div className="mt-1 text-[12px] text-muted">{s.label}</div>
                            </div>
                        </div>
                    );
                })}
            </div>

            {/* Toolbar */}
            <div className="card-premium p-4">
                <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
                    <div className="relative flex-1">
                        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-subtle" />
                        <input
                            value={query}
                            onChange={(e) => {
                                setQuery(e.target.value);
                                setPage(0);
                            }}
                            placeholder="Mitglieder suchen…"
                            className="h-10 w-full rounded-xl border border-border bg-surface/60 pl-9 pr-3 text-sm outline-none transition-colors focus:border-primary"
                        />
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                        <select
                            value={role}
                            onChange={(e) => {
                                setRole(e.target.value as (typeof ROLES)[number]);
                                setPage(0);
                            }}
                            className="h-10 rounded-xl border border-border bg-surface/60 px-3 text-sm outline-none focus:border-primary"
                        >
                            {ROLES.map((r) => (
                                <option key={r} value={r}>
                                    {r === 'Alle' ? 'Alle Rollen' : r}
                                </option>
                            ))}
                        </select>
                        <div className="flex rounded-xl border border-border bg-surface/60 p-1">
                            {(['Alle', 'active', 'pending', 'inactive'] as const).map((s) => (
                                <button
                                    key={s}
                                    onClick={() => {
                                        setStatus(s);
                                        setPage(0);
                                    }}
                                    className={cn(
                                        'rounded-lg px-2.5 py-1.5 text-[12px] font-medium transition-colors',
                                        status === s ? 'bg-elevated text-foreground shadow-soft' : 'text-muted hover:text-foreground'
                                    )}
                                >
                                    {s === 'Alle' ? 'Alle' : STATUS_LABEL[s]}
                                </button>
                            ))}
                        </div>
                        <Button variant="secondary" size="md" onClick={exportCsv}>
                            <Download size={15} /> Export
                        </Button>
                    </div>
                </div>
            </div>

            {/* Tabelle */}
            <div className="card-premium overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full min-w-[760px] text-sm">
                        <thead>
                            <tr className="border-b border-border text-left text-[12px] uppercase tracking-wider text-subtle">
                                <th className="px-5 py-3 font-medium">
                                    <button onClick={() => toggleSort('name')} className="flex items-center gap-1 hover:text-foreground">
                                        Mitglied <ArrowUpDown size={12} />
                                    </button>
                                </th>
                                <th className="px-5 py-3 font-medium">Rolle</th>
                                <th className="px-5 py-3 font-medium">Status</th>
                                <th className="px-5 py-3 text-right font-medium">
                                    <button onClick={() => toggleSort('contributed')} className="ml-auto flex items-center gap-1 hover:text-foreground">
                                        Beigetragen <ArrowUpDown size={12} />
                                    </button>
                                </th>
                                <th className="px-5 py-3 text-right font-medium">Offen</th>
                                <th className="px-5 py-3 text-right font-medium">
                                    <button onClick={() => toggleSort('joined')} className="ml-auto flex items-center gap-1 hover:text-foreground">
                                        Beigetreten <ArrowUpDown size={12} />
                                    </button>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <AnimatePresence mode="popLayout">
                                {rows.map((m, i) => (
                                    <motion.tr
                                        key={m.id}
                                        layout
                                        initial={{ opacity: 0, y: 6 }}
                                        animate={{ opacity: 1, y: 0, transition: { delay: i * 0.025 } }}
                                        exit={{ opacity: 0 }}
                                        className="border-b border-border/60 transition-colors last:border-0 hover:bg-foreground/[0.03]"
                                    >
                                        <td className="px-5 py-3">
                                            <div className="flex items-center gap-3">
                                                <Avatar name={m.name} flag={m.flag} size={36} />
                                                <div className="min-w-0">
                                                    <div className="truncate font-medium">{m.name}</div>
                                                    <div className="truncate text-[12px] text-subtle">{m.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-5 py-3">
                                            <Badge tone={m.role === 'Administrator' ? 'primary' : m.role === 'Treasurer' ? 'success' : m.role === 'Auditor' ? 'info' : 'neutral'}>
                                                {m.role}
                                            </Badge>
                                        </td>
                                        <td className="px-5 py-3">
                                            <Badge tone={STATUS_TONE[m.status]} dot>
                                                {STATUS_LABEL[m.status]}
                                            </Badge>
                                        </td>
                                        <td className="px-5 py-3 text-right font-medium tabular-nums">{formatEuro(m.contributed)}</td>
                                        <td className="px-5 py-3 text-right tabular-nums">
                                            {m.outstanding > 0 ? <span className="text-warning">{formatEuro(m.outstanding)}</span> : <span className="text-subtle">—</span>}
                                        </td>
                                        <td className="px-5 py-3 text-right text-[13px] text-muted">{formatDate(m.joined)}</td>
                                    </motion.tr>
                                ))}
                            </AnimatePresence>
                        </tbody>
                    </table>
                </div>

                {rows.length === 0 && (
                    <div className="px-5 py-16 text-center">
                        <p className="text-sm text-muted">Keine Mitglieder für diese Filter gefunden.</p>
                    </div>
                )}

                {/* Pagination */}
                <div className="flex items-center justify-between border-t border-border px-5 py-3 text-[13px] text-muted">
                    <span>
                        {filtered.length === 0 ? 0 : current * PER_PAGE + 1}–{Math.min((current + 1) * PER_PAGE, filtered.length)} von{' '}
                        {filtered.length}
                    </span>
                    <div className="flex items-center gap-1">
                        <button
                            onClick={() => setPage(Math.max(0, current - 1))}
                            disabled={current === 0}
                            className="flex size-8 items-center justify-center rounded-lg border border-border disabled:opacity-40 hover:enabled:border-border-strong"
                        >
                            <ChevronLeft size={16} />
                        </button>
                        <span className="px-2 tabular-nums">
                            {current + 1} / {pages}
                        </span>
                        <button
                            onClick={() => setPage(Math.min(pages - 1, current + 1))}
                            disabled={current >= pages - 1}
                            className="flex size-8 items-center justify-center rounded-lg border border-border disabled:opacity-40 hover:enabled:border-border-strong"
                        >
                            <ChevronRight size={16} />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
