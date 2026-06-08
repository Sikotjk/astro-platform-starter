import { describe, it, expect, beforeEach } from 'vitest';
import { KycService, KycStateError, KycUserNotFoundError } from './kyc.service';
import { InMemoryKycRepository } from './in-memory.kyc.repository';
import { FakeIdentityGateway } from './fake-identity.gateway';

let repo: InMemoryKycRepository;
let gateway: FakeIdentityGateway;
let service: KycService;

beforeEach(() => {
  repo = new InMemoryKycRepository();
  gateway = new FakeIdentityGateway();
  service = new KycService(repo, gateway);
  repo.seed({ id: 'u1', email: 'a@b.de', kycStatus: 'NOT_STARTED', kycSessionId: null });
});

describe('startVerification', () => {
  it('erstellt eine Session und setzt PENDING', async () => {
    const res = await service.startVerification('u1');
    expect(res.clientSecret).toContain('secret');
    expect(res.sessionId).toMatch(/^vs_fake_/);
    expect(await service.getStatus('u1')).toBe('PENDING');
    expect(gateway.created).toHaveLength(1);
  });

  it('wirft, wenn bereits verifiziert', async () => {
    repo.seed({ id: 'u2', email: 'c@d.de', kycStatus: 'VERIFIED', kycSessionId: 'vs_x' });
    await expect(service.startVerification('u2')).rejects.toThrow(KycStateError);
  });

  it('wirft bei unbekanntem User', async () => {
    await expect(service.startVerification('nope')).rejects.toThrow(KycUserNotFoundError);
  });
});

describe('handleEvent (Webhook)', () => {
  it('setzt VERIFIED bei verified-Event', async () => {
    const { sessionId } = await service.startVerification('u1');
    const r = await service.handleEvent('evt_1', 'identity.verification_session.verified', sessionId);
    expect(r).toMatchObject({ processed: true, status: 'VERIFIED' });
    expect(await service.getStatus('u1')).toBe('VERIFIED');
  });

  it('setzt REJECTED bei requires_input', async () => {
    const { sessionId } = await service.startVerification('u1');
    await service.handleEvent('evt_2', 'identity.verification_session.requires_input', sessionId);
    expect(await service.getStatus('u1')).toBe('REJECTED');
  });

  it('ist idempotent (dasselbe Event zweimal)', async () => {
    const { sessionId } = await service.startVerification('u1');
    const first = await service.handleEvent('evt_dup', 'identity.verification_session.verified', sessionId);
    const second = await service.handleEvent('evt_dup', 'identity.verification_session.verified', sessionId);
    expect(first.processed).toBe(true);
    expect(second.processed).toBe(false);
  });

  it('ignoriert unbekannte Eventtypen ohne Statusänderung', async () => {
    const { sessionId } = await service.startVerification('u1');
    await service.handleEvent('evt_x', 'identity.verification_session.created', sessionId);
    expect(await service.getStatus('u1')).toBe('PENDING');
  });

  it('überschreibt einen bereits verifizierten Status nicht', async () => {
    const { sessionId } = await service.startVerification('u1');
    await service.handleEvent('evt_v', 'identity.verification_session.verified', sessionId);
    await service.handleEvent('evt_c', 'identity.verification_session.canceled', sessionId);
    expect(await service.getStatus('u1')).toBe('VERIFIED');
  });
});
