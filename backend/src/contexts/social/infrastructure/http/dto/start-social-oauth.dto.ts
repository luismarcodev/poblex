import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class StartSocialOAuthDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}
