import { IsEnum, IsString, MinLength } from 'class-validator';

export enum DevicePlatformDto {
  IOS = 'IOS',
  ANDROID = 'ANDROID',
  WEB = 'WEB',
}

export class RegisterDeviceDto {
  @IsString()
  @MinLength(10)
  token!: string;

  @IsEnum(DevicePlatformDto)
  platform!: DevicePlatformDto;
}
