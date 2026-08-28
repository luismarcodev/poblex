import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ListManagedIncidentsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ required: false, enum: ['recibido', 'en_curso', 'resuelta'] })
  @IsOptional()
  @IsIn(['recibido', 'en_curso', 'resuelta'])
  status?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;

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

export class ChangeIncidentStatusDto {
  @ApiProperty({ enum: ['recibido', 'en_curso', 'resuelta'] })
  @IsIn(['recibido', 'en_curso', 'resuelta'])
  status!: string;

  @ApiProperty({
    required: false,
    maxLength: 1000,
    description: 'Nota del gestor. Queda registrada en el historial.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}
