import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { LoginDto, RefreshDto, RegisterDto } from './dto/auth.dto';

// Strenges Rate-Limit gegen Brute-Force: 20 Requests/Minute je IP und Route.
// Der ThrottlerGuard läuft global (APP_GUARD); hier nur das schärfere Limit.
@Controller('auth')
@Throttle({ default: { ttl: 60_000, limit: 20 } })
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  /** Rotiert ein Refresh-Token gegen ein frisches Token-Paar. */
  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  /** Widerruft das Refresh-Token dieses Geräts (Logout). */
  @Post('logout')
  logout(@Body() dto: RefreshDto) {
    return this.auth.logout(dto.refreshToken);
  }
}
