import { useEffect, useRef, useState } from 'react';
import { animate, useInView } from 'framer-motion';

/** Zählt beim Sichtbarwerden von 0 auf den Zielwert hoch (respektiert reduce-motion). */
export function AnimatedCounter({
    value,
    format,
    duration = 1.4
}: {
    value: number;
    format: (n: number) => string;
    duration?: number;
}) {
    const ref = useRef<HTMLSpanElement>(null);
    const inView = useInView(ref, { once: true, margin: '-40px' });
    const [display, setDisplay] = useState(0);

    useEffect(() => {
        if (!inView) return;
        const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (reduce) {
            setDisplay(value);
            return;
        }
        const controls = animate(0, value, {
            duration,
            ease: [0.16, 1, 0.3, 1],
            onUpdate: (v) => setDisplay(v)
        });
        return () => controls.stop();
    }, [inView, value, duration]);

    return (
        <span ref={ref} className="tabular-nums">
            {format(display)}
        </span>
    );
}
