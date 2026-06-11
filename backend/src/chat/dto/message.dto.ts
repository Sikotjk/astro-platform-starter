import { IsOptional, IsString, IsUrl, MaxLength, MinLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  body!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  @IsUrl({ require_tld: false, require_protocol: true })
  attachmentUrl?: string;
}
