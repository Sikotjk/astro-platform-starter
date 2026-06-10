import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { createHash, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterDto } from './dto/auth.dto';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  userId: string;
}

/** Gültigkeit eines Refresh-Tokens (Rotation bei jeder Nutzung). */
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 Tage

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthTokens> {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('E-Mail ist bereits registriert.');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        passwordHash,
        firstName: dto.firstName,
        lastName: dto.lastName,
        role: dto.role ?? 'SENDER',
        preferredLocale: dto.preferredLocale ?? 'de',
      },
    });

    return this.issueTokens(user.id, user.role);
  }

  async login(dto: LoginDto): Promise<AuthTokens> {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user?.passwordHash || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Ungültige Anmeldedaten.');
    }
    return this.issueTokens(user.id, user.role);
  }

  /**
   * Tauscht ein gültiges Refresh-Token gegen ein frisches Token-Paar
   * (Rotation). Wird ein bereits rotiertes Token erneut vorgelegt, gilt das
   * als Diebstahl-Indikator: ALLE aktiven Tokens des Nutzers werden widerrufen.
   */
  async refresh(refreshToken: string): Promise<AuthTokens> {
    const tokenHash = this.hash(refreshToken);
    const stored = await this.prisma.refreshToken.findUnique({ where: { tokenHash } });
    if (!stored) throw new UnauthorizedException('Ungültiges Refresh-Token.');

    if (stored.revokedAt) {
      await this.prisma.refreshToken.updateMany({
        where: { userId: stored.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException('Refresh-Token wurde bereits verwendet.');
    }
    if (stored.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException('Refresh-Token ist abgelaufen.');
    }

    const user = await this.prisma.user.findUnique({ where: { id: stored.userId } });
    if (!user) throw new UnauthorizedException('Nutzer existiert nicht mehr.');

    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    return this.issueTokens(user.id, user.role);
  }

  /**
   * Logout dieses Geräts: Token wird GELÖSCHT (nicht widerrufen), damit ein
   * verspäteter Refresh-Versuch danach nicht als Diebstahl gewertet wird
   * und andere Geräte angemeldet bleiben.
   */
  async logout(refreshToken: string): Promise<{ ok: true }> {
    await this.prisma.refreshToken.deleteMany({
      where: { tokenHash: this.hash(refreshToken) },
    });
    return { ok: true };
  }

  private async issueTokens(userId: string, role: string): Promise<AuthTokens> {
    const accessToken = await this.jwt.signAsync({ sub: userId, role });
    const refreshToken = randomBytes(48).toString('base64url');
    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash: this.hash(refreshToken),
        expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
      },
    });
    return { accessToken, refreshToken, userId };
  }

  private hash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}
