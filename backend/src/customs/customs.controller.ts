import { Body, Controller, Post } from '@nestjs/common';
import { CustomsService } from './customs.service';
import { EvaluateDeclarationDto } from './dto/declaration.dto';

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
