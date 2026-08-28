import { ApiProperty } from '@nestjs/swagger';

export class DeviceResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty()
  locale!: string;
}
