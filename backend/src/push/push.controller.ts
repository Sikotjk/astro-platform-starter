import { Body, Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { DeviceTokenService } from './device-token.service';
import { RegisterDeviceDto } from './dto/device.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('devices')
@UseGuards(JwtAuthGuard)
export class PushController {
  constructor(private readonly devices: DeviceTokenService) {}

  @Post()
  register(@CurrentUser() u: AuthUser, @Body() dto: RegisterDeviceDto) {
    return this.devices.register(u.userId, dto);
  }

  @Get()
  list(@CurrentUser() u: AuthUser) {
    return this.devices.list(u.userId);
  }

  @Delete(':id')
  remove(@CurrentUser() u: AuthUser, @Param('id') id: string) {
    return this.devices.remove(u.userId, id);
  }
}
