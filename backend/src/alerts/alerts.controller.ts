import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { SavedSearchService } from './saved-search.service';
import { NotificationsService } from './notifications.service';
import { CreateSavedSearchDto, ListNotificationsDto } from './dto/alerts.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class AlertsController {
  constructor(
    private readonly savedSearches: SavedSearchService,
    private readonly notifications: NotificationsService,
  ) {}

  @Post('saved-searches')
  createSearch(@CurrentUser() u: AuthUser, @Body() dto: CreateSavedSearchDto) {
    return this.savedSearches.create(u.userId, dto);
  }

  @Get('saved-searches')
  listSearches(@CurrentUser() u: AuthUser) {
    return this.savedSearches.list(u.userId);
  }

  @Delete('saved-searches/:id')
  removeSearch(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.savedSearches.remove(u.userId, id);
  }

  @Get('notifications')
  listNotifications(@CurrentUser() u: AuthUser, @Query() q: ListNotificationsDto) {
    return this.notifications.list(u.userId, q.unread === 'true');
  }

  @Post('notifications/read-all')
  readAll(@CurrentUser() u: AuthUser) {
    return this.notifications.markAllRead(u.userId);
  }

  @Post('notifications/:id/read')
  read(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.notifications.markRead(u.userId, id);
  }
}
