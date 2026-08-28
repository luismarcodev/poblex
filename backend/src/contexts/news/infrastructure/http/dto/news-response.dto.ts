import { ApiProperty } from '@nestjs/swagger';
import { LocalizedTextDto } from '../../../../../shared/infrastructure/http/dto/localized-text.dto';

export class NewsAttachmentResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  url!: string;

  @ApiProperty()
  mimeType!: string;
}

export class NewsResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ type: LocalizedTextDto })
  title!: LocalizedTextDto;

  @ApiProperty({ type: LocalizedTextDto })
  body!: LocalizedTextDto;

  @ApiProperty({ nullable: true, type: String })
  imageUrl!: string | null;

  @ApiProperty()
  category!: string;

  @ApiProperty()
  pinned!: boolean;

  @ApiProperty()
  publishedAt!: string;

  @ApiProperty()
  archived!: boolean;

  @ApiProperty({ type: [NewsAttachmentResponseDto] })
  attachments!: NewsAttachmentResponseDto[];
}

// Solo para el gestor: el origen de una noticia importada de redes sociales
// no le interesa al vecino, así que el DTO público (NewsResponseDto) no lo
// lleva. Ver news-social-share.port.ts para el porqué de la separación.
export class ManagedNewsResponseDto extends NewsResponseDto {
  @ApiProperty({
    required: false,
    nullable: true,
    enum: ['instagram', 'facebook'],
  })
  sourcePlatform!: string | null;

  @ApiProperty({ required: false, nullable: true, type: String })
  sourceExternalPostId!: string | null;
}
