import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/booking.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private readonly bookings: BookingsService) {}

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateBookingDto) {
    return this.bookings.create(u.userId, dto);
  }

  @Get(':id')
  findOne(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.findOne(u.userId, id);
  }

  @Post(':id/accept')
  accept(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.accept(u.userId, id);
  }

  @Post(':id/reject')
  reject(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'REJECTED');
  }

  /** Sender zahlt -> liefert clientSecret für Stripe. */
  @Post(':id/escrow')
  escrow(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.createEscrow(u.userId, id);
  }

  /** Traveler bestätigt Inhalt + Beförderungsbedingungen (Compliance-Gate). */
  @Post(':id/accept-terms')
  acceptTerms(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.acceptTerms(u.userId, id);
  }

  @Post(':id/handover')
  handover(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'HANDED_OVER');
  }

  @Post(':id/transit')
  transit(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'IN_TRANSIT');
  }

  @Post(':id/delivered')
  delivered(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'DELIVERED');
  }

  /** Sender bestätigt Empfang -> Escrow wird an Traveler ausgezahlt. */
  @Post(':id/confirm')
  confirm(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'CONFIRMED');
  }

  @Post(':id/cancel')
  cancel(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.bookings.transition(u.userId, u.role, id, 'CANCELLED');
  }

  // Hinweis: POST /bookings/:id/dispute liegt im DisputesController
  // (erfordert eine Begründung und legt einen Dispute-Datensatz an).
}
