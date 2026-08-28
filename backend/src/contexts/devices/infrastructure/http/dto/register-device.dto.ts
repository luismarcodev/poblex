import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, IsUUID } from 'class-validator';

export class RegisterDeviceDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty()
  @IsIn(['es', 'va'])
  locale!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  fcmToken?: string;
}
