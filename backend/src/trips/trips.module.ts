import { Module } from '@nestjs/common';
import { TripsService } from './trips.service';
import { TripsController } from './trips.controller';
import { AuthModule } from '../auth/auth.module';
import { AlertsModule } from '../alerts/alerts.module';

@Module({
  imports: [AuthModule, AlertsModule],
  controllers: [TripsController],
  providers: [TripsService],
  exports: [TripsService],
})
export class TripsModule {}
