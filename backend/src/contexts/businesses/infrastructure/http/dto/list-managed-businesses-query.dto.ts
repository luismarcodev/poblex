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

export class ListManagedBusinessesQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({
    required: false,
    description: 'Incluye los comercios desactivados.',
  })
  @IsOptional()
  @Transform(parseQueryBoolean)
  @IsBoolean()
  includeInactive?: boolean;

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

export class SetActiveDto {
  @ApiProperty()
  @IsBoolean()
  active!: boolean;
}
