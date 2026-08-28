import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEmail,
  IsOptional,
  IsString,
  IsUrl,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class UpdateBusinessDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiProperty({ required: false, nullable: true, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  description?: LocalizedTextDto | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsString()
  address?: string | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsString()
  phone?: string | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsEmail()
  email?: string | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsUrl()
  website?: string | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsString()
  schedule?: string | null;
}
