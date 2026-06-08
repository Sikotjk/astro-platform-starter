import { Logger, Module, Provider } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PushController } from './push.controller';
import { DeviceTokenService } from './device-token.service';
import { PushService } from './push.service';
import { PrismaDeviceTokenRepository } from './prisma-device-token.repository';
import { HttpPushSender } from './http.push-sender';
import { FakePushSender } from './fake.push-sender';
import { PUSH_SENDER, DEVICE_TOKEN_REPOSITORY } from './push.tokens';
import { AuthModule } from '../auth/auth.module';
import type { PushSender } from './push.sender';

const logger = new Logger('PushModule');

// Realer Sender, falls PUSH_WEBHOOK_URL gesetzt ist, sonst Fake (Dev/Test).
const senderProvider: Provider = {
  provide: PUSH_SENDER,
  inject: [ConfigService],
  useFactory: (config: ConfigService): PushSender => {
    const url = config.get<string>('PUSH_WEBHOOK_URL');
    if (url) return new HttpPushSender(url);
    logger.warn('PUSH_WEBHOOK_URL fehlt — verwende FakePushSender (nur Dev/Test!).');
    return new FakePushSender();
  },
};

const repoProvider: Provider = {
  provide: DEVICE_TOKEN_REPOSITORY,
  useClass: PrismaDeviceTokenRepository,
};

@Module({
  imports: [ConfigModule, AuthModule],
  controllers: [PushController],
  providers: [DeviceTokenService, PushService, senderProvider, repoProvider],
  exports: [PushService],
})
export class PushModule {}
