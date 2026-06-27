import type { ReactNode } from 'react';
import { cn } from '../../lib/cn';

export function Card({
    className,
    hover = false,
    children
}: {
    className?: string;
    hover?: boolean;
    children: ReactNode;
}) {
    return (
        <div
            className={cn(
                'card-premium relative overflow-hidden',
                hover &&
                    'transition-all duration-300 hover:shadow-float hover:-translate-y-0.5 hover:border-border-strong',
                className
            )}
        >
            {children}
        </div>
    );
}

export function CardHeader({ className, children }: { className?: string; children: ReactNode }) {
    return <div className={cn('flex items-start justify-between gap-4 p-5 pb-0', className)}>{children}</div>;
}

export function CardTitle({ className, children }: { className?: string; children: ReactNode }) {
    return <h3 className={cn('text-[15px] font-semibold tracking-tight', className)}>{children}</h3>;
}

export function CardDescription({ className, children }: { className?: string; children: ReactNode }) {
    return <p className={cn('mt-0.5 text-[13px] text-muted', className)}>{children}</p>;
}

export function CardContent({ className, children }: { className?: string; children: ReactNode }) {
    return <div className={cn('p-5', className)}>{children}</div>;
}
