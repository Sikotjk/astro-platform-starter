import {
  IsBooleanString,
  IsDateString,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Min,
} from 'class-validator';

export class CreateSavedSearchDto {
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

export class ListNotificationsDto {
  @IsOptional()
  @IsBooleanString()
  unread?: string;
}
