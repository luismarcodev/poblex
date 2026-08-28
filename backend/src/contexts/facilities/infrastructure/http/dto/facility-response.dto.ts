import { ApiProperty } from '@nestjs/swagger';

export class FacilityResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  name!: { es?: string; va?: string };

  @ApiProperty({ nullable: true })
  description!: { es?: string; va?: string } | null;

  @ApiProperty()
  category!: string;

  @ApiProperty({ nullable: true })
  imageUrl!: string | null;

  @ApiProperty()
  slotDurationMinutes!: number;

  @ApiProperty()
  openingHours!: Record<string, { open: string; close: string } | null>;

  @ApiProperty({ nullable: true })
  feeNote!: { es?: string; va?: string } | null;

  @ApiProperty()
  maxAdvanceBookingDays!: number;

  @ApiProperty()
  active!: boolean;
}

export class FacilityListResponseDto {
  @ApiProperty({ type: [FacilityResponseDto] })
  items!: FacilityResponseDto[];
}

export class AvailabilitySlotDto {
  @ApiProperty()
  start!: string;

  @ApiProperty()
  end!: string;
}

export class FacilityAvailabilityResponseDto {
  @ApiProperty({ type: [AvailabilitySlotDto] })
  slots!: AvailabilitySlotDto[];
}
