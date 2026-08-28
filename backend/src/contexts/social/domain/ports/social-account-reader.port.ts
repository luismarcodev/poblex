import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialAccount } from '../entities/social-account.entity';
import { SocialPlatform } from '../value-objects/social-platform.vo';

// Un token descifrado y listo para usar contra la API de Meta — la única
// forma en la que el token en claro sale del repositorio, y solo hacia el
// publicador/oyente, nunca hacia un DTO de respuesta HTTP.
export interface SocialAccountWithToken {
  account: SocialAccount;
  accessToken: string;
}

export interface SocialAccountReaderPort {
  findByMunicipality(municipalityId: MunicipalityId): Promise<SocialAccount[]>;

  findConnected(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
  ): Promise<SocialAccount | null>;

  findAccessTokenForPublishing(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
  ): Promise<SocialAccountWithToken | null>;

  // Cuentas conectadas de cualquier municipio — barrido del cron de sondeo
  // entrante, análogo a MunicipalityReaderPort.findAllWithAemetZone.
  findAllConnected(): Promise<SocialAccountWithToken[]>;

  findAllExpiringBefore(date: Date): Promise<SocialAccountWithToken[]>;
}

export const SOCIAL_ACCOUNT_READER_PORT = Symbol('SOCIAL_ACCOUNT_READER_PORT');
