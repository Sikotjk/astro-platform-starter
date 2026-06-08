// Port über den Push-Anbieter (FCM/APNs bzw. ein Push-Relay). Hält PushService
// testbar (FakePushSender) und den Anbieter austauschbar.

export interface PushMessage {
  /** Geräte-Tokens der Empfänger. */
  tokens: string[];
  title: string;
  body: string;
  /** Optionale Datennutzlast (z.B. { type: 'TRIP_MATCH', tripId }). */
  data?: Record<string, string>;
}

export interface PushSendResult {
  sent: number;
}

export interface PushSender {
  send(message: PushMessage): Promise<PushSendResult>;
}
