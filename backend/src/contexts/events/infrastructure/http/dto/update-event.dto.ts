import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class UpdateEventDto {
  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title?: LocalizedTextDto;

  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description?: LocalizedTextDto;

  @ApiProperty({ required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startAt?: Date;

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

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;
}
