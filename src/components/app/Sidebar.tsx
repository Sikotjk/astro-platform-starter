import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ShieldCheck, X, Sparkles } from 'lucide-react';
import { NAV } from '../../lib/nav';
import { withBase, isActivePath } from '../../lib/site';
import { formatEuroCompact } from '../../lib/format';
import { kpis } from '../../lib/data';
import { cn } from '../../lib/cn';

export function Sidebar({ currentPath }: { currentPath: string }) {
    const [open, setOpen] = useState(false);

    useEffect(() => {
        const handler = () => setOpen((o) => !o);
        window.addEventListener('toggle-sidebar', handler);
        return () => window.removeEventListener('toggle-sidebar', handler);
    }, []);

    const nav = (
        <div className="flex h-full flex-col gap-1 p-4">
            <a href={withBase('/')} className="mb-5 flex items-center gap-3 px-2 pt-1">
                <span className="flex size-9 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-primary-foreground shadow-soft">
                    <Sparkles size={18} />
                </span>
                <span className="flex flex-col leading-none">
                    <span className="text-[15px] font-semibold tracking-tight">Meridian</span>
                    <span className="text-[11px] text-subtle">Fund Platform</span>
                </span>
            </a>

            <p className="px-3 pb-1.5 pt-2 text-[11px] font-medium uppercase tracking-wider text-subtle">
                Navigation
            </p>
            <nav className="flex flex-col gap-0.5">
                {NAV.map((item) => {
                    const active = isActivePath(currentPath, item.href);
                    const Icon = item.icon;
                    return (
                        <a
                            key={item.href}
                            href={withBase(item.href)}
                            className={cn(
                                'group relative flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors',
                                active ? 'text-foreground' : 'text-muted hover:text-foreground'
                            )}
                        >
                            {active && (
                                <span className="absolute inset-0 rounded-xl border border-border bg-elevated shadow-soft" />
                            )}
                            <Icon
                                size={18}
                                className={cn('relative z-10', active && 'text-primary')}
                            />
                            <span className="relative z-10 font-medium">{item.label}</span>
                        </a>
                    );
                })}
            </nav>

            <div className="mt-auto">
                <div className="relative overflow-hidden rounded-2xl border border-border bg-gradient-to-br from-primary/10 to-accent/10 p-4">
                    <div className="flex items-center gap-2 text-[12px] text-muted">
                        <ShieldCheck size={14} className="text-accent" />
                        Fondsvolumen
                    </div>
                    <div className="mt-1 text-xl font-bold tracking-tight">
                        {formatEuroCompact(kpis.totalVolume)}
                    </div>
                    <div className="mt-0.5 text-[11px] text-success">
                        +{kpis.volumeChange.toFixed(1)}% diesen Monat
                    </div>
                </div>
            </div>
        </div>
    );

    return (
        <>
            {/* Desktop */}
            <aside className="fixed inset-y-0 left-0 z-40 hidden w-64 border-r border-border bg-surface lg:block">
                {nav}
            </aside>

            {/* Mobile-Drawer */}
            <AnimatePresence>
                {open && (
                    <>
                        <motion.div
                            className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm lg:hidden"
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setOpen(false)}
                        />
                        <motion.aside
                            className="fixed inset-y-0 left-0 z-50 w-72 border-r border-border bg-surface lg:hidden"
                            initial={{ x: '-100%' }}
                            animate={{ x: 0 }}
                            exit={{ x: '-100%' }}
                            transition={{ type: 'spring', stiffness: 380, damping: 38 }}
                        >
                            <button
                                onClick={() => setOpen(false)}
                                aria-label="Menü schließen"
                                className="absolute right-3 top-4 flex size-9 items-center justify-center rounded-lg text-muted hover:bg-foreground/5"
                            >
                                <X size={18} />
                            </button>
                            {nav}
                        </motion.aside>
                    </>
                )}
            </AnimatePresence>
        </>
    );
}
