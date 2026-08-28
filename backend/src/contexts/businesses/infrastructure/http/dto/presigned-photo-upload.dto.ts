import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class PresignedPhotoUploadRequestDto {
  @ApiProperty()
  @IsString()
  fileName!: string;

  @ApiProperty()
  @IsString()
  contentType!: string;
}

export class PresignedPhotoUploadResponseDto {
  @ApiProperty()
  uploadUrl!: string;

  @ApiProperty()
  publicUrl!: string;

  @ApiProperty()
  expiresInSeconds!: number;
}
