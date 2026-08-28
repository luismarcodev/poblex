import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class CreateFacilityDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  name!: LocalizedTextDto;

  @ApiProperty({ type: LocalizedTextDto, required: false })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description?: LocalizedTextDto;

  @ApiProperty({ example: 'Pádel' })
  @IsString()
  category!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiProperty({ minimum: 1, maximum: 480 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(480)
  slotDurationMinutes!: number;

  // Validación de forma profunda (mon..sun, {open,close}|null) en el
  // dominio (OpeningHours.create) — aquí solo se comprueba que sea un
  // objeto, mismo criterio que LocalizedTextDto delega en LocalizedText.
  @ApiProperty({
    example: {
      mon: { open: '09:00', close: '22:00' },
      tue: { open: '09:00', close: '22:00' },
      wed: { open: '09:00', close: '22:00' },
      thu: { open: '09:00', close: '22:00' },
      fri: { open: '09:00', close: '22:00' },
      sat: { open: '09:00', close: '14:00' },
      sun: null,
    },
  })
  @IsObject()
  openingHours!: Record<string, { open: string; close: string } | null>;

  @ApiProperty({ type: LocalizedTextDto, required: false })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  feeNote?: LocalizedTextDto;

  @ApiProperty({ required: false, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  maxAdvanceBookingDays?: number;
}

export class UpdateFacilityDto {
  @ApiProperty({ type: LocalizedTextDto, required: false })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  name?: LocalizedTextDto;

  @ApiProperty({ type: LocalizedTextDto, required: false, nullable: true })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description?: LocalizedTextDto | null;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsString()
  imageUrl?: string | null;

  @ApiProperty({ required: false, minimum: 1, maximum: 480 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(480)
  slotDurationMinutes?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsObject()
  openingHours?: Record<string, { open: string; close: string } | null>;

  @ApiProperty({ type: LocalizedTextDto, required: false, nullable: true })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  feeNote?: LocalizedTextDto | null;

  @ApiProperty({ required: false, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  maxAdvanceBookingDays?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

export class ListFacilitiesQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;
}

export class FacilityAvailabilityQueryDto {
  @ApiProperty({ example: '2026-08-20' })
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'date must be YYYY-MM-DD' })
  date!: string;
}
