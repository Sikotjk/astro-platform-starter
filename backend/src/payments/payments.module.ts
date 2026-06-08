import { Logger, Module, Provider } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { PAYMENT_GATEWAY, STRIPE_CLIENT } from './payment.tokens';
import { StripePaymentGateway } from './stripe.gateway';
import { FakePaymentGateway } from './fake.gateway';
import type { PaymentGateway } from './payment.gateway';

const logger = new Logger('PaymentsModule');

// Stripe-Client (oder null, falls kein Key gesetzt — z.B. lokaler Start).
const stripeProvider: Provider = {
  provide: STRIPE_CLIENT,
  inject: [ConfigService],
  useFactory: (config: ConfigService): Stripe | null => {
    const key = config.get<string>('STRIPE_SECRET_KEY');
    return key ? new Stripe(key) : null;
  },
};

// PaymentGateway: echtes Stripe wenn Client vorhanden, sonst In-Memory-Fake.
const gatewayProvider: Provider = {
  provide: PAYMENT_GATEWAY,
  inject: [STRIPE_CLIENT],
  useFactory: (stripe: Stripe | null): PaymentGateway => {
    if (stripe) return new StripePaymentGateway(stripe);
    logger.warn('STRIPE_SECRET_KEY fehlt — verwende FakePaymentGateway (nur Dev/Test!).');
    return new FakePaymentGateway();
  },
};

@Module({
  imports: [ConfigModule],
  providers: [stripeProvider, gatewayProvider],
  exports: [PAYMENT_GATEWAY, STRIPE_CLIENT],
})
export class PaymentsModule {}
