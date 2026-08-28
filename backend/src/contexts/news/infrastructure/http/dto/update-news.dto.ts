import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional, IsString, IsUrl, ValidateNested } from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class UpdateNewsDto {
  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  title?: LocalizedTextDto;

  @ApiProperty({ required: false, type: LocalizedTextDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedTextDto)
  body?: LocalizedTextDto;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiProperty({ required: false, nullable: true, type: String })
  @IsOptional()
  @IsUrl()
  imageUrl?: string | null;
}
