import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class UpdateDeviceMunicipalityDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}
