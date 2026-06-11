import { Inject, Injectable } from '@nestjs/common';
import { PUSH_SENDER, DEVICE_TOKEN_REPOSITORY } from './push.tokens';
import type { PushSender } from './push.sender';
import type { DeviceTokenRepository } from './device-token.repository';

export interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class PushService {
  constructor(
    @Inject(DEVICE_TOKEN_REPOSITORY) private readonly tokens: DeviceTokenRepository,
    @Inject(PUSH_SENDER) private readonly sender: PushSender,
  ) {}

  /** Sendet einen Push an alle Geräte der angegebenen Nutzer. */
  async pushToUsers(userIds: string[], payload: PushPayload): Promise<{ sent: number }> {
    if (userIds.length === 0) return { sent: 0 };
    const tokens = await this.tokens.findTokensForUsers(userIds);
    if (tokens.length === 0) return { sent: 0 };
    return this.sender.send({ tokens, ...payload });
  }
}
