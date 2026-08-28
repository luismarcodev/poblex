import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsDate,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';
import { parseQueryBoolean } from '../../../../../shared/infrastructure/http/transformers/query-boolean';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ListFormsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @Transform(parseQueryBoolean)
  @IsBoolean()
  includeClosed?: boolean;

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

export class FormDetailQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

export class SubmissionAnswerDto {
  @ApiProperty()
  @IsUUID('4')
  fieldId!: string;

  @ApiProperty({ description: 'Valor serializado como texto.' })
  @IsString()
  value!: string;
}

export class SubmitFormDto {
  @ApiProperty({ type: [SubmissionAnswerDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SubmissionAnswerDto)
  answers!: SubmissionAnswerDto[];
}

export class CreateFormFieldDto {
  @ApiProperty({ example: 'numero_comensales' })
  @IsString()
  @Matches(/^[a-z0-9_]+$/, {
    message: 'key must be a lowercase snake_case identifier',
  })
  key!: string;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  label!: LocalizedTextDto;

  @ApiProperty({ enum: ['text', 'number', 'select', 'date', 'boolean'] })
  @IsIn(['text', 'number', 'select', 'date', 'boolean'])
  type!: string;

  @ApiProperty({ required: false, default: false })
  @IsOptional()
  @IsBoolean()
  required?: boolean;

  @ApiProperty({
    required: false,
    type: [String],
    description: 'Obligatorio en los campos de tipo select.',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  options?: string[];
}

export class CreateFormDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title!: LocalizedTextDto;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description!: LocalizedTextDto;

  @ApiProperty({ required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  deadline?: Date;

  @ApiProperty({ type: [CreateFormFieldDto], minItems: 1 })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateFormFieldDto)
  fields!: CreateFormFieldDto[];
}

export class FormFieldResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  key!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  label!: { es?: string; va?: string };

  @ApiProperty({ enum: ['text', 'number', 'select', 'date', 'boolean'] })
  type!: string;

  @ApiProperty()
  required!: boolean;

  @ApiProperty({ type: [String] })
  options!: string[];

  @ApiProperty()
  position!: number;
}

export class FormResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  title!: { es?: string; va?: string };

  @ApiProperty({ description: 'Objeto bilingüe completo {es, va}' })
  description!: { es?: string; va?: string };

  @ApiProperty({ nullable: true })
  deadline!: string | null;

  @ApiProperty()
  isOpen!: boolean;

  @ApiProperty()
  alreadySubmitted!: boolean;

  @ApiProperty({ type: [FormFieldResponseDto] })
  fields!: FormFieldResponseDto[];
}

export class FormListResponseDto {
  @ApiProperty({ type: [FormResponseDto] })
  items!: FormResponseDto[];

  @ApiProperty({ nullable: true })
  nextCursor!: string | null;
}
