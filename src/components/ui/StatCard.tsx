import type { ReactNode } from 'react';
import { ArrowDownRight, ArrowUpRight } from 'lucide-react';
import { AnimatedCounter } from './AnimatedCounter';
import { Sparkline } from '../charts/Sparkline';
import { formatPercent } from '../../lib/format';
import { cn } from '../../lib/cn';

export function StatCard({
    label,
    value,
    format,
    change,
    spark,
    icon,
    tone = 'var(--primary)',
    invertChange = false
}: {
    label: string;
    value: number;
    format: (n: number) => string;
    change: number;
    spark: number[];
    icon: ReactNode;
    tone?: string;
    invertChange?: boolean;
}) {
    const positive = invertChange ? change < 0 : change > 0;
    return (
        <div className="card-premium group p-5 transition-all duration-300 hover:shadow-float hover:-translate-y-0.5 hover:border-border-strong">
            <div className="flex items-start justify-between">
                <div
                    className="flex size-10 items-center justify-center rounded-xl"
                    style={{ background: `color-mix(in oklab, ${tone} 14%, transparent)`, color: tone }}
                >
                    {icon}
                </div>
                <span
                    className={cn(
                        'inline-flex items-center gap-0.5 rounded-full px-2 py-1 text-xs font-semibold',
                        positive ? 'bg-success/12 text-success' : 'bg-danger/12 text-danger'
                    )}
                >
                    {positive ? <ArrowUpRight size={13} /> : <ArrowDownRight size={13} />}
                    {formatPercent(Math.abs(change))}
                </span>
            </div>
            <div className="mt-4 text-[26px] font-bold leading-none tracking-tight">
                <AnimatedCounter value={value} format={format} />
            </div>
            <div className="mt-1.5 flex items-end justify-between gap-3">
                <span className="text-[13px] text-muted">{label}</span>
                <div className="opacity-80 transition-opacity group-hover:opacity-100">
                    <Sparkline data={spark} color={tone} width={96} height={32} />
                </div>
            </div>
        </div>
    );
}
