import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  MinLength,
} from 'class-validator';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class CreateReservationDto {
  @ApiProperty()
  @IsUUID('4')
  facilityId!: string;

  @ApiProperty({ type: String, format: 'date-time' })
  @Type(() => Date)
  @IsDate()
  slotStart!: Date;
}

export class ListMyReservationsQueryDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @IsPaginationCursor()
  cursor?: string;

  @ApiProperty({ required: false, minimum: 1, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;
}

export class ListManagedReservationsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID('4')
  facilityId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @IsPaginationCursor()
  cursor?: string;

  @ApiProperty({ required: false, minimum: 1, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;
}

export class CancelReservationAsManagerDto {
  @ApiProperty({ minLength: 1 })
  @IsString()
  @MinLength(1)
  note!: string;
}
