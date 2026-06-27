import { useEffect, useMemo, useRef, useState, type KeyboardEvent } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, CornerDownLeft, ArrowUp, ArrowDown } from 'lucide-react';
import { NAV } from '../../lib/nav';
import { members } from '../../lib/data';
import { withBase } from '../../lib/site';
import { cn } from '../../lib/cn';

interface Cmd {
    id: string;
    label: string;
    hint: string;
    href: string;
    group: string;
}

export function CommandPalette() {
    const [open, setOpen] = useState(false);
    const [query, setQuery] = useState('');
    const [active, setActive] = useState(0);
    const inputRef = useRef<HTMLInputElement>(null);

    const commands: Cmd[] = useMemo(() => {
        const navCmds = NAV.map((n) => ({
            id: `nav-${n.href}`,
            label: n.label,
            hint: n.description,
            href: n.href,
            group: 'Navigation'
        }));
        const memberCmds = members.slice(0, 60).map((m) => ({
            id: m.id,
            label: m.name,
            hint: `${m.country} · ${m.role}`,
            href: '/members',
            group: 'Mitglieder'
        }));
        return [...navCmds, ...memberCmds];
    }, []);

    const filtered = useMemo(() => {
        const q = query.trim().toLowerCase();
        if (!q) return commands.slice(0, 8);
        return commands.filter((c) => (c.label + ' ' + c.hint).toLowerCase().includes(q)).slice(0, 12);
    }, [query, commands]);

    useEffect(() => {
        const onKey = (e: KeyboardEvent) => {
            if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
                e.preventDefault();
                setOpen((o) => !o);
            }
            if (e.key === 'Escape') setOpen(false);
        };
        const onOpen = () => setOpen(true);
        window.addEventListener('keydown', onKey);
        window.addEventListener('open-command', onOpen);
        return () => {
            window.removeEventListener('keydown', onKey);
            window.removeEventListener('open-command', onOpen);
        };
    }, []);

    useEffect(() => {
        if (open) {
            setQuery('');
            setActive(0);
            setTimeout(() => inputRef.current?.focus(), 40);
        }
    }, [open]);

    useEffect(() => setActive(0), [query]);

    const go = (c: Cmd) => {
        window.location.href = withBase(c.href);
    };

    const onKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            setActive((a) => Math.min(a + 1, filtered.length - 1));
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            setActive((a) => Math.max(a - 1, 0));
        } else if (e.key === 'Enter' && filtered[active]) {
            go(filtered[active]);
        }
    };

    return (
        <AnimatePresence>
            {open && (
                <motion.div
                    className="fixed inset-0 z-[100] flex items-start justify-center px-4 pt-[12vh]"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                >
                    <div
                        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
                        onClick={() => setOpen(false)}
                    />
                    <motion.div
                        className="relative w-full max-w-xl overflow-hidden rounded-2xl border border-border bg-elevated shadow-float"
                        initial={{ scale: 0.96, opacity: 0, y: -8 }}
                        animate={{ scale: 1, opacity: 1, y: 0 }}
                        exit={{ scale: 0.97, opacity: 0, y: -6 }}
                        transition={{ duration: 0.18, ease: [0.16, 1, 0.3, 1] }}
                    >
                        <div className="flex items-center gap-3 border-b border-border px-4">
                            <Search size={18} className="text-subtle" />
                            <input
                                ref={inputRef}
                                value={query}
                                onChange={(e) => setQuery(e.target.value)}
                                onKeyDown={onKeyDown}
                                placeholder="Suchen oder Befehl eingeben…"
                                className="h-14 flex-1 bg-transparent text-[15px] outline-none placeholder:text-subtle"
                            />
                            <kbd className="hidden rounded-md border border-border px-1.5 py-0.5 text-[11px] text-subtle sm:block">
                                ESC
                            </kbd>
                        </div>

                        <div className="max-h-[52vh] overflow-y-auto p-2">
                            {filtered.length === 0 && (
                                <div className="px-3 py-8 text-center text-sm text-muted">
                                    Keine Treffer für „{query}"
                                </div>
                            )}
                            {filtered.map((c, i) => (
                                <button
                                    key={c.id}
                                    onMouseEnter={() => setActive(i)}
                                    onClick={() => go(c)}
                                    className={cn(
                                        'flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left transition-colors',
                                        i === active ? 'bg-primary/10' : 'hover:bg-foreground/5'
                                    )}
                                >
                                    <span className="flex flex-col">
                                        <span className="text-sm font-medium">{c.label}</span>
                                        <span className="text-[12px] text-subtle">{c.hint}</span>
                                    </span>
                                    <span className="ml-auto text-[11px] text-subtle">{c.group}</span>
                                    {i === active && <CornerDownLeft size={14} className="text-primary" />}
                                </button>
                            ))}
                        </div>

                        <div className="flex items-center gap-3 border-t border-border px-4 py-2.5 text-[11px] text-subtle">
                            <span className="flex items-center gap-1">
                                <ArrowUp size={11} />
                                <ArrowDown size={11} /> navigieren
                            </span>
                            <span className="flex items-center gap-1">
                                <CornerDownLeft size={11} /> öffnen
                            </span>
                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}
