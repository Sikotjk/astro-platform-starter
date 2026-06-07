// Spiegelt das Prisma-Enum `PaymentStatus` 1:1 wider (framework-unabhängig).
export type PaymentStatus =
  | 'PENDING'
  | 'ESCROW_HELD'
  | 'RELEASED'
  | 'REFUNDED'
  | 'FAILED';
