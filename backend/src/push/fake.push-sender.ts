import type { PushMessage, PushSender, PushSendResult } from './push.sender';

// In-Memory-PushSender für Tests/Dev: protokolliert alle Sendungen.
export class FakePushSender implements PushSender {
  readonly sent: PushMessage[] = [];

  async send(message: PushMessage): Promise<PushSendResult> {
    this.sent.push(message);
    return { sent: message.tokens.length };
  }
}
