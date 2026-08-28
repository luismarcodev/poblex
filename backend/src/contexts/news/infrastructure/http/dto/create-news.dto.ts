import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  ArrayUnique,
  IsArray,
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  IsUrl,
  ValidateNested,
} from 'class-validator';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class CreateNewsDto {
  @ApiProperty({
    type: [String],
    minItems: 1,
    description:
      'Municipios donde publicar. Un gestor con varios puede publicar en todos de golpe.',
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
  body!: LocalizedTextDto;

  @ApiProperty()
  @IsString()
  category!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  pinned?: boolean;

  @ApiProperty({
    required: false,
    type: [String],
    enum: ['instagram', 'facebook'],
    description:
      'Redes donde publicar también esta noticia — checkbox por noticia, nunca automático.',
  })
  @IsOptional()
  @IsArray()
  @IsIn(['instagram', 'facebook'], { each: true })
  shareToChannels?: string[];
}
