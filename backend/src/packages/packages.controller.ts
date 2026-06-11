import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { PackagesService } from './packages.service';
import { CreatePackageDto } from './dto/package.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('packages')
@UseGuards(JwtAuthGuard)
export class PackagesController {
  constructor(private readonly packages: PackagesService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreatePackageDto) {
    return this.packages.create(user.userId, dto);
  }
}
