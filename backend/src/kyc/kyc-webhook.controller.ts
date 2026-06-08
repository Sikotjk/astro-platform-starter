// Stripe-Identity-Webhook. Eigener Endpoint/Secret (STRIPE_IDENTITY_WEBHOOK_SECRET),
// gleiche Sicherheitsprinzipien wie der Payment-Webhook: Signatur prüfen,
// Roh-Body verwenden, idempotent verarbeiten.

import {
  BadRequestException,
  Controller,
  Headers,
  Inject,
  Logger,
  Post,
  Req,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import type { Request } from 'express';
import { STRIPE_CLIENT } from '../payments/payment.tokens';
import { KycService } from './kyc.service';

@Controller('webhooks/stripe-identity')
export class KycWebhookController {
  private readonly logger = new Logger('KycWebhook');

  constructor(
    @Inject(STRIPE_CLIENT) private readonly stripe: Stripe | null,
    private readonly config: ConfigService,
    private readonly kyc: KycService,
  ) {}

  @Post()
  async handle(
    @Req() req: Request & { rawBody?: Buffer },
    @Headers('stripe-signature') signature?: string,
  ) {
    if (!this.stripe) throw new ServiceUnavailableException('Stripe ist nicht konfiguriert.');
    const secret = this.config.get<string>('STRIPE_IDENTITY_WEBHOOK_SECRET');
    if (!secret) throw new ServiceUnavailableException('Identity-Webhook-Secret fehlt.');
    if (!req.rawBody || !signature) throw new BadRequestException('Fehlende Signatur/Body.');

    let event: Stripe.Event;
    try {
      event = this.stripe.webhooks.constructEvent(req.rawBody, signature, secret);
    } catch (err) {
      this.logger.warn(`Ungültige Signatur: ${(err as Error).message}`);
      throw new BadRequestException('Ungültige Signatur.');
    }

    if (event.type.startsWith('identity.verification_session.')) {
      const session = event.data.object as Stripe.Identity.VerificationSession;
      await this.kyc.handleEvent(event.id, event.type, session.id);
    } else {
      this.logger.debug(`Unbehandeltes Event: ${event.type}`);
    }

    return { received: true };
  }
}
