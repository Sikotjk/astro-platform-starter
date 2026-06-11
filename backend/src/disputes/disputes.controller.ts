import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { DisputesService } from './disputes.service';
import { OpenDisputeDto, ResolveDisputeDto } from './dto/dispute.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { RolesGuard } from '../common/roles.guard';
import { Roles } from '../common/roles.decorator';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller()
export class DisputesController {
  constructor(private readonly disputes: DisputesService) {}

  /** Beteiligter eröffnet einen Streitfall mit Begründung. */
  @Post('bookings/:id/dispute')
  @UseGuards(JwtAuthGuard)
  open(@CurrentUser() u: AuthUser, @Param('id') id: string, @Body() dto: OpenDisputeDto) {
    return this.disputes.open(u.userId, u.role, id, dto.reason);
  }

  /** Admin: offene Streitfälle. */
  @Get('admin/disputes')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  list() {
    return this.disputes.listOpen();
  }

  /** Admin: Streitfall auflösen (REFUND an Sender oder RELEASE an Traveler). */
  @Post('admin/disputes/:bookingId/resolve')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  resolve(
    @CurrentUser() u: AuthUser,
    @Param('bookingId') bookingId: string,
    @Body() dto: ResolveDisputeDto,
  ) {
    return this.disputes.resolve(u.userId, bookingId, dto.resolution, dto.note);
  }
}
