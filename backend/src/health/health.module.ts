import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';

// PrismaService ist global verfügbar (PrismaModule ist @Global).
@Module({
  controllers: [HealthController],
})
export class HealthModule {}
