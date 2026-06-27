import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowDownLeft, ArrowUpRight, Scale, AlertCircle, Search } from 'lucide-react';
import { AreaChart } from '../charts/AreaChart';
import { Badge } from '../ui/Badge';
import { payments as ALL, monthly, kpis, type Payment } from '../../lib/data';
import { formatEuro, formatEuroCompact, formatDate } from '../../lib/format';
import { cn } from '../../lib/cn';

const TYPE_LABEL: Record<Payment['type'], string> = { contribution: 'Beitrag', payout: 'Auszahlung', fee: 'Gebühr' };
const PSTATUS_LABEL: Record<Payment['status'], string> = { settled: 'Abgeschlossen', processing: 'In Bearbeitung', failed: 'Fehlgeschlagen' };
const PSTATUS_TONE = { settled: 'success', processing: 'info', failed: 'danger' } as const;

export function PaymentsView() {
    const [query, setQuery] = useState('');
    const [type, setType] = useState<'all' | Payment['type']>('all');
    const [status, setStatus] = useState<'all' | Payment['status']>('all');

    const totals = useMemo(() => {
        const inflow = ALL.filter((p) => p.type === 'contribution' && p.status !== 'failed').reduce((s, p) => s + p.amount, 0);
        const outflow = ALL.filter((p) => p.type === 'payout' && p.status !== 'failed').reduce((s, p) => s + Math.abs(p.amount), 0);
        return { inflow, outflow, net: inflow - outflow };
    }, []);

    const filtered = useMemo(() => {
        const q = query.trim().toLowerCase();
        return ALL.filter((p) => {
            if (type !== 'all' && p.type !== type) return false;
            if (status !== 'all' && p.status !== status) return false;
            if (q && !(p.member + p.reference + p.id).toLowerCase().includes(q)) return false;
            return true;
        }).slice(0, 24);
    }, [query, type, status]);

    const trend = monthly.map((m) => ({ label: m.m, value: m.inflow }));

    const stats = [
        { label: 'Zufluss gesamt', value: formatEuroCompact(totals.inflow), icon: ArrowDownLeft, tone: 'var(--accent)' },
        { label: 'Auszahlungen', value: formatEuroCompact(totals.outflow), icon: ArrowUpRight, tone: 'var(--info)' },
        { label: 'Netto', value: formatEuroCompact(totals.net), icon: Scale, tone: 'var(--primary)' },
        { label: 'Offene Beiträge', value: formatEuro(kpis.outstanding), icon: AlertCircle, tone: 'var(--warning)' }
    ];

    return (
        <div className="space-y-5">
            <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
                {stats.map((s, i) => {
                    const Icon = s.icon;
                    return (
                        <motion.div
                            key={s.label}
                            initial={{ opacity: 0, y: 14 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.05 }}
                            className="card-premium p-4"
                        >
                            <span
                                className="flex size-10 items-center justify-center rounded-xl"
                                style={{ background: `color-mix(in oklab, ${s.tone} 14%, transparent)`, color: s.tone }}
                            >
                                <Icon size={18} />
                            </span>
                            <div className="mt-3 text-xl font-bold tracking-tight">{s.value}</div>
                            <div className="mt-1 text-[12px] text-muted">{s.label}</div>
                        </motion.div>
                    );
                })}
            </div>

            <div className="card-premium">
                <div className="p-5 pb-0">
                    <h3 className="text-[15px] font-semibold">Beitragsverlauf</h3>
                    <p className="mt-0.5 text-[13px] text-muted">Monatlicher Zufluss über 12 Monate</p>
                </div>
                <div className="p-3 pt-2">
                    <AreaChart data={trend} format={(n) => formatEuro(n)} color="var(--accent)" height={220} />
                </div>
            </div>

            <div className="card-premium overflow-hidden">
                <div className="flex flex-col gap-3 border-b border-border p-4 lg:flex-row lg:items-center">
                    <div className="relative flex-1">
                        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-subtle" />
                        <input
                            value={query}
                            onChange={(e) => setQuery(e.target.value)}
                            placeholder="Transaktion oder Referenz suchen…"
                            className="h-10 w-full rounded-xl border border-border bg-surface/60 pl-9 pr-3 text-sm outline-none focus:border-primary"
                        />
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                        <div className="flex rounded-xl border border-border bg-surface/60 p-1">
                            {(['all', 'contribution', 'payout', 'fee'] as const).map((t) => (
                                <button
                                    key={t}
                                    onClick={() => setType(t)}
                                    className={cn(
                                        'rounded-lg px-2.5 py-1.5 text-[12px] font-medium transition-colors',
                                        type === t ? 'bg-elevated text-foreground shadow-soft' : 'text-muted hover:text-foreground'
                                    )}
                                >
                                    {t === 'all' ? 'Alle' : TYPE_LABEL[t]}
                                </button>
                            ))}
                        </div>
                        <select
                            value={status}
                            onChange={(e) => setStatus(e.target.value as 'all' | Payment['status'])}
                            className="h-10 rounded-xl border border-border bg-surface/60 px-3 text-sm outline-none focus:border-primary"
                        >
                            <option value="all">Jeder Status</option>
                            <option value="settled">Abgeschlossen</option>
                            <option value="processing">In Bearbeitung</option>
                            <option value="failed">Fehlgeschlagen</option>
                        </select>
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full min-w-[720px] text-sm">
                        <thead>
                            <tr className="border-b border-border text-left text-[12px] uppercase tracking-wider text-subtle">
                                <th className="px-5 py-3 font-medium">Transaktion</th>
                                <th className="px-5 py-3 font-medium">Typ</th>
                                <th className="px-5 py-3 font-medium">Methode</th>
                                <th className="px-5 py-3 font-medium">Status</th>
                                <th className="px-5 py-3 text-right font-medium">Betrag</th>
                                <th className="px-5 py-3 text-right font-medium">Datum</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.map((p, i) => (
                                <motion.tr
                                    key={p.id}
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1, transition: { delay: Math.min(i, 12) * 0.02 } }}
                                    className="border-b border-border/60 transition-colors last:border-0 hover:bg-foreground/[0.03]"
                                >
                                    <td className="px-5 py-3">
                                        <div className="flex items-center gap-2">
                                            <span className="text-base">{p.flag}</span>
                                            <div>
                                                <div className="font-medium">{p.member}</div>
                                                <div className="text-[12px] text-subtle">{p.reference}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-5 py-3">
                                        <Badge tone={p.type === 'contribution' ? 'success' : p.type === 'payout' ? 'info' : 'neutral'}>
                                            {TYPE_LABEL[p.type]}
                                        </Badge>
                                    </td>
                                    <td className="px-5 py-3 text-muted">{p.method}</td>
                                    <td className="px-5 py-3">
                                        <Badge tone={PSTATUS_TONE[p.status]} dot>
                                            {PSTATUS_LABEL[p.status]}
                                        </Badge>
                                    </td>
                                    <td className={cn('px-5 py-3 text-right font-semibold tabular-nums', p.amount < 0 ? 'text-foreground' : 'text-success')}>
                                        {p.amount < 0 ? '−' : '+'}
                                        {formatEuro(Math.abs(p.amount))}
                                    </td>
                                    <td className="px-5 py-3 text-right text-[13px] text-muted">{formatDate(p.date)}</td>
                                </motion.tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
