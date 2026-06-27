import { cn } from '../../lib/cn';
import { initials } from '../../lib/format';

const PALETTE = ['#4f46e5', '#059669', '#2563eb', '#8b5cf6', '#0ea5e9', '#d97706'];

function colorFor(name: string): string {
    const hash = name.split('').reduce((a, c) => a + c.charCodeAt(0), 0);
    return PALETTE[hash % PALETTE.length];
}

export function Avatar({
    name,
    size = 36,
    flag,
    className
}: {
    name: string;
    size?: number;
    flag?: string;
    className?: string;
}) {
    const color = colorFor(name);
    return (
        <span className={cn('relative inline-flex shrink-0', className)} style={{ width: size, height: size }}>
            <span
                className="flex size-full items-center justify-center rounded-full font-semibold text-white"
                style={{
                    background: `linear-gradient(135deg, ${color}, color-mix(in oklab, ${color} 60%, #000 18%))`,
                    fontSize: size * 0.4
                }}
            >
                {initials(name)}
            </span>
            {flag && (
                <span
                    className="absolute -bottom-0.5 -right-0.5 flex items-center justify-center rounded-full bg-card ring-2 ring-card"
                    style={{ width: size * 0.46, height: size * 0.46, fontSize: size * 0.28 }}
                >
                    {flag}
                </span>
            )}
        </span>
    );
}
