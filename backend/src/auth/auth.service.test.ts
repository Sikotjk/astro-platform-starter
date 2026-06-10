import { describe, it, expect, beforeEach } from 'vitest';
import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import type { PrismaService } from '../prisma/prisma.service';

// ── Minimaler In-Memory-Fake der von AuthService genutzten Prisma-Ausschnitte ─
interface TokenRow {
  id: string;
  userId: string;
  tokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
}

class FakePrisma {
  users: Array<{ id: string; email: string; passwordHash: string | null; role: string }> = [];
  tokens: TokenRow[] = [];
  private seq = 0;

  user = {
    findUnique: ({ where }: { where: { email?: string; id?: string } }) =>
      Promise.resolve(
        this.users.find((u) => (where.email ? u.email === where.email : u.id === where.id)) ?? null,
      ),
    create: ({ data }: { data: Record<string, unknown> }) => {
      const u = { id: `u_${++this.seq}`, role: 'SENDER', ...data } as (typeof this.users)[number];
      this.users.push(u);
      return Promise.resolve(u);
    },
  };

  refreshToken = {
    create: ({ data }: { data: Omit<TokenRow, 'id' | 'revokedAt'> }) => {
      const row: TokenRow = { id: `rt_${++this.seq}`, revokedAt: null, ...data };
      this.tokens.push(row);
      return Promise.resolve(row);
    },
    findUnique: ({ where }: { where: { tokenHash: string } }) =>
      Promise.resolve(this.tokens.find((t) => t.tokenHash === where.tokenHash) ?? null),
    update: ({ where, data }: { where: { id: string }; data: Partial<TokenRow> }) => {
      const t = this.tokens.find((x) => x.id === where.id)!;
      Object.assign(t, data);
      return Promise.resolve(t);
    },
    updateMany: ({
      where,
      data,
    }: {
      where: { userId?: string; tokenHash?: string; revokedAt: null };
      data: Partial<TokenRow>;
    }) => {
      const hits = this.tokens.filter(
        (t) =>
          t.revokedAt === null &&
          (where.userId ? t.userId === where.userId : true) &&
          (where.tokenHash ? t.tokenHash === where.tokenHash : true),
      );
      hits.forEach((t) => Object.assign(t, data));
      return Promise.resolve({ count: hits.length });
    },
    deleteMany: ({ where }: { where: { tokenHash: string } }) => {
      const before = this.tokens.length;
      this.tokens = this.tokens.filter((t) => t.tokenHash !== where.tokenHash);
      return Promise.resolve({ count: before - this.tokens.length });
    },
  };
}

let prisma: FakePrisma;
let service: AuthService;

beforeEach(() => {
  prisma = new FakePrisma();
  service = new AuthService(
    prisma as unknown as PrismaService,
    new JwtService({ secret: 'test-secret', signOptions: { expiresIn: '15m' } }),
  );
});

async function registeredTokens() {
  return service.register({
    email: 'a@b.de',
    password: 'password123',
    firstName: 'A',
    lastName: 'B',
  });
}

describe('Refresh-Token-Rotation', () => {
  it('register/login liefern Access- UND Refresh-Token', async () => {
    const t = await registeredTokens();
    expect(t.accessToken).toBeTruthy();
    expect(t.refreshToken).toBeTruthy();
    expect(prisma.tokens).toHaveLength(1);
    // Nur der Hash wird gespeichert, nie der Klartext.
    expect(prisma.tokens[0].tokenHash).not.toBe(t.refreshToken);
  });

  it('refresh rotiert: altes Token wird widerrufen, neues ausgestellt', async () => {
    const first = await registeredTokens();

    const second = await service.refresh(first.refreshToken);

    expect(second.refreshToken).not.toBe(first.refreshToken);
    expect(prisma.tokens).toHaveLength(2);
    expect(prisma.tokens[0].revokedAt).not.toBeNull(); // alt widerrufen
    expect(prisma.tokens[1].revokedAt).toBeNull(); // neu aktiv
  });

  it('Wiederverwendung eines rotierten Tokens widerruft ALLE Tokens', async () => {
    const first = await registeredTokens();
    await service.refresh(first.refreshToken); // rotiert -> first ist widerrufen

    await expect(service.refresh(first.refreshToken)).rejects.toBeInstanceOf(UnauthorizedException);
    // Diebstahl-Indikator: auch das frische Token ist jetzt widerrufen.
    expect(prisma.tokens.every((t) => t.revokedAt !== null)).toBe(true);
  });

  it('abgelaufenes Token wird abgelehnt', async () => {
    const t = await registeredTokens();
    prisma.tokens[0].expiresAt = new Date(Date.now() - 1000);

    await expect(service.refresh(t.refreshToken)).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('unbekanntes Token wird abgelehnt', async () => {
    await expect(service.refresh('x'.repeat(64))).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('logout löscht genau das übergebene Token; andere Geräte bleiben aktiv', async () => {
    const a = await registeredTokens();
    const b = await service.login({ email: 'a@b.de', password: 'password123' });

    await service.logout(a.refreshToken);

    // a ist gelöscht -> Reuse ist "unbekannt", KEIN Diebstahl-Trigger:
    await expect(service.refresh(a.refreshToken)).rejects.toBeInstanceOf(UnauthorizedException);
    // b funktioniert weiterhin (kein Revoke-All durch den Logout-Race).
    await expect(service.refresh(b.refreshToken)).resolves.toBeTruthy();
  });
});
