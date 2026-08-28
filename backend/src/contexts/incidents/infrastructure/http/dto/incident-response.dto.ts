import { ApiProperty } from '@nestjs/swagger';

export class IncidentStatusChangeDto {
  @ApiProperty({ enum: ['recibido', 'en_curso', 'resuelta'] })
  status!: string;

  @ApiProperty({ nullable: true })
  note!: string | null;

  @ApiProperty()
  changedAt!: string;
}

export class IncidentResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty()
  category!: string;

  @ApiProperty()
  description!: string;

  @ApiProperty({ nullable: true })
  photoUrl!: string | null;

  @ApiProperty({ nullable: true })
  lat!: number | null;

  @ApiProperty({ nullable: true })
  lng!: number | null;

  @ApiProperty({ enum: ['recibido', 'en_curso', 'resuelta'] })
  status!: string;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;
}

export class IncidentDetailResponseDto extends IncidentResponseDto {
  @ApiProperty({ type: [IncidentStatusChangeDto] })
  history!: IncidentStatusChangeDto[];
}

export class IncidentListResponseDto {
  @ApiProperty({ type: [IncidentResponseDto] })
  items!: IncidentResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
