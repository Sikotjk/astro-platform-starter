import { motion } from 'framer-motion';

interface Row {
    label: string;
    a: number;
    b: number;
}

/** Gruppiertes Balkendiagramm (z.B. Zufluss vs. Abfluss), animiert. */
export function BarChart({
    data,
    height = 220,
    colors = ['var(--primary)', 'var(--accent)']
}: {
    data: Row[];
    height?: number;
    colors?: [string, string];
}) {
    const max = Math.max(...data.flatMap((d) => [d.a, d.b])) * 1.1;
    return (
        <div className="w-full" style={{ height }}>
            <div className="flex h-full items-end gap-2">
                {data.map((d, i) => (
                    <div key={d.label} className="flex h-full flex-1 flex-col items-center justify-end gap-2">
                        <div className="flex h-full w-full items-end justify-center gap-1">
                            {([d.a, d.b] as const).map((v, j) => (
                                <motion.div
                                    key={j}
                                    className="w-1/2 max-w-3 rounded-t-md"
                                    style={{ background: colors[j] }}
                                    initial={{ height: 0 }}
                                    whileInView={{ height: `${(v / max) * 100}%` }}
                                    viewport={{ once: true, margin: '-30px' }}
                                    transition={{ duration: 0.8, delay: i * 0.04 + j * 0.05, ease: [0.16, 1, 0.3, 1] }}
                                />
                            ))}
                        </div>
                        <span className="text-[11px] text-subtle">{d.label}</span>
                    </div>
                ))}
            </div>
        </div>
    );
}
