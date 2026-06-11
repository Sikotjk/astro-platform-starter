import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { CustomsService } from './customs.service';
import { EvaluateDeclarationDto } from './dto/declaration.dto';

// Öffentlicher (auth-freier) Endpunkt → strenger drosseln als der globale Default.
@Throttle({ default: { ttl: 60_000, limit: 30 } })
@Controller('customs')
export class CustomsController {
  constructor(private readonly customs: CustomsService) {}

  /**
   * Vorschau-Prüfung: Der Sender sieht VOR dem Buchen, ob sein Inhalt
   * transportierbar ist (ALLOW/WARN/BLOCK) und welche Hinweise gelten.
   */
  @Post('evaluate')
  evaluate(@Body() dto: EvaluateDeclarationDto) {
    return this.customs.evaluate(dto.items, dto.locale ?? 'de');
  }
}
