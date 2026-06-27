import { useMemo, useRef, useState, type PointerEvent } from 'react';
import { motion } from 'framer-motion';

interface Point {
    label: string;
    value: number;
}

/** Premium-Flächendiagramm mit animiertem Pfad, Verlauf und Hover-Tooltip. */
export function AreaChart({
    data,
    format,
    height = 280,
    color = 'var(--primary)'
}: {
    data: Point[];
    format: (n: number) => string;
    height?: number;
    color?: string;
}) {
    const W = 720;
    const H = height;
    const padX = 8;
    const padTop = 18;
    const padBottom = 28;
    const [hover, setHover] = useState<number | null>(null);
    const wrapRef = useRef<HTMLDivElement>(null);

    const { line, area, pts, max, min } = useMemo(() => {
        const values = data.map((d) => d.value);
        const max = Math.max(...values) * 1.08;
        const min = Math.min(...values) * 0.92;
        const span = max - min || 1;
        const stepX = (W - padX * 2) / (data.length - 1);
        const pts = data.map(
            (d, i) =>
                [padX + i * stepX, padTop + (1 - (d.value - min) / span) * (H - padTop - padBottom)] as const
        );
        // Glatte Kurve (Catmull-Rom → Bézier)
        let line = `M${pts[0][0]},${pts[0][1]}`;
        for (let i = 0; i < pts.length - 1; i++) {
            const p0 = pts[i === 0 ? 0 : i - 1];
            const p1 = pts[i];
            const p2 = pts[i + 1];
            const p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
            const c1x = p1[0] + (p2[0] - p0[0]) / 6;
            const c1y = p1[1] + (p2[1] - p0[1]) / 6;
            const c2x = p2[0] - (p3[0] - p1[0]) / 6;
            const c2y = p2[1] - (p3[1] - p1[1]) / 6;
            line += ` C${c1x.toFixed(1)},${c1y.toFixed(1)} ${c2x.toFixed(1)},${c2y.toFixed(1)} ${p2[0].toFixed(1)},${p2[1].toFixed(1)}`;
        }
        const area = `${line} L${pts[pts.length - 1][0]},${H - padBottom} L${pts[0][0]},${H - padBottom} Z`;
        return { line, area, pts, max, min };
    }, [data, H]);

    const onMove = (e: PointerEvent) => {
        const rect = wrapRef.current?.getBoundingClientRect();
        if (!rect) return;
        const x = ((e.clientX - rect.left) / rect.width) * W;
        const stepX = (W - padX * 2) / (data.length - 1);
        const idx = Math.round((x - padX) / stepX);
        setHover(Math.max(0, Math.min(data.length - 1, idx)));
    };

    const gridY = [0, 0.25, 0.5, 0.75, 1];

    return (
        <div ref={wrapRef} className="relative w-full" onPointerMove={onMove} onPointerLeave={() => setHover(null)}>
            <svg viewBox={`0 0 ${W} ${H}`} className="w-full" style={{ height }} preserveAspectRatio="none">
                <defs>
                    <linearGradient id="areaFill" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor={color} stopOpacity="0.26" />
                        <stop offset="100%" stopColor={color} stopOpacity="0" />
                    </linearGradient>
                </defs>
                {gridY.map((g) => {
                    const y = padTop + g * (H - padTop - padBottom);
                    return (
                        <line
                            key={g}
                            x1={padX}
                            x2={W - padX}
                            y1={y}
                            y2={y}
                            stroke="var(--border)"
                            strokeWidth={1}
                            strokeDasharray="2 5"
                        />
                    );
                })}
                <motion.path
                    d={area}
                    fill="url(#areaFill)"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 1, delay: 0.3 }}
                />
                <motion.path
                    d={line}
                    fill="none"
                    stroke={color}
                    strokeWidth={2.5}
                    strokeLinecap="round"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1.6, ease: [0.16, 1, 0.3, 1] }}
                />
                {hover !== null && (
                    <g>
                        <line
                            x1={pts[hover][0]}
                            x2={pts[hover][0]}
                            y1={padTop}
                            y2={H - padBottom}
                            stroke={color}
                            strokeWidth={1}
                            strokeOpacity={0.4}
                        />
                        <circle cx={pts[hover][0]} cy={pts[hover][1]} r={6} fill={color} />
                        <circle cx={pts[hover][0]} cy={pts[hover][1]} r={11} fill={color} fillOpacity={0.18} />
                    </g>
                )}
            </svg>

            {/* X-Achsenbeschriftung */}
            <div className="mt-1 flex justify-between px-1 text-[11px] text-subtle">
                {data.map((d, i) => (
                    <span key={i} className={data.length > 8 && i % 2 === 1 ? 'hidden sm:inline' : ''}>
                        {d.label}
                    </span>
                ))}
            </div>

            {/* Tooltip */}
            {hover !== null && (
                <div
                    className="pointer-events-none absolute z-10 -translate-x-1/2 rounded-xl border border-border bg-elevated px-3 py-2 shadow-float"
                    style={{
                        left: `${(pts[hover][0] / W) * 100}%`,
                        top: Math.max(0, (pts[hover][1] / H) * 100 - 22) + '%'
                    }}
                >
                    <div className="text-[11px] text-muted">{data[hover].label}</div>
                    <div className="text-sm font-semibold tabular-nums">{format(data[hover].value)}</div>
                </div>
            )}
        </div>
    );
}
