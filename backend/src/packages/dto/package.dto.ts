import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { DeclarationItemDto } from '../../customs/dto/declaration.dto';

export class CreatePackageDto {
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  title!: string;

  @IsNumber()
  @Min(0.1)
  @Max(100)
  weightKg!: number;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  dimensionsCm?: string;

  @IsNumber()
  @Min(0)
  @Max(1_000_000)
  declaredValueEur!: number;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  recipientName!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(40)
  recipientPhone!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  recipientCity!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => DeclarationItemDto)
  items!: DeclarationItemDto[];
}
