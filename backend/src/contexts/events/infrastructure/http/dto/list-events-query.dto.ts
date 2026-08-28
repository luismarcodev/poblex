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

export class ListEventsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

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

export class EventDetailQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

export class ListManagedEventsQueryDto extends ListEventsQueryDto {
  @ApiProperty({
    required: false,
    description: 'Incluye eventos ya celebrados.',
  })
  @IsOptional()
  @Transform(parseQueryBoolean)
  @IsBoolean()
  includePast?: boolean;
}
