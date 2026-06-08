import type { DeviceTokenRepository } from './device-token.repository';

export class InMemoryDeviceTokenRepository implements DeviceTokenRepository {
  private readonly byUser = new Map<string, string[]>();

  add(userId: string, token: string): void {
    const list = this.byUser.get(userId) ?? [];
    list.push(token);
    this.byUser.set(userId, list);
  }

  async findTokensForUsers(userIds: string[]): Promise<string[]> {
    return userIds.flatMap((id) => this.byUser.get(id) ?? []);
  }
}
