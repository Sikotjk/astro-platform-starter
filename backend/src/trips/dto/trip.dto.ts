import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Min,
} from 'class-validator';

export enum CustomsCategoryDto {
  DOCUMENTS = 'DOCUMENTS',
  CLOTHING = 'CLOTHING',
  FOOD_DRY = 'FOOD_DRY',
  ELECTRONICS = 'ELECTRONICS',
  MEDICINE = 'MEDICINE',
  GIFTS = 'GIFTS',
  COSMETICS = 'COSMETICS',
  OTHER = 'OTHER',
}

export class CreateTripDto {
  @IsString()
  @Length(3, 3)
  originAirport!: string;

  @IsString()
  @Length(3, 3)
  destinationAirport!: string;

  @IsOptional()
  @IsString()
  departureGate?: string;

  @IsDateString()
  departureAt!: string;

  @IsOptional()
  @IsDateString()
  arrivalAt?: string;

  @IsNumber()
  @Min(0.1)
  capacityKgTotal!: number;

  @IsNumber()
  @Min(0)
  pricePerKg!: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsArray()
  @IsEnum(CustomsCategoryDto, { each: true })
  acceptedCategories?: CustomsCategoryDto[];

  @IsOptional()
  @IsString()
  notes?: string;
}

export class SearchTripsDto {
  @IsOptional()
  @IsString()
  @Length(3, 3)
  originAirport?: string;

  @IsOptional()
  @IsString()
  @Length(3, 3)
  destinationAirport?: string;

  @IsOptional()
  @IsDateString()
  departureFrom?: string;

  @IsOptional()
  @IsDateString()
  departureTo?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  minFreeKg?: number;
}
