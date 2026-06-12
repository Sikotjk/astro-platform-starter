import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { RequestsService } from './requests.service';
import { CreatePackageRequestDto, CreateOfferDto, SearchRequestsDto } from './dto/request.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('requests')
export class RequestsController {
  constructor(private readonly requests: RequestsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: AuthUser, @Body() dto: CreatePackageRequestDto) {
    return this.requests.create(user.userId, dto);
  }

  @Get()
  search(@Query() query: SearchRequestsDto) {
    return this.requests.search(query);
  }

  // Muss VOR @Get(':id') stehen, sonst fängt ':id' "mine" ab.
  @Get('mine')
  @UseGuards(JwtAuthGuard)
  listMine(@CurrentUser() user: AuthUser) {
    return this.requests.listMine(user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.requests.findOne(id);
  }

  // ── Angebote ────────────────────────────────────────────────────────────────

  @Post(':id/offers')
  @UseGuards(JwtAuthGuard)
  createOffer(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: CreateOfferDto) {
    return this.requests.createOffer(user.userId, id, dto);
  }

  @Get(':id/offers')
  @UseGuards(JwtAuthGuard)
  listOffers(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.requests.listOffers(user.userId, id);
  }

  @Post(':id/offers/:offerId/accept')
  @UseGuards(JwtAuthGuard)
  acceptOffer(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Param('offerId') offerId: string,
  ) {
    return this.requests.acceptOffer(user.userId, id, offerId);
  }
}
