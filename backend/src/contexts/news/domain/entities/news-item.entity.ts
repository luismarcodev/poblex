import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsCategory } from '../value-objects/news-category.vo';
import { NewsAttachment } from './news-attachment.entity';

export interface NewsItemProps {
  id: string;
  municipalityId: MunicipalityId;
  title: LocalizedText;
  body: LocalizedText;
  imageUrl: string | null;
  category: NewsCategory;
  pinned: boolean;
  publishedAt: Date;
  archived: boolean;
  attachments: NewsAttachment[];
  // Origen cuando la noticia proviene de una publicación importada de redes
  // sociales (contexto `social`) — null en el resto, creadas por el gestor.
  sourcePlatform: string | null;
  sourceExternalPostId: string | null;
}

export class NewsItem {
  private constructor(private readonly props: NewsItemProps) {}

  static create(props: NewsItemProps): NewsItem {
    return new NewsItem(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get title(): LocalizedText {
    return this.props.title;
  }

  get body(): LocalizedText {
    return this.props.body;
  }

  get imageUrl(): string | null {
    return this.props.imageUrl;
  }

  get category(): NewsCategory {
    return this.props.category;
  }

  get pinned(): boolean {
    return this.props.pinned;
  }

  get publishedAt(): Date {
    return this.props.publishedAt;
  }

  get archived(): boolean {
    return this.props.archived;
  }

  get attachments(): NewsAttachment[] {
    return this.props.attachments;
  }

  get sourcePlatform(): string | null {
    return this.props.sourcePlatform;
  }

  get sourceExternalPostId(): string | null {
    return this.props.sourceExternalPostId;
  }
}
