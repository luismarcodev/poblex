import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUrl } from 'class-validator';

export class ConfirmAttachmentDto {
  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsUrl()
  url!: string;

  @ApiProperty()
  @IsString()
  mimeType!: string;
}
