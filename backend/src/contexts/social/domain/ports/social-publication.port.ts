import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialPublication } from '../entities/social-publication.entity';
import { SocialPlatform } from '../value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../value-objects/social-publication-status.vo';

export interface CreateSocialPublicationParams {
  newsId: string;
  municipalityId: MunicipalityId;
  platform: SocialPlatform;
}

export interface UpdateSocialPublicationStatusParams {
  status: SocialPublicationStatus;
  containerId?: string;
  externalPostId?: string;
  lastError?: string | null;
  publishedAt?: Date;
}

export interface SocialPublicationReaderPort {
  findByNews(newsId: string): Promise<SocialPublication[]>;

  // Barrido del cron de avance de Instagram: todo lo que sigue en curso.
  findPendingInstagram(): Promise<SocialPublication[]>;
}

export interface SocialPublicationWriterPort {
  // Upsert sobre @@unique([newsId, platform]): un reintento reutiliza la
  // misma fila en vez de acumular intentos duplicados.
  create(params: CreateSocialPublicationParams): Promise<SocialPublication>;

  updateStatus(
    id: string,
    fields: UpdateSocialPublicationStatusParams,
  ): Promise<SocialPublication>;
}

export const SOCIAL_PUBLICATION_READER_PORT = Symbol(
  'SOCIAL_PUBLICATION_READER_PORT',
);
export const SOCIAL_PUBLICATION_WRITER_PORT = Symbol(
  'SOCIAL_PUBLICATION_WRITER_PORT',
);
