// ─────────────────────────────────────────────────────────────────────────────
//  ChatGateway — Echtzeit-Chat über socket.io
//
//  Auth: JWT im Handshake (auth.token oder ?token=). Pro Buchung ein Raum
//  ("booking:<id>"). Persistenz + Berechtigung laufen über den ChatService,
//  sodass REST und WebSocket exakt dieselben Regeln nutzen.
// ─────────────────────────────────────────────────────────────────────────────

import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';

interface AuthedSocket extends Socket {
  data: { userId?: string };
}

const room = (bookingId: string) => `booking:${bookingId}`;

@WebSocketGateway({ namespace: '/chat', cors: { origin: '*' } })
export class ChatGateway implements OnGatewayConnection {
  private readonly logger = new Logger('ChatGateway');

  @WebSocketServer()
  server!: Server;

  constructor(
    private readonly chat: ChatService,
    private readonly jwt: JwtService,
  ) {}

  async handleConnection(client: AuthedSocket): Promise<void> {
    const token =
      (client.handshake.auth?.token as string | undefined) ??
      (client.handshake.query?.token as string | undefined);
    try {
      const payload = await this.jwt.verifyAsync<{ sub: string }>(token ?? '');
      client.data.userId = payload.sub;
    } catch {
      client.emit('chat:error', { message: 'Authentifizierung fehlgeschlagen.' });
      client.disconnect(true);
    }
  }

  @SubscribeMessage('chat:join')
  async onJoin(
    @ConnectedSocket() client: AuthedSocket,
    @MessageBody() data: { bookingId: string },
  ): Promise<{ ok: boolean; error?: string }> {
    const userId = client.data.userId;
    if (!userId) return { ok: false, error: 'unauthenticated' };
    try {
      // Lesezugriff prüfen (wirft, wenn nicht beteiligt).
      await this.chat.listMessages(userId, data.bookingId);
      await client.join(room(data.bookingId));
      return { ok: true };
    } catch (e) {
      return { ok: false, error: (e as Error).message };
    }
  }

  @SubscribeMessage('chat:send')
  async onSend(
    @ConnectedSocket() client: AuthedSocket,
    @MessageBody() data: { bookingId: string; body: string; attachmentUrl?: string },
  ): Promise<{ ok: boolean; error?: string }> {
    const userId = client.data.userId;
    if (!userId) return { ok: false, error: 'unauthenticated' };
    try {
      const message = await this.chat.sendMessage(userId, data.bookingId, {
        body: data.body,
        attachmentUrl: data.attachmentUrl,
      });
      this.server.to(room(data.bookingId)).emit('chat:message', message);
      return { ok: true };
    } catch (e) {
      return { ok: false, error: (e as Error).message };
    }
  }
}
