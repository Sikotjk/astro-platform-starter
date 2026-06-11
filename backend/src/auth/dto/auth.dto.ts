import { IsEmail, IsEnum, IsOptional, IsString, MinLength } from 'class-validator';

export enum RegisterRole {
  SENDER = 'SENDER',
  TRAVELER = 'TRAVELER',
  BOTH = 'BOTH',
}

export class RegisterDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsString()
  firstName!: string;

  @IsString()
  lastName!: string;

  @IsOptional()
  @IsEnum(RegisterRole)
  role?: RegisterRole;

  @IsOptional()
  @IsString()
  preferredLocale?: string;
}

export class LoginDto {
  @IsEmail()
  email!: string;

  @IsString()
  password!: string;
}

export class RefreshDto {
  @IsString()
  @MinLength(32)
  refreshToken!: string;
}
