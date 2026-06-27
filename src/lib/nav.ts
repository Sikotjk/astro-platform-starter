import {
    LayoutDashboard,
    Users,
    CreditCard,
    FileBarChart,
    Settings2,
    type LucideIcon
} from 'lucide-react';

export interface NavItem {
    label: string;
    href: string;
    icon: LucideIcon;
    description: string;
}

/** Primäre Navigation — geteilt von Sidebar und Command-Palette. */
export const NAV: NavItem[] = [
    { label: 'Dashboard', href: '/', icon: LayoutDashboard, description: 'Übersicht & Kennzahlen' },
    { label: 'Mitglieder', href: '/members', icon: Users, description: 'Verwaltung & Profile' },
    { label: 'Zahlungen', href: '/payments', icon: CreditCard, description: 'Beiträge & Auszahlungen' },
    { label: 'Berichte', href: '/reports', icon: FileBarChart, description: 'Analysen & Exporte' },
    { label: 'Verwaltung', href: '/settings', icon: Settings2, description: 'Rollen, Audit & System' }
];
