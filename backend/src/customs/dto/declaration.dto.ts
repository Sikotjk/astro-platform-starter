import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export enum DeclarationCategory {
  DOCUMENTS = 'DOCUMENTS',
  CLOTHING = 'CLOTHING',
  FOOD_DRY = 'FOOD_DRY',
  ELECTRONICS = 'ELECTRONICS',
  MEDICINE = 'MEDICINE',
  GIFTS = 'GIFTS',
  COSMETICS = 'COSMETICS',
  OTHER = 'OTHER',
}

export class DeclarationItemDto {
  @IsEnum(DeclarationCategory)
  category!: DeclarationCategory;

  @IsString()
  @MinLength(3)
  description!: string;

  @IsNumber()
  @Min(1)
  quantity!: number;

  @IsNumber()
  @Min(0)
  unitValueEur!: number;

  @IsBoolean()
  isSealed!: boolean;
}

export class EvaluateDeclarationDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => DeclarationItemDto)
  items!: DeclarationItemDto[];

  @IsOptional()
  @IsIn(['de', 'ru', 'tg'])
  locale?: 'de' | 'ru' | 'tg';
}
