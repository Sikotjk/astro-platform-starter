import { Module } from '@nestjs/common';
import { PackagesService } from './packages.service';
import { PackagesController } from './packages.controller';
import { CustomsModule } from '../customs/customs.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [CustomsModule, AuthModule],
  controllers: [PackagesController],
  providers: [PackagesService],
})
export class PackagesModule {}
