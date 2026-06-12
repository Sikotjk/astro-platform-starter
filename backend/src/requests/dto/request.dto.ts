import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { CustomsCategoryDto } from '../../trips/dto/trip.dto';

/** Ein Liefer-Wunsch, den ein Sender auf dem Board veröffentlicht. */
export class CreatePackageRequestDto {
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  title!: string;

  @IsString()
  @Length(3, 3)
  originAirport!: string;

  @IsString()
  @Length(3, 3)
  destinationAirport!: string;

  @IsOptional()
  @IsDateString()
  desiredByDate?: string;

  @IsNumber()
  @Min(0.1)
  @Max(100)
  weightKg!: number;

  @IsNumber()
  @Min(0)
  @Max(100_000)
  rewardOffered!: number;

  @IsOptional()
  @IsString()
  @Length(3, 3)
  currency?: string;

  @IsOptional()
  @IsEnum(CustomsCategoryDto)
  category?: CustomsCategoryDto;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}

/** Angebot eines Reisenden auf einen Wunsch. */
export class CreateOfferDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;
}

/** Filter für das öffentliche Wunsch-Board. */
export class SearchRequestsDto {
  @IsOptional()
  @IsString()
  @Length(3, 3)
  originAirport?: string;

  @IsOptional()
  @IsString()
  @Length(3, 3)
  destinationAirport?: string;
}
