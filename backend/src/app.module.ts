import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TripsModule } from './trips/trips.module';
import { RequestsModule } from './requests/requests.module';
import { PackagesModule } from './packages/packages.module';
import { CustomsModule } from './customs/customs.module';
import { BookingsModule } from './bookings/bookings.module';
import { KycModule } from './kyc/kyc.module';
import { ManifestPdfModule } from './manifest-pdf/manifest-pdf.module';
import { ChatModule } from './chat/chat.module';
import { ReviewsModule } from './reviews/reviews.module';
import { DisputesModule } from './disputes/disputes.module';
import { AlertsModule } from './alerts/alerts.module';
import { PushModule } from './push/push.module';
import { UsersModule } from './users/users.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    // Globales Rate-Limit (In-Memory, pro Instanz). Großzügiger Default für
    // normale API-Nutzung; sensible Endpunkte (Auth, Zoll, Manifest) setzen
    // per @Throttle strengere Limits. Greift app-weit über den APP_GUARD.
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 200 }]),
    PrismaModule,
    AuthModule,
    UsersModule,
    TripsModule,
    RequestsModule,
    PackagesModule,
    CustomsModule,
    BookingsModule,
    KycModule,
    ManifestPdfModule,
    ChatModule,
    ReviewsModule,
    DisputesModule,
    AlertsModule,
    PushModule,
    HealthModule,
  ],
  providers: [
    // Rate-Limiting app-weit erzwingen (statt nur am AuthController).
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
