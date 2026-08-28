import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class PresignedUploadRequestDto {
  @ApiProperty()
  @IsString()
  fileName!: string;

  @ApiProperty()
  @IsString()
  contentType!: string;
}

export class PresignedUploadResponseDto {
  @ApiProperty()
  uploadUrl!: string;

  @ApiProperty()
  publicUrl!: string;

  @ApiProperty()
  expiresInSeconds!: number;
}
