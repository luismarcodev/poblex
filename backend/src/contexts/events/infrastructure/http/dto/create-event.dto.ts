import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  ArrayUnique,
  IsArray,
  IsDate,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class CreateEventDto {
  @ApiProperty({
    type: [String],
    minItems: 1,
    description: 'Municipios donde publicar el evento.',
  })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayUnique()
  @IsUUID('4', { each: true })
  municipalityIds!: string[];

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title!: LocalizedTextDto;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description!: LocalizedTextDto;

  @ApiProperty({ type: String, format: 'date-time' })
  @Type(() => Date)
  @IsDate()
  startAt!: Date;

  @ApiProperty({ required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endAt?: Date;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  locationName?: string;

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

  @ApiProperty()
  @IsString()
  category!: string;
}
