import { ApiProperty } from '@nestjs/swagger';

export class AlertResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ enum: ['aemet', 'manual'] })
  source!: string;

  @ApiProperty({ enum: ['amarillo', 'naranja', 'rojo'] })
  severity!: string;

  @ApiProperty({
    enum: ['incendio', 'evacuacion', 'meteorologico', 'sanitario', 'otro'],
  })
  phenomenonType!: string;

  @ApiProperty()
  phenomenon!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  body!: { es?: string; va?: string };

  @ApiProperty()
  startAt!: string;

  @ApiProperty({ nullable: true })
  endAt!: string | null;

  @ApiProperty({
    description:
      'Cierto en alertas rojas: la app no debe filtrarla por preferencias.',
  })
  forcesNotification!: boolean;
}

export class AlertListResponseDto {
  @ApiProperty({ type: [AlertResponseDto] })
  items!: AlertResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
