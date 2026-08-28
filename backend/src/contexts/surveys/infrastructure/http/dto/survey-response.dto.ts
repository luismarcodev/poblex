import { ApiProperty } from '@nestjs/swagger';

export class SurveyOptionResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  label!: { es?: string; va?: string };

  @ApiProperty()
  position!: number;

  @ApiProperty({
    nullable: true,
    description: 'Null mientras los resultados no sean visibles.',
  })
  votes!: number | null;
}

export class SurveyResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  question!: { es?: string; va?: string };

  @ApiProperty()
  closesAt!: string;

  @ApiProperty()
  isOpen!: boolean;

  @ApiProperty({
    description:
      'Las encuestas no son vinculantes: no hay verificación de empadronamiento.',
    default: false,
  })
  binding!: boolean;

  @ApiProperty({ type: [SurveyOptionResponseDto] })
  options!: SurveyOptionResponseDto[];

  @ApiProperty({
    nullable: true,
    description: 'Opción votada por este dispositivo, si votó.',
  })
  votedOptionId!: string | null;
}

export class SurveyListResponseDto {
  @ApiProperty({ type: [SurveyResponseDto] })
  items!: SurveyResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
