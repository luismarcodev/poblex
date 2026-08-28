import { ApiProperty } from '@nestjs/swagger';

export class MunicipalityResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  province!: string;

  @ApiProperty({ nullable: true, type: String })
  primaryColor!: string | null;

  @ApiProperty({ nullable: true, type: String })
  logoUrl!: string | null;

  @ApiProperty({ type: [String] })
  languages!: string[];
}
