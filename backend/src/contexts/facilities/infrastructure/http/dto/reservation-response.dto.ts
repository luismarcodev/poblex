import { ApiProperty } from '@nestjs/swagger';

export class ReservationResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  facilityId!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty()
  slotStart!: string;

  @ApiProperty()
  slotEnd!: string;
}

export class ReservationListResponseDto {
  @ApiProperty({ type: [ReservationResponseDto] })
  items!: ReservationResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
