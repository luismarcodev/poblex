import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';
import { parseQueryBoolean } from '../../../../../shared/infrastructure/http/transformers/query-boolean';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ListManagedNewsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({
    required: false,
    description: 'Incluye las noticias archivadas (más de 90 días).',
  })
  @IsOptional()
  @Transform(parseQueryBoolean)
  @IsBoolean()
  includeArchived?: boolean;

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

export class SetArchivedDto {
  @ApiProperty()
  @IsBoolean()
  archived!: boolean;
}
