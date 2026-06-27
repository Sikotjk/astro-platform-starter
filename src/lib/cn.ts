import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/** Klassen sicher zusammenführen (clsx + Tailwind-Konfliktauflösung). */
export function cn(...inputs: ClassValue[]): string {
    return twMerge(clsx(inputs));
}
