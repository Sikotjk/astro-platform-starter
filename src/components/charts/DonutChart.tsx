import { motion } from 'framer-motion';

interface Slice {
    label: string;
    value: number;
    color: string;
}

/** Animiertes Donut-Diagramm für die Mittelverwendung. */
export function DonutChart({ data, size = 200 }: { data: Slice[]; size?: number }) {
    const total = data.reduce((s, d) => s + d.value, 0);
    const r = size / 2 - 16;
    const c = 2 * Math.PI * r;
    let offset = 0;

    return (
        <div className="flex items-center gap-6">
            <div className="relative shrink-0" style={{ width: size, height: size }}>
                <svg width={size} height={size} className="-rotate-90">
                    {data.map((d) => {
                        const frac = d.value / total;
                        const dash = frac * c;
                        const el = (
                            <motion.circle
                                key={d.label}
                                cx={size / 2}
                                cy={size / 2}
                                r={r}
                                fill="none"
                                stroke={d.color}
                                strokeWidth={16}
                                strokeLinecap="round"
                                strokeDasharray={`${dash} ${c - dash}`}
                                strokeDashoffset={-offset}
                                initial={{ opacity: 0, strokeDasharray: `0 ${c}` }}
                                whileInView={{ opacity: 1, strokeDasharray: `${dash} ${c - dash}` }}
                                viewport={{ once: true }}
                                transition={{ duration: 1, ease: [0.16, 1, 0.3, 1] }}
                            />
                        );
                        offset += dash;
                        return el;
                    })}
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                    <span className="text-2xl font-bold tracking-tight">{total}%</span>
                    <span className="text-[11px] text-subtle">verteilt</span>
                </div>
            </div>
            <ul className="space-y-2.5">
                {data.map((d) => (
                    <li key={d.label} className="flex items-center gap-2.5 text-sm">
                        <span className="size-2.5 rounded-full" style={{ background: d.color }} />
                        <span className="text-muted">{d.label}</span>
                        <span className="ml-auto font-semibold tabular-nums">{d.value}%</span>
                    </li>
                ))}
            </ul>
        </div>
    );
}
