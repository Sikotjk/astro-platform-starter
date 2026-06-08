// Stripe-Webhook-Endpoint. SICHERHEITSKRITISCH:
//  1. Signatur gegen STRIPE_WEBHOOK_SECRET prüfen (verhindert gefälschte Events).
//  2. Roh-Body verwenden (req.rawBody) — JSON-Parsing würde die Signatur brechen.
//  3. Idempotente Verarbeitung im BookingService (ProcessedWebhookEvent).

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
import { BookingService } from './booking.service';

@Controller('webhooks/stripe')
export class StripeWebhookController {
  private readonly logger = new Logger('StripeWebhook');

  constructor(
    @Inject(STRIPE_CLIENT) private readonly stripe: Stripe | null,
    private readonly config: ConfigService,
    private readonly bookings: BookingService,
  ) {}

  @Post()
  async handle(
    @Req() req: Request & { rawBody?: Buffer },
    @Headers('stripe-signature') signature?: string,
  ) {
    if (!this.stripe) throw new ServiceUnavailableException('Stripe ist nicht konfiguriert.');
    const secret = this.config.get<string>('STRIPE_WEBHOOK_SECRET');
    if (!secret) throw new ServiceUnavailableException('Webhook-Secret fehlt.');
    if (!req.rawBody || !signature) throw new BadRequestException('Fehlende Signatur/Body.');

    let event: Stripe.Event;
    try {
      event = this.stripe.webhooks.constructEvent(req.rawBody, signature, secret);
    } catch (err) {
      this.logger.warn(`Ungültige Webhook-Signatur: ${(err as Error).message}`);
      throw new BadRequestException('Ungültige Signatur.');
    }

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const pi = event.data.object as Stripe.PaymentIntent;
        await this.bookings.handlePaymentSucceeded(event.id, pi.id);
        break;
      }
      default:
        // Andere Events werden (noch) nicht verarbeitet — bewusst ignoriert.
        this.logger.debug(`Unbehandeltes Event: ${event.type}`);
    }

    return { received: true };
  }
}
