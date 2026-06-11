import { Module } from '@nestjs/common';
import { DisputesService } from './disputes.service';
import { DisputesController } from './disputes.controller';
import { RolesGuard } from '../common/roles.guard';
import { BookingsModule } from '../bookings/bookings.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [BookingsModule, AuthModule], // BookingsModule exportiert die Domain-BookingService
  controllers: [DisputesController],
  providers: [DisputesService, RolesGuard],
})
export class DisputesModule {}
