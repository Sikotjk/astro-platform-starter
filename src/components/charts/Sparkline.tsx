import { motion } from 'framer-motion';

/** Mini-Trendlinie für Statistik-Karten. */
export function Sparkline({
    data,
    color = 'var(--primary)',
    width = 120,
    height = 40
}: {
    data: number[];
    color?: string;
    width?: number;
    height?: number;
}) {
    const min = Math.min(...data);
    const max = Math.max(...data);
    const span = max - min || 1;
    const stepX = width / (data.length - 1);
    const pts = data.map((d, i) => [i * stepX, height - ((d - min) / span) * (height - 6) - 3] as const);
    const line = pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`).join(' ');
    const area = `${line} L${width},${height} L0,${height} Z`;
    const id = `spark-${color.replace(/[^a-z0-9]/gi, '')}`;

    return (
        <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} className="overflow-visible">
            <defs>
                <linearGradient id={id} x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor={color} stopOpacity="0.22" />
                    <stop offset="100%" stopColor={color} stopOpacity="0" />
                </linearGradient>
            </defs>
            <motion.path
                d={area}
                fill={`url(#${id})`}
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8 }}
            />
            <motion.path
                d={line}
                fill="none"
                stroke={color}
                strokeWidth={2}
                strokeLinecap="round"
                strokeLinejoin="round"
                initial={{ pathLength: 0 }}
                whileInView={{ pathLength: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 1.2, ease: 'easeOut' }}
            />
        </svg>
    );
}
