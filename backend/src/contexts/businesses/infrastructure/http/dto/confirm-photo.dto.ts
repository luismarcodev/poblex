import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUrl } from 'class-validator';

export class ConfirmPhotoDto {
  @ApiProperty()
  @IsUrl()
  url!: string;

  @ApiProperty()
  @IsString()
  mimeType!: string;
}
