import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ListBusinessesQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({
    required: false,
    description:
      'Filtra por categoría. El slug lo valida el dominio: uno inventado da 400.',
    example: 'bar',
  })
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

// El detalle exige municipio: el aislamiento entre municipios no es opcional
// ni siquiera para contenido público.
export class BusinessDetailQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

export class BusinessCategoriesQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}
