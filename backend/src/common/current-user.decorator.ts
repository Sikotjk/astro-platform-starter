import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { AuthUser } from './jwt-auth.guard';

/** Injiziert den authentifizierten User (aus dem JWT) in Controller-Methoden. */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    return ctx.switchToHttp().getRequest().user;
  },
);
