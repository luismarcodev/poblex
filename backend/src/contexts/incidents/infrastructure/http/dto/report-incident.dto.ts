import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ReportIncidentDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ example: 'alumbrado' })
  @IsString()
  category!: string;

  @ApiProperty({ minLength: 1, maxLength: 2000 })
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  description!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  lat?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  lng?: number;
}

export class ListMyIncidentsQueryDto {
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
