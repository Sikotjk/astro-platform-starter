import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { KycService } from './kyc.service';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('kyc')
@UseGuards(JwtAuthGuard)
export class KycController {
  constructor(private readonly kyc: KycService) {}

  /** Startet die Identitätsprüfung -> clientSecret für den Stripe-Identity-Flow. */
  @Post('session')
  start(@CurrentUser() user: AuthUser) {
    return this.kyc.startVerification(user.userId);
  }

  @Get('status')
  async status(@CurrentUser() user: AuthUser) {
    return { status: await this.kyc.getStatus(user.userId) };
  }
}
