import type { ButtonHTMLAttributes, ReactNode } from 'react';
import { cn } from '../../lib/cn';

type Variant = 'primary' | 'secondary' | 'ghost' | 'outline' | 'danger';
type Size = 'sm' | 'md' | 'lg' | 'icon';

const variants: Record<Variant, string> = {
    primary:
        'bg-primary text-primary-foreground shadow-soft hover:brightness-110 active:brightness-95',
    secondary: 'bg-elevated text-foreground border border-border hover:border-border-strong',
    ghost: 'text-muted hover:text-foreground hover:bg-foreground/5',
    outline: 'border border-border-strong text-foreground hover:bg-foreground/5',
    danger: 'bg-danger text-white hover:brightness-110'
};

const sizes: Record<Size, string> = {
    sm: 'h-8 px-3 text-[13px] gap-1.5 rounded-lg',
    md: 'h-10 px-4 text-sm gap-2 rounded-xl',
    lg: 'h-12 px-6 text-[15px] gap-2.5 rounded-xl',
    icon: 'h-10 w-10 rounded-xl'
};

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: Variant;
    size?: Size;
    children?: ReactNode;
}

export function Button({ variant = 'primary', size = 'md', className, children, ...rest }: Props) {
    return (
        <button
            className={cn(
                'inline-flex items-center justify-center font-medium transition-all duration-200 ease-out',
                'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary disabled:opacity-50 disabled:pointer-events-none',
                'active:scale-[0.97] cursor-pointer select-none whitespace-nowrap',
                variants[variant],
                sizes[size],
                className
            )}
            {...rest}
        >
            {children}
        </button>
    );
}
