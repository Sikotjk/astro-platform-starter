import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<{ accessToken: string; userId: string }> {
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

    return { accessToken: await this.sign(user.id, user.role), userId: user.id };
  }

  async login(dto: LoginDto): Promise<{ accessToken: string; userId: string }> {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user?.passwordHash || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Ungültige Anmeldedaten.');
    }
    return { accessToken: await this.sign(user.id, user.role), userId: user.id };
  }

  private sign(userId: string, role: string): Promise<string> {
    return this.jwt.signAsync({ sub: userId, role });
  }
}
