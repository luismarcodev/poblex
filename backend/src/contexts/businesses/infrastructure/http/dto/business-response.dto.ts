import { ApiProperty } from '@nestjs/swagger';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class BusinessPhotoResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  url!: string;

  @ApiProperty()
  mimeType!: string;

  @ApiProperty()
  position!: number;
}

export class BusinessResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  category!: string;

  @ApiProperty({ nullable: true, type: LocalizedTextDto })
  description!: LocalizedTextDto | null;

  @ApiProperty({ nullable: true, type: String })
  address!: string | null;

  @ApiProperty({ nullable: true, type: String })
  phone!: string | null;

  @ApiProperty({ nullable: true, type: String })
  email!: string | null;

  @ApiProperty({ nullable: true, type: String })
  website!: string | null;

  @ApiProperty({ nullable: true, type: String })
  schedule!: string | null;

  @ApiProperty()
  active!: boolean;

  @ApiProperty({ type: [BusinessPhotoResponseDto] })
  photos!: BusinessPhotoResponseDto[];
}
