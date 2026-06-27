import { useEffect, useRef, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Menu, Search, Bell, ChevronRight, CreditCard, UserPlus, FileText } from 'lucide-react';
import { ThemeToggle } from './ThemeToggle';
import { Avatar } from '../ui/Avatar';
import { withBase } from '../../lib/site';
import { activity } from '../../lib/data';
import { timeAgo } from '../../lib/format';

const NOTIF_ICON = { payment: CreditCard, member: UserPlus, report: FileText } as const;

export function Topbar({ crumb }: { crumb: string }) {
    const [notifOpen, setNotifOpen] = useState(false);
    const ref = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const onClick = (e: MouseEvent) => {
            if (ref.current && !ref.current.contains(e.target as Node)) setNotifOpen(false);
        };
        window.addEventListener('mousedown', onClick);
        return () => window.removeEventListener('mousedown', onClick);
    }, []);

    return (
        <header className="sticky top-0 z-30 flex h-16 items-center gap-3 border-b border-border glass px-4 sm:px-6">
            <button
                onClick={() => window.dispatchEvent(new Event('toggle-sidebar'))}
                aria-label="Menü öffnen"
                className="flex size-10 items-center justify-center rounded-xl border border-border text-muted hover:text-foreground lg:hidden"
            >
                <Menu size={18} />
            </button>

            <nav className="hidden items-center gap-1.5 text-sm text-muted sm:flex" aria-label="Brotkrumen">
                <a href={withBase('/')} className="hover:text-foreground">
                    Meridian
                </a>
                <ChevronRight size={14} className="text-subtle" />
                <span className="font-medium text-foreground">{crumb}</span>
            </nav>

            <button
                onClick={() => window.dispatchEvent(new Event('open-command'))}
                className="ml-auto flex h-10 w-44 items-center gap-2 rounded-xl border border-border bg-surface/60 px-3 text-sm text-subtle transition-colors hover:border-border-strong sm:w-64"
            >
                <Search size={16} />
                <span>Suchen…</span>
                <kbd className="ml-auto hidden rounded-md border border-border px-1.5 py-0.5 text-[11px] sm:block">
                    ⌘K
                </kbd>
            </button>

            <div className="relative" ref={ref}>
                <button
                    onClick={() => setNotifOpen((o) => !o)}
                    aria-label="Benachrichtigungen"
                    className="relative flex size-10 items-center justify-center rounded-xl border border-border text-muted transition-colors hover:text-foreground hover:border-border-strong"
                >
                    <Bell size={18} />
                    <span className="absolute right-2.5 top-2.5 size-2 rounded-full bg-danger ring-2 ring-card" />
                </button>
                <AnimatePresence>
                    {notifOpen && (
                        <motion.div
                            className="absolute right-0 top-12 w-80 overflow-hidden rounded-2xl border border-border bg-elevated shadow-float"
                            initial={{ opacity: 0, y: -8, scale: 0.97 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: -6, scale: 0.98 }}
                            transition={{ duration: 0.16 }}
                        >
                            <div className="flex items-center justify-between border-b border-border px-4 py-3">
                                <span className="text-sm font-semibold">Benachrichtigungen</span>
                                <span className="rounded-full bg-primary/12 px-2 py-0.5 text-[11px] font-medium text-primary">
                                    {activity.length} neu
                                </span>
                            </div>
                            <div className="max-h-80 overflow-y-auto py-1">
                                {activity.map((a) => {
                                    const Icon = NOTIF_ICON[a.kind as keyof typeof NOTIF_ICON] ?? Bell;
                                    return (
                                        <div key={a.id} className="flex gap-3 px-4 py-2.5 hover:bg-foreground/4">
                                            <span className="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                                <Icon size={15} />
                                            </span>
                                            <div className="min-w-0">
                                                <p className="truncate text-[13px] font-medium">{a.title}</p>
                                                <p className="truncate text-[12px] text-muted">{a.detail}</p>
                                                <p className="text-[11px] text-subtle">{timeAgo(a.at)}</p>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>

            <ThemeToggle />

            <button className="flex items-center gap-2.5 rounded-xl border border-transparent px-1 py-1 pr-2 transition-colors hover:border-border">
                <Avatar name="Anvar Karimov" size={34} />
                <span className="hidden flex-col items-start leading-none md:flex">
                    <span className="text-[13px] font-semibold">Anvar Karimov</span>
                    <span className="text-[11px] text-subtle">Administrator</span>
                </span>
            </button>
        </header>
    );
}
