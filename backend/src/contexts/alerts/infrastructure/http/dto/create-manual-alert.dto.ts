import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class CreateManualAlertDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty({ enum: ['amarillo', 'naranja', 'rojo'] })
  @IsIn(['amarillo', 'naranja', 'rojo'])
  severity!: string;

  @ApiProperty({
    enum: ['incendio', 'evacuacion', 'meteorologico', 'sanitario', 'otro'],
  })
  @IsIn(['incendio', 'evacuacion', 'meteorologico', 'sanitario', 'otro'])
  phenomenonType!: string;

  @ApiProperty({ example: 'Lluvias' })
  @IsString()
  phenomenon!: string;

  @ApiProperty({ type: LocalizedTextDto })
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  body!: LocalizedTextDto;

  @ApiProperty({ type: String, format: 'date-time' })
  @Type(() => Date)
  @IsDate()
  startAt!: Date;

  @ApiProperty({ required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endAt?: Date;
}

export class UpdateManualAlertDto {
  @ApiProperty({ required: false, enum: ['amarillo', 'naranja', 'rojo'] })
  @IsOptional()
  @IsIn(['amarillo', 'naranja', 'rojo'])
  severity?: string;

  @ApiProperty({
    required: false,
    enum: ['incendio', 'evacuacion', 'meteorologico', 'sanitario', 'otro'],
  })
  @IsOptional()
  @IsIn(['incendio', 'evacuacion', 'meteorologico', 'sanitario', 'otro'])
  phenomenonType?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  phenomenon?: string;

  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  body?: LocalizedTextDto;

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
}
