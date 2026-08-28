import { ApiProperty } from '@nestjs/swagger';

export class EventResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  title!: { es?: string; va?: string };

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  description!: { es?: string; va?: string };

  @ApiProperty()
  startAt!: string;

  @ApiProperty({ nullable: true })
  endAt!: string | null;

  @ApiProperty({ nullable: true })
  locationName!: string | null;

  @ApiProperty({ nullable: true })
  lat!: number | null;

  @ApiProperty({ nullable: true })
  lng!: number | null;

  @ApiProperty()
  category!: string;
}

export class EventListResponseDto {
  @ApiProperty({ type: [EventResponseDto] })
  items!: EventResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
