import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export class ListDutyPharmaciesQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  from?: Date;

  @ApiProperty({ required: false, minimum: 1, maximum: 60, default: 14 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(60)
  days?: number;
}

export class TodayDutyPharmacyQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

export class UpsertDutyPharmacyDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ type: String, format: 'date' })
  @Type(() => Date)
  @IsDate()
  date!: Date;

  @ApiProperty({ example: 'Farmàcia Ribera' })
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  pharmacyName!: string;

  @ApiProperty({ example: 'Carrer Major, 12' })
  @IsString()
  @MinLength(1)
  @MaxLength(300)
  address!: string;

  @ApiProperty({ example: '961 234 567' })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  phone!: string;

  @ApiProperty({ example: '9:00 - 22:00' })
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  schedule!: string;
}

export class DutyPharmacyResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ description: 'Fecha en formato ISO (solo día).' })
  date!: string;

  @ApiProperty()
  pharmacyName!: string;

  @ApiProperty()
  address!: string;

  @ApiProperty()
  phone!: string;

  @ApiProperty()
  schedule!: string;
}
