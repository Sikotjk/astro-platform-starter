import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateMeDto } from './dto/update-me.dto';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';

@Controller('me')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  me(@CurrentUser() u: AuthUser) {
    return this.users.getMe(u.userId);
  }

  @Patch()
  update(@CurrentUser() u: AuthUser, @Body() dto: UpdateMeDto) {
    return this.users.updateMe(u.userId, dto);
  }
}
