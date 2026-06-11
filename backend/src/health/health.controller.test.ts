import { describe, it, expect } from 'vitest';
import { ServiceUnavailableException } from '@nestjs/common';
import { HealthController } from './health.controller';
import type { PrismaService } from '../prisma/prisma.service';

function controllerWith(queryRaw: () => Promise<unknown>): HealthController {
  return new HealthController({ $queryRaw: queryRaw } as unknown as PrismaService);
}

describe('HealthController', () => {
  it('live() meldet ok', () => {
    const c = controllerWith(() => Promise.resolve([{ x: 1 }]));
    expect(c.live()).toEqual({ status: 'ok' });
  });

  it('ready() meldet ok, wenn die DB antwortet', async () => {
    const c = controllerWith(() => Promise.resolve([{ x: 1 }]));
    await expect(c.ready()).resolves.toEqual({ status: 'ok', db: 'up' });
  });

  it('ready() wirft 503, wenn die DB nicht erreichbar ist', async () => {
    const c = controllerWith(() => Promise.reject(new Error('no db')));
    await expect(c.ready()).rejects.toBeInstanceOf(ServiceUnavailableException);
  });
});
