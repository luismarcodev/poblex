import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEmail,
  IsOptional,
  IsString,
  IsUUID,
  IsUrl,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class CreateBusinessDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsString()
  category!: string;

  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description?: LocalizedTextDto;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUrl()
  website?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  schedule?: string;
}
