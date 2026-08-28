import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialPlatform } from '../value-objects/social-platform.vo';

export type SocialAccountStatusKind =
  'connected' | 'expired' | 'error' | 'revoked';

export interface SocialAccountProps {
  id: string;
  municipalityId: MunicipalityId;
  platform: SocialPlatform;
  externalAccountId: string;
  accountName: string;
  tokenExpiresAt: Date;
  status: SocialAccountStatusKind;
  lastErrorMessage: string | null;
  connectedByManagerId: string;
  connectedAt: Date;
  lastRefreshedAt: Date | null;
}

// El access token NUNCA vive en esta entidad de dominio — solo el
// repositorio Prisma lo toca (cifrado en la columna, descifrado bajo
// demanda), y únicamente para pasarlo directo a la llamada HTTP a Meta.
export class SocialAccount {
  private constructor(private readonly props: SocialAccountProps) {}

  static create(props: SocialAccountProps): SocialAccount {
    if (props.externalAccountId.trim().length === 0) {
      throw new ValidationError(
        'SocialAccount.externalAccountId must not be empty',
      );
    }
    if (props.accountName.trim().length === 0) {
      throw new ValidationError('SocialAccount.accountName must not be empty');
    }
    return new SocialAccount(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get platform(): SocialPlatform {
    return this.props.platform;
  }

  get externalAccountId(): string {
    return this.props.externalAccountId;
  }

  get accountName(): string {
    return this.props.accountName;
  }

  get tokenExpiresAt(): Date {
    return this.props.tokenExpiresAt;
  }

  get status(): SocialAccountStatusKind {
    return this.props.status;
  }

  get lastErrorMessage(): string | null {
    return this.props.lastErrorMessage;
  }

  get connectedByManagerId(): string {
    return this.props.connectedByManagerId;
  }

  get connectedAt(): Date {
    return this.props.connectedAt;
  }

  get lastRefreshedAt(): Date | null {
    return this.props.lastRefreshedAt;
  }

  get isUsable(): boolean {
    return this.props.status === 'connected';
  }

  expiresWithin(days: number): boolean {
    const threshold = new Date(Date.now() + days * 86_400_000);
    return this.props.tokenExpiresAt <= threshold;
  }
}
