import Stripe from 'stripe';
import type {
  IdentityGateway,
  CreateVerificationInput,
  CreateVerificationResult,
} from './identity.gateway';

export class StripeIdentityGateway implements IdentityGateway {
  constructor(private readonly stripe: Stripe) {}

  async createVerificationSession(
    input: CreateVerificationInput,
  ): Promise<CreateVerificationResult> {
    const session = await this.stripe.identity.verificationSessions.create(
      {
        type: 'document',
        provided_details: { email: input.email },
        metadata: { userId: input.userId },
      },
      { idempotencyKey: `kyc_${input.userId}` },
    );

    if (!session.client_secret) {
      throw new Error('Stripe Identity lieferte kein client_secret.');
    }
    return {
      sessionId: session.id,
      clientSecret: session.client_secret,
      url: session.url ?? undefined,
    };
  }
}
