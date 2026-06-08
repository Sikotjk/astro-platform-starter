import { IsIn, IsInt, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  tripId!: string;

  @IsString()
  packageId!: string;

  @IsNumber()
  @Min(0.1)
  agreedWeightKg!: number;
}

export class ListBookingsDto {
  @IsOptional()
  @IsIn(['SENDER', 'TRAVELER'])
  role?: 'SENDER' | 'TRAVELER';

  /** Kommaseparierter Statusfilter, z.B. "PAID,DELIVERED". */
  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  take?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  skip?: number;
}
