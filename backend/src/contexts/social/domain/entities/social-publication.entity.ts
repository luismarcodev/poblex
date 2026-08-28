import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialPlatform } from '../value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../value-objects/social-publication-status.vo';

export interface SocialPublicationProps {
  id: string;
  newsId: string;
  municipalityId: MunicipalityId;
  platform: SocialPlatform;
  status: SocialPublicationStatus;
  containerId: string | null;
  externalPostId: string | null;
  lastError: string | null;
  attemptCount: number;
  createdAt: Date;
  publishedAt: Date | null;
}

// Un intento de publicación saliente de UNA noticia hacia UNA plataforma.
// Reintentable: no se crea una fila nueva por cada intento, se actualiza el
// estado de la existente (ver @@unique([newsId, platform]) en el schema).
export class SocialPublication {
  private constructor(private readonly props: SocialPublicationProps) {}

  static create(props: SocialPublicationProps): SocialPublication {
    return new SocialPublication(props);
  }

  get id(): string {
    return this.props.id;
  }

  get newsId(): string {
    return this.props.newsId;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get platform(): SocialPlatform {
    return this.props.platform;
  }

  get status(): SocialPublicationStatus {
    return this.props.status;
  }

  get containerId(): string | null {
    return this.props.containerId;
  }

  get externalPostId(): string | null {
    return this.props.externalPostId;
  }

  get lastError(): string | null {
    return this.props.lastError;
  }

  get attemptCount(): number {
    return this.props.attemptCount;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get publishedAt(): Date | null {
    return this.props.publishedAt;
  }
}
