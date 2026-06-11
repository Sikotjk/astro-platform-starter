// Port: liefert aktive Geräte-Tokens für eine Menge von Nutzern.
export interface DeviceTokenRepository {
  findTokensForUsers(userIds: string[]): Promise<string[]>;
}
