import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ShieldCheck, ScrollText, SlidersHorizontal, Check, Lock } from 'lucide-react';
import { Badge } from '../ui/Badge';
import { roles, auditLog } from '../../lib/data';
import { timeAgo } from '../../lib/format';
import { cn } from '../../lib/cn';

const TABS = [
    { id: 'roles', label: 'Rollen & Rechte', icon: ShieldCheck },
    { id: 'audit', label: 'Audit-Log', icon: ScrollText },
    { id: 'system', label: 'System', icon: SlidersHorizontal }
] as const;

type TabId = (typeof TABS)[number]['id'];

function Switch({ on, onToggle }: { on: boolean; onToggle: () => void }) {
    return (
        <button
            onClick={onToggle}
            role="switch"
            aria-checked={on}
            className={cn('relative h-6 w-11 shrink-0 rounded-full transition-colors', on ? 'bg-primary' : 'bg-foreground/15')}
        >
            <motion.span
                layout
                transition={{ type: 'spring', stiffness: 500, damping: 32 }}
                className="absolute top-0.5 size-5 rounded-full bg-white shadow"
                style={{ left: on ? 22 : 2 }}
            />
        </button>
    );
}

const SYSTEM_SETTINGS = [
    { key: '2fa', label: 'Zwei-Faktor-Authentifizierung erzwingen', desc: 'Pflicht für alle Mitglieder mit Verwaltungsrechten.', def: true },
    { key: 'notify', label: 'E-Mail-Benachrichtigungen', desc: 'Bei Beiträgen, Auszahlungen und neuen Mitgliedern.', def: true },
    { key: 'audit', label: 'Erweitertes Audit-Logging', desc: 'Protokolliert jede schreibende Aktion mit IP & Zeitstempel.', def: true },
    { key: 'autopay', label: 'Automatische Beitragserinnerungen', desc: 'Erinnert Mitglieder 3 Tage vor Fälligkeit.', def: false }
];

export function SettingsView() {
    const [tab, setTab] = useState<TabId>('roles');
    const [toggles, setToggles] = useState<Record<string, boolean>>(
        Object.fromEntries(SYSTEM_SETTINGS.map((s) => [s.key, s.def]))
    );

    return (
        <div className="space-y-5">
            <div className="flex w-full gap-1 overflow-x-auto rounded-xl border border-border bg-surface/60 p-1">
                {TABS.map((t) => {
                    const Icon = t.icon;
                    const active = tab === t.id;
                    return (
                        <button
                            key={t.id}
                            onClick={() => setTab(t.id)}
                            className={cn(
                                'relative flex flex-1 items-center justify-center gap-2 whitespace-nowrap rounded-lg px-4 py-2.5 text-sm font-medium transition-colors',
                                active ? 'text-foreground' : 'text-muted hover:text-foreground'
                            )}
                        >
                            {active && (
                                <motion.span
                                    layoutId="settings-tab"
                                    className="absolute inset-0 rounded-lg bg-elevated shadow-soft"
                                    transition={{ type: 'spring', stiffness: 400, damping: 32 }}
                                />
                            )}
                            <Icon size={16} className="relative z-10" />
                            <span className="relative z-10">{t.label}</span>
                        </button>
                    );
                })}
            </div>

            <AnimatePresence mode="wait">
                <motion.div
                    key={tab}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -6 }}
                    transition={{ duration: 0.22 }}
                >
                    {tab === 'roles' && (
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            {roles.map((r) => (
                                <div key={r.name} className="card-premium p-5">
                                    <div className="flex items-center justify-between">
                                        <div className="flex items-center gap-3">
                                            <span className="size-3 rounded-full" style={{ background: r.color }} />
                                            <h3 className="font-semibold">{r.name}</h3>
                                        </div>
                                        <Badge tone="neutral">{r.members} Mitglieder</Badge>
                                    </div>
                                    <ul className="mt-4 space-y-2">
                                        {r.permissions.map((p) => (
                                            <li key={p} className="flex items-center gap-2 text-[13px] text-muted">
                                                <Check size={14} className="text-accent" />
                                                {p}
                                            </li>
                                        ))}
                                    </ul>
                                </div>
                            ))}
                        </div>
                    )}

                    {tab === 'audit' && (
                        <div className="card-premium overflow-hidden">
                            <div className="overflow-x-auto">
                                <table className="w-full min-w-[680px] text-sm">
                                    <thead>
                                        <tr className="border-b border-border text-left text-[12px] uppercase tracking-wider text-subtle">
                                            <th className="px-5 py-3 font-medium">Akteur</th>
                                            <th className="px-5 py-3 font-medium">Aktion</th>
                                            <th className="px-5 py-3 font-medium">Ziel</th>
                                            <th className="px-5 py-3 font-medium">IP</th>
                                            <th className="px-5 py-3 text-right font-medium">Zeit</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {auditLog.map((l, i) => (
                                            <motion.tr
                                                key={l.id}
                                                initial={{ opacity: 0 }}
                                                animate={{ opacity: 1, transition: { delay: i * 0.04 } }}
                                                className="border-b border-border/60 last:border-0 hover:bg-foreground/[0.03]"
                                            >
                                                <td className="px-5 py-3">
                                                    <div className="font-medium">{l.actor}</div>
                                                    <div className="text-[12px] text-subtle">{l.role}</div>
                                                </td>
                                                <td className="px-5 py-3 text-muted">{l.action}</td>
                                                <td className="px-5 py-3 text-[13px] text-muted">{l.target}</td>
                                                <td className="px-5 py-3 font-mono text-[12px] text-subtle">{l.ip}</td>
                                                <td className="px-5 py-3 text-right text-[13px] text-muted">{timeAgo(l.at)}</td>
                                            </motion.tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    )}

                    {tab === 'system' && (
                        <div className="space-y-3">
                            {SYSTEM_SETTINGS.map((s) => (
                                <div key={s.key} className="card-premium flex items-center gap-4 p-5">
                                    <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                        <Lock size={17} />
                                    </span>
                                    <div className="min-w-0 flex-1">
                                        <div className="font-medium">{s.label}</div>
                                        <div className="text-[13px] text-muted">{s.desc}</div>
                                    </div>
                                    <Switch on={!!toggles[s.key]} onToggle={() => setToggles((t) => ({ ...t, [s.key]: !t[s.key] }))} />
                                </div>
                            ))}
                        </div>
                    )}
                </motion.div>
            </AnimatePresence>
        </div>
    );
}
