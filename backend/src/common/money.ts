// Geld-Umrechnung. Intern rechnen wir in Minor Units (Cent, Integer), die DB
// speichert Decimal-Euro. Hier liegt die einzige Konvertierungsstelle.

import { Prisma } from '@prisma/client';

export function eurosToMinor(euros: Prisma.Decimal | number | string): number {
  const n = typeof euros === 'object' ? Number(euros.toString()) : Number(euros);
  return Math.round((n + Number.EPSILON) * 100);
}

export function minorToEuros(minor: number): Prisma.Decimal {
  return new Prisma.Decimal((minor / 100).toFixed(2));
}
