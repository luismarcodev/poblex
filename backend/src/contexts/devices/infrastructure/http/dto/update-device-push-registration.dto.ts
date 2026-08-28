import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString } from 'class-validator';

export class UpdateDevicePushRegistrationDto {
  @ApiProperty({ required: false, enum: ['es', 'va'] })
  @IsOptional()
  @IsIn(['es', 'va'])
  locale?: string;

  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsString()
  fcmToken?: string | null;
}
