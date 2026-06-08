import { Module } from '@nestjs/common';
import { AlertsController } from './alerts.controller';
import { SavedSearchService } from './saved-search.service';
import { NotificationsService } from './notifications.service';
import { AlertDispatcherService } from './alert-dispatcher.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [AlertsController],
  providers: [SavedSearchService, NotificationsService, AlertDispatcherService],
  exports: [AlertDispatcherService], // TripsModule löst darüber Benachrichtigungen aus
})
export class AlertsModule {}
