import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { DeclarationItemDto } from '../../customs/dto/declaration.dto';

export class CreatePackageDto {
  @IsString()
  @MinLength(2)
  title!: string;

  @IsNumber()
  @Min(0.1)
  weightKg!: number;

  @IsOptional()
  @IsString()
  dimensionsCm?: string;

  @IsNumber()
  @Min(0)
  declaredValueEur!: number;

  @IsString()
  recipientName!: string;

  @IsString()
  recipientPhone!: string;

  @IsString()
  recipientCity!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => DeclarationItemDto)
  items!: DeclarationItemDto[];
}
