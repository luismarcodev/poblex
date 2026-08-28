import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsDate,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';
import { parseQueryBoolean } from '../../../../../shared/infrastructure/http/transformers/query-boolean';
import { IsPaginationCursor } from '../../../../../shared/infrastructure/http/validators/pagination-cursor.validator';

export class ListSurveysQueryDto {
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

export class SurveyDetailQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

export class VoteDto {
  @ApiProperty()
  @IsUUID('4')
  optionId!: string;
}

export class CreateSurveyDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  question!: LocalizedTextDto;

  @ApiProperty({ type: String, format: 'date-time' })
  @Type(() => Date)
  @IsDate()
  closesAt!: Date;

  @ApiProperty({ required: false, default: true })
  @IsOptional()
  @IsBoolean()
  resultsVisible?: boolean;

  @ApiProperty({ type: [LocalizedTextDto], minItems: 2 })
  @IsArray()
  @ArrayMinSize(2)
  @ValidateNested({ each: true })
  @Type(() => LocalizedTextDto)
  options!: LocalizedTextDto[];
}

export class SetResultsVisibilityDto {
  @ApiProperty()
  @IsBoolean()
  visible!: boolean;
}
