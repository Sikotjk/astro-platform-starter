import { Logger, Module, Provider } from '@nestjs/common';
import Stripe from 'stripe';
import { KycController } from './kyc.controller';
import { KycWebhookController } from './kyc-webhook.controller';
import { KycService } from './kyc.service';
import { PrismaKycRepository } from './prisma-kyc.repository';
import { StripeIdentityGateway } from './stripe-identity.gateway';
import { FakeIdentityGateway } from './fake-identity.gateway';
import { IDENTITY_GATEWAY } from './identity.tokens';
import { PaymentsModule } from '../payments/payments.module';
import { STRIPE_CLIENT } from '../payments/payment.tokens';
import { AuthModule } from '../auth/auth.module';
import type { IdentityGateway } from './identity.gateway';

const logger = new Logger('KycModule');

const identityProvider: Provider = {
  provide: IDENTITY_GATEWAY,
  inject: [STRIPE_CLIENT],
  useFactory: (stripe: Stripe | null): IdentityGateway => {
    if (stripe) return new StripeIdentityGateway(stripe);
    logger.warn('STRIPE_SECRET_KEY fehlt — verwende FakeIdentityGateway (nur Dev/Test!).');
    return new FakeIdentityGateway();
  },
};

const kycServiceProvider: Provider = {
  provide: KycService,
  inject: [PrismaKycRepository, IDENTITY_GATEWAY],
  useFactory: (repo: PrismaKycRepository, gateway: IdentityGateway) =>
    new KycService(repo, gateway),
};

@Module({
  imports: [PaymentsModule, AuthModule],
  controllers: [KycController, KycWebhookController],
  providers: [PrismaKycRepository, identityProvider, kycServiceProvider],
})
export class KycModule {}
