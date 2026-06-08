import { Logger } from '@nestjs/common';
import type { PushMessage, PushSender, PushSendResult } from './push.sender';

// Reale Implementierung: POSTet die Nachricht an ein konfigurierbares
// Push-Relay (PUSH_WEBHOOK_URL). Ein Relay entkoppelt das Backend von den
// Anbieter-SDKs (FCM/APNs) und deren Credentials. Best-effort: Fehler werden
// geloggt, aber nicht geworfen (Push ist nicht geschäftskritisch).
export class HttpPushSender implements PushSender {
  private readonly logger = new Logger('HttpPushSender');

  constructor(private readonly webhookUrl: string) {}

  async send(message: PushMessage): Promise<PushSendResult> {
    if (message.tokens.length === 0) return { sent: 0 };
    try {
      const res = await fetch(this.webhookUrl, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(message),
      });
      if (!res.ok) {
        this.logger.warn(`Push-Relay antwortete mit ${res.status}`);
        return { sent: 0 };
      }
      return { sent: message.tokens.length };
    } catch (e) {
      this.logger.warn(`Push-Versand fehlgeschlagen: ${(e as Error).message}`);
      return { sent: 0 };
    }
  }
}
