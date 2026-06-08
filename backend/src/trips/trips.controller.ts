import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { TripsService } from './trips.service';
import { CreateTripDto, SearchTripsDto } from './dto/trip.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('trips')
export class TripsController {
  constructor(private readonly trips: TripsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateTripDto) {
    return this.trips.create(user.userId, dto);
  }

  @Get()
  search(@Query() query: SearchTripsDto) {
    return this.trips.search(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.trips.findOne(id);
  }
}
