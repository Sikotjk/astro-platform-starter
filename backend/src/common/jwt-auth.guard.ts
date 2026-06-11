import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';

export interface AuthUser {
  userId: string;
  role: string;
}

/** Liest "Authorization: Bearer <token>", verifiziert es und legt req.user ab. */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request & { user?: AuthUser }>();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Kein Bearer-Token.');
    }
    try {
      const payload = await this.jwt.verifyAsync<{ sub: string; role: string }>(header.slice(7));
      req.user = { userId: payload.sub, role: payload.role };
      return true;
    } catch {
      throw new UnauthorizedException('Token ungültig oder abgelaufen.');
    }
  }
}
