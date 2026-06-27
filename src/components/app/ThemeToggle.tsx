import { useEffect, useState } from 'react';
import { Moon, Sun } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

/** Hell/Dunkel-Umschalter mit Persistenz (localStorage) und sanfter Animation. */
export function ThemeToggle() {
    const [dark, setDark] = useState(true);

    useEffect(() => {
        setDark(document.documentElement.classList.contains('dark'));
    }, []);

    const toggle = () => {
        const next = !dark;
        setDark(next);
        document.documentElement.classList.toggle('dark', next);
        try {
            localStorage.setItem('theme', next ? 'dark' : 'light');
        } catch {
            /* ignore */
        }
    };

    return (
        <button
            onClick={toggle}
            aria-label={dark ? 'Zu hellem Modus wechseln' : 'Zu dunklem Modus wechseln'}
            className="relative flex size-10 items-center justify-center rounded-xl border border-border text-muted transition-colors hover:text-foreground hover:border-border-strong"
        >
            <AnimatePresence mode="wait" initial={false}>
                <motion.span
                    key={dark ? 'moon' : 'sun'}
                    initial={{ rotate: -90, opacity: 0, scale: 0.6 }}
                    animate={{ rotate: 0, opacity: 1, scale: 1 }}
                    exit={{ rotate: 90, opacity: 0, scale: 0.6 }}
                    transition={{ duration: 0.25 }}
                >
                    {dark ? <Moon size={18} /> : <Sun size={18} />}
                </motion.span>
            </AnimatePresence>
        </button>
    );
}
