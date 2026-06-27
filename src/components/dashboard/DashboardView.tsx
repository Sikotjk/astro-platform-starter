import { useState } from 'react';
import { motion } from 'framer-motion';
import {
    Wallet,
    Users,
    TrendingUp,
    AlertCircle,
    ArrowRight,
    UserPlus,
    Send,
    FileDown,
    ShieldCheck,
    CreditCard,
    FileText
} from 'lucide-react';
import { StatCard } from '../ui/StatCard';
import { AreaChart } from '../charts/AreaChart';
import { DonutChart } from '../charts/DonutChart';
import { BarChart } from '../charts/BarChart';
import { Avatar } from '../ui/Avatar';
import { kpis, monthly, allocation, activity } from '../../lib/data';
import { formatEuro, formatEuroCompact, formatNumber, timeAgo } from '../../lib/format';
import { withBase } from '../../lib/site';
import { cn } from '../../lib/cn';

const fade = {
    hidden: { opacity: 0, y: 16 },
    show: (i: number) => ({ opacity: 1, y: 0, transition: { duration: 0.5, delay: i * 0.06, ease: [0.16, 1, 0.3, 1] } })
};

const ACT_ICON = { payment: CreditCard, member: UserPlus, report: FileText, security: ShieldCheck, system: ShieldCheck };

const QUICK = [
    { label: 'Mitglied einladen', icon: UserPlus, tone: 'var(--primary)' },
    { label: 'Auszahlung starten', icon: Send, tone: 'var(--accent)' },
    { label: 'Bericht exportieren', icon: FileDown, tone: 'var(--info)' }
];

export function DashboardView() {
    const [tab, setTab] = useState<'volume' | 'inflow'>('volume');

    const chartData = monthly.map((m) => ({
        label: m.m,
        value: tab === 'volume' ? m.volume : m.inflow
    }));
    const barData = monthly.slice(-7).map((m) => ({ label: m.m, a: m.inflow, b: m.outflow }));

    const cards = [
        {
            label: 'Fondsvolumen gesamt',
            value: kpis.totalVolume,
            format: (n: number) => formatEuroCompact(n),
            change: kpis.volumeChange,
            spark: monthly.map((m) => m.volume),
            icon: <Wallet size={18} />,
            tone: 'var(--primary)'
        },
        {
            label: 'Aktive Mitglieder',
            value: kpis.activeMembers,
            format: (n: number) => formatNumber(Math.round(n)),
            change: kpis.memberChange,
            spark: monthly.map((m) => m.members),
            icon: <Users size={18} />,
            tone: 'var(--info)'
        },
        {
            label: 'Zufluss diesen Monat',
            value: kpis.monthInflow,
            format: (n: number) => formatEuroCompact(n),
            change: kpis.inflowChange,
            spark: monthly.map((m) => m.inflow),
            icon: <TrendingUp size={18} />,
            tone: 'var(--accent)'
        },
        {
            label: 'Offene Beiträge',
            value: kpis.outstanding,
            format: (n: number) => formatEuro(n),
            change: kpis.outstandingChange,
            spark: [9, 8, 8.4, 7, 6.5, 6.8, 5.4, 5],
            icon: <AlertCircle size={18} />,
            tone: 'var(--warning)',
            invertChange: true
        }
    ];

    return (
        <div className="space-y-6">
            {/* KPIs */}
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
                {cards.map((c, i) => (
                    <motion.div key={c.label} custom={i} initial="hidden" animate="show" variants={fade}>
                        <StatCard {...c} />
                    </motion.div>
                ))}
            </div>

            {/* Chart + Allocation */}
            <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
                <motion.div
                    custom={4}
                    initial="hidden"
                    animate="show"
                    variants={fade}
                    className="card-premium lg:col-span-2"
                >
                    <div className="flex flex-wrap items-center justify-between gap-3 p-5 pb-0">
                        <div>
                            <h3 className="text-[15px] font-semibold">Fondsentwicklung</h3>
                            <p className="mt-0.5 text-[13px] text-muted">Letzte 12 Monate</p>
                        </div>
                        <div className="flex rounded-xl border border-border bg-surface/60 p-1">
                            {(['volume', 'inflow'] as const).map((t) => (
                                <button
                                    key={t}
                                    onClick={() => setTab(t)}
                                    className={cn(
                                        'relative rounded-lg px-3 py-1.5 text-[13px] font-medium transition-colors',
                                        tab === t ? 'text-foreground' : 'text-muted hover:text-foreground'
                                    )}
                                >
                                    {tab === t && (
                                        <motion.span
                                            layoutId="chart-tab"
                                            className="absolute inset-0 rounded-lg bg-elevated shadow-soft"
                                            transition={{ type: 'spring', stiffness: 400, damping: 32 }}
                                        />
                                    )}
                                    <span className="relative z-10">{t === 'volume' ? 'Volumen' : 'Zufluss'}</span>
                                </button>
                            ))}
                        </div>
                    </div>
                    <div className="p-3 pt-2">
                        <AreaChart
                            data={chartData}
                            format={(n) => formatEuro(n)}
                            color={tab === 'volume' ? 'var(--primary)' : 'var(--accent)'}
                        />
                    </div>
                </motion.div>

                <motion.div custom={5} initial="hidden" animate="show" variants={fade} className="card-premium">
                    <div className="p-5 pb-0">
                        <h3 className="text-[15px] font-semibold">Mittelverwendung</h3>
                        <p className="mt-0.5 text-[13px] text-muted">Aktuelle Allokation</p>
                    </div>
                    <div className="p-5">
                        <DonutChart data={allocation} size={180} />
                    </div>
                </motion.div>
            </div>

            {/* Inflow/Outflow + Activity + Quick actions */}
            <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
                <motion.div custom={6} initial="hidden" animate="show" variants={fade} className="card-premium">
                    <div className="p-5 pb-0">
                        <h3 className="text-[15px] font-semibold">Zu- & Abfluss</h3>
                        <p className="mt-0.5 text-[13px] text-muted">Beiträge vs. Auszahlungen</p>
                    </div>
                    <div className="p-5">
                        <BarChart data={barData} height={190} />
                        <div className="mt-3 flex items-center gap-4 text-[12px] text-muted">
                            <span className="flex items-center gap-1.5">
                                <span className="size-2.5 rounded-full bg-primary" /> Zufluss
                            </span>
                            <span className="flex items-center gap-1.5">
                                <span className="size-2.5 rounded-full bg-accent" /> Abfluss
                            </span>
                        </div>
                    </div>
                </motion.div>

                <motion.div custom={7} initial="hidden" animate="show" variants={fade} className="card-premium">
                    <div className="flex items-center justify-between p-5 pb-3">
                        <h3 className="text-[15px] font-semibold">Letzte Aktivität</h3>
                        <a href={withBase('/reports')} className="text-[13px] font-medium text-primary hover:underline">
                            Alle
                        </a>
                    </div>
                    <div className="px-2 pb-3">
                        {activity.slice(0, 5).map((a) => {
                            const Icon = ACT_ICON[a.kind] ?? CreditCard;
                            return (
                                <div key={a.id} className="flex gap-3 rounded-xl px-3 py-2.5 hover:bg-foreground/4">
                                    <span className="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                        <Icon size={15} />
                                    </span>
                                    <div className="min-w-0 flex-1">
                                        <p className="truncate text-[13px] font-medium">{a.title}</p>
                                        <p className="truncate text-[12px] text-muted">{a.detail}</p>
                                    </div>
                                    <span className="shrink-0 text-[11px] text-subtle">{timeAgo(a.at)}</span>
                                </div>
                            );
                        })}
                    </div>
                </motion.div>

                <motion.div custom={8} initial="hidden" animate="show" variants={fade} className="flex flex-col gap-4">
                    <div className="card-premium p-5">
                        <h3 className="text-[15px] font-semibold">Schnellaktionen</h3>
                        <div className="mt-3 space-y-2">
                            {QUICK.map((q) => {
                                const Icon = q.icon;
                                return (
                                    <button
                                        key={q.label}
                                        className="group flex w-full items-center gap-3 rounded-xl border border-border bg-surface/40 px-3 py-3 text-left transition-all hover:border-border-strong hover:shadow-soft"
                                    >
                                        <span
                                            className="flex size-9 items-center justify-center rounded-lg"
                                            style={{ background: `color-mix(in oklab, ${q.tone} 14%, transparent)`, color: q.tone }}
                                        >
                                            <Icon size={17} />
                                        </span>
                                        <span className="text-sm font-medium">{q.label}</span>
                                        <ArrowRight
                                            size={16}
                                            className="ml-auto text-subtle transition-transform group-hover:translate-x-0.5 group-hover:text-foreground"
                                        />
                                    </button>
                                );
                            })}
                        </div>
                    </div>

                    <div className="relative overflow-hidden rounded-2xl border border-border bg-gradient-to-br from-primary/12 via-card to-accent/10 p-5">
                        <ShieldCheck className="text-accent" size={22} />
                        <h3 className="mt-2 text-[15px] font-semibold">Treuhand gesichert</h3>
                        <p className="mt-1 text-[13px] text-muted">
                            Alle Mittel sind segregiert verwahrt und werden vierteljährlich extern geprüft.
                        </p>
                        <div className="mt-3 flex -space-x-2">
                            {['Karim Rahimov', 'Madina Tosheva', 'Sabina Saidova'].map((n) => (
                                <Avatar key={n} name={n} size={28} className="ring-2 ring-card" />
                            ))}
                            <span className="flex size-7 items-center justify-center rounded-full bg-elevated text-[11px] font-medium text-muted ring-2 ring-card">
                                +6
                            </span>
                        </div>
                    </div>
                </motion.div>
            </div>
        </div>
    );
}
