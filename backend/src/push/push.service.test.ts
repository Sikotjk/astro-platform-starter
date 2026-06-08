import { describe, it, expect, beforeEach } from 'vitest';
import { PushService } from './push.service';
import { FakePushSender } from './fake.push-sender';
import { InMemoryDeviceTokenRepository } from './in-memory-device-token.repository';

let repo: InMemoryDeviceTokenRepository;
let sender: FakePushSender;
let service: PushService;

beforeEach(() => {
  repo = new InMemoryDeviceTokenRepository();
  sender = new FakePushSender();
  service = new PushService(repo, sender);
});

describe('PushService.pushToUsers', () => {
  it('sendet an alle Geräte der Nutzer', async () => {
    repo.add('u1', 'tok_a');
    repo.add('u1', 'tok_b');
    repo.add('u2', 'tok_c');

    const res = await service.pushToUsers(['u1', 'u2'], { title: 'Hi', body: 'Test' });

    expect(res.sent).toBe(3);
    expect(sender.sent).toHaveLength(1);
    expect(sender.sent[0].tokens.sort()).toEqual(['tok_a', 'tok_b', 'tok_c']);
    expect(sender.sent[0].title).toBe('Hi');
  });

  it('sendet nichts, wenn die Nutzer keine Geräte haben', async () => {
    const res = await service.pushToUsers(['ghost'], { title: 'x', body: 'y' });
    expect(res.sent).toBe(0);
    expect(sender.sent).toHaveLength(0);
  });

  it('sendet nichts bei leerer Nutzerliste', async () => {
    const res = await service.pushToUsers([], { title: 'x', body: 'y' });
    expect(res.sent).toBe(0);
    expect(sender.sent).toHaveLength(0);
  });
});
