import { IsNumber, IsString, Min } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  tripId!: string;

  @IsString()
  packageId!: string;

  @IsNumber()
  @Min(0.1)
  agreedWeightKg!: number;
}
