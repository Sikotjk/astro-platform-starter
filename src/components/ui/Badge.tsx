import type { ReactNode } from 'react';
import { cn } from '../../lib/cn';

type Tone = 'neutral' | 'primary' | 'success' | 'warning' | 'danger' | 'info';

const tones: Record<Tone, string> = {
    neutral: 'bg-foreground/6 text-muted',
    primary: 'bg-primary/12 text-primary',
    success: 'bg-success/12 text-success',
    warning: 'bg-warning/14 text-warning',
    danger: 'bg-danger/12 text-danger',
    info: 'bg-info/12 text-info'
};

export function Badge({
    tone = 'neutral',
    dot = false,
    className,
    children
}: {
    tone?: Tone;
    dot?: boolean;
    className?: string;
    children: ReactNode;
}) {
    return (
        <span
            className={cn(
                'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium',
                tones[tone],
                className
            )}
        >
            {dot && <span className="size-1.5 rounded-full bg-current" />}
            {children}
        </span>
    );
}
