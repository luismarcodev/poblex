import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type PublicationStatusKind =
  'pending' | 'container_created' | 'processing' | 'published' | 'failed';

const ALL_STATUSES: readonly PublicationStatusKind[] = [
  'pending',
  'container_created',
  'processing',
  'published',
  'failed',
];

// Instagram usa la cadena completa (crear contenedor → procesando →
// publicado); Facebook es prácticamente síncrono y salta directo de
// "pending" a "published"/"failed" sin pasar por los intermedios. La regla
// vive aquí, en el dominio, no en el caso de uso que la invoca.
const ALLOWED_TRANSITIONS: Record<
  PublicationStatusKind,
  readonly PublicationStatusKind[]
> = {
  pending: ['container_created', 'published', 'failed'],
  container_created: ['processing', 'failed'],
  processing: ['published', 'failed'],
  published: [],
  failed: [],
};

export class SocialPublicationStatus {
  private constructor(readonly value: PublicationStatusKind) {}

  static create(value: string): SocialPublicationStatus {
    const normalized = value.trim().toLowerCase() as PublicationStatusKind;
    if (!ALL_STATUSES.includes(normalized)) {
      throw new ValidationError(`Invalid SocialPublicationStatus: "${value}"`);
    }
    return new SocialPublicationStatus(normalized);
  }

  static pending(): SocialPublicationStatus {
    return new SocialPublicationStatus('pending');
  }

  static containerCreated(): SocialPublicationStatus {
    return new SocialPublicationStatus('container_created');
  }

  static processing(): SocialPublicationStatus {
    return new SocialPublicationStatus('processing');
  }

  static published(): SocialPublicationStatus {
    return new SocialPublicationStatus('published');
  }

  static failed(): SocialPublicationStatus {
    return new SocialPublicationStatus('failed');
  }

  canTransitionTo(next: SocialPublicationStatus): boolean {
    return ALLOWED_TRANSITIONS[this.value].includes(next.value);
  }

  get isTerminal(): boolean {
    return this.value === 'published' || this.value === 'failed';
  }

  equals(other: SocialPublicationStatus): boolean {
    return this.value === other.value;
  }
}
