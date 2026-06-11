import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class OpenDisputeDto {
  @IsString()
  @MinLength(5)
  @MaxLength(1000)
  reason!: string;
}

export class ResolveDisputeDto {
  @IsIn(['REFUND', 'RELEASE'])
  resolution!: 'REFUND' | 'RELEASE';

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}
