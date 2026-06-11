import { Controller, Get, Param, Query, Res, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Response } from 'express';
import { ManifestPdfService } from './manifest-pdf.service';
import { JwtAuthGuard } from '../common/jwt-auth.guard';
import { CurrentUser } from '../common/current-user.decorator';
import type { AuthUser } from '../common/jwt-auth.guard';
import type { Locale } from '../customs/customs.types';

const LOCALES: Locale[] = ['de', 'ru', 'tg'];

// PDF-Erzeugung ist rechenintensiv → strenger drosseln (Schutz vor CPU-DoS).
@Throttle({ default: { ttl: 60_000, limit: 20 } })
@Controller('bookings/:id/manifest')
@UseGuards(JwtAuthGuard)
export class ManifestPdfController {
  constructor(private readonly service: ManifestPdfService) {}

  /** Liefert das Zoll-Manifest als PDF (Schutzurkunde des Travelers am Zoll). */
  @Get()
  async download(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Query('locale') localeQuery: string | undefined,
    @Res() res: Response,
  ): Promise<void> {
    const locale: Locale = LOCALES.includes(localeQuery as Locale) ? (localeQuery as Locale) : 'de';
    const { pdf, filename, contentHash } = await this.service.generate(id, user.userId, locale);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="${filename}"`);
    res.setHeader('X-Manifest-Hash', contentHash);
    res.send(pdf);
  }
}
