import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/review.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller()
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  /** Bewertung zu einer abgeschlossenen Buchung abgeben. */
  @Post('bookings/:id/review')
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() u: AuthUser, @Param('id') bookingId: string, @Body() dto: CreateReviewDto) {
    return this.reviews.create(u.userId, bookingId, dto);
  }

  /** Öffentliches Bewertungsprofil eines Nutzers. */
  @Get('users/:id/reviews')
  list(@Param('id') userId: string) {
    return this.reviews.listForUser(userId);
  }
}
