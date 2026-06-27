import { motion } from 'framer-motion';

/** Animierter Fortschrittsbalken (füllt sich beim Sichtbarwerden). */
export function ProgressBar({
    value,
    tone = 'var(--primary)',
    height = 8
}: {
    value: number;
    tone?: string;
    height?: number;
}) {
    const pct = Math.max(0, Math.min(100, value));
    return (
        <div
            className="w-full overflow-hidden rounded-full bg-foreground/8"
            style={{ height }}
            role="progressbar"
            aria-valuenow={Math.round(pct)}
            aria-valuemin={0}
            aria-valuemax={100}
        >
            <motion.div
                className="h-full rounded-full"
                style={{ background: tone }}
                initial={{ width: 0 }}
                whileInView={{ width: `${pct}%` }}
                viewport={{ once: true, margin: '-30px' }}
                transition={{ duration: 1.1, ease: [0.16, 1, 0.3, 1] }}
            />
        </div>
    );
}
