import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ChatService } from './chat.service';
import { SendMessageDto } from './dto/message.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

// REST-Fallback für Verlauf & Senden (Echtzeit läuft über das WebSocket-Gateway).
@Controller('bookings/:id/messages')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chat: ChatService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Param('id') bookingId: string) {
    return this.chat.listMessages(u.userId, bookingId);
  }

  @Post()
  send(@CurrentUser() u: AuthUser, @Param('id') bookingId: string, @Body() dto: SendMessageDto) {
    return this.chat.sendMessage(u.userId, bookingId, dto);
  }
}
