import { defineConfig } from 'vitest/config';
import swc from 'unplugin-swc';

// E2E-Integrationstests: booten die echte Nest-App gegen eine echte PostgreSQL.
// Erfordern DATABASE_URL. Ohne Stripe-Keys nutzt die App die Fake-Gateways.
//
// SWC-Transform ist nötig, damit Decorator-Metadaten (emitDecoratorMetadata)
// erzeugt werden — sonst kann NestJS die DI zur Laufzeit nicht auflösen.
export default defineConfig({
  plugins: [swc.vite({ module: { type: 'es6' } })],
  test: {
    include: ['src/**/*.e2e-spec.ts'],
    fileParallelism: false,
    sequence: { concurrent: false },
    testTimeout: 30000,
    hookTimeout: 60000,
  },
});
