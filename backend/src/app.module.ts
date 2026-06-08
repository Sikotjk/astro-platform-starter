import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TripsModule } from './trips/trips.module';
import { PackagesModule } from './packages/packages.module';
import { CustomsModule } from './customs/customs.module';
import { BookingsModule } from './bookings/bookings.module';
import { KycModule } from './kyc/kyc.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    TripsModule,
    PackagesModule,
    CustomsModule,
    BookingsModule,
    KycModule,
  ],
})
export class AppModule {}
