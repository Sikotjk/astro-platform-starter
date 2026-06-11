import { Module, Provider } from '@nestjs/common';
import { BookingsController } from './bookings.controller';
import { StripeWebhookController } from './webhook.controller';
import { BookingsService } from './bookings.service';
import { BookingService } from './booking.service';
import { PrismaBookingRepository } from './booking.repository.prisma';
import { PaymentsModule } from '../payments/payments.module';
import { PAYMENT_GATEWAY } from '../payments/payment.tokens';
import { AuthModule } from '../auth/auth.module';
import type { PaymentGateway } from '../payments/payment.gateway';

// Domain-BookingService aus PrismaBookingRepository + PaymentGateway zusammensetzen.
const domainBookingProvider: Provider = {
  provide: BookingService,
  inject: [PrismaBookingRepository, PAYMENT_GATEWAY],
  useFactory: (repo: PrismaBookingRepository, gateway: PaymentGateway) =>
    new BookingService(repo, gateway),
};

@Module({
  imports: [PaymentsModule, AuthModule],
  controllers: [BookingsController, StripeWebhookController],
  providers: [BookingsService, PrismaBookingRepository, domainBookingProvider],
  exports: [BookingService], // wird vom DisputesModule für Admin-Übergänge genutzt
})
export class BookingsModule {}
