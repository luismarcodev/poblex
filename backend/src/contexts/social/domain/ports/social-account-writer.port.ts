import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialAccount } from '../entities/social-account.entity';
import { SocialPlatform } from '../value-objects/social-platform.vo';

export interface UpsertSocialAccountParams {
  municipalityId: MunicipalityId;
  platform: SocialPlatform;
  externalAccountId: string;
  accountName: string;
  accessToken: string;
  tokenExpiresAt: Date;
  connectedByManagerId: string;
}

export interface SocialAccountWriterPort {
  // Reemplaza cualquier cuenta ya conectada para ese municipio+plataforma
  // (UNIQUE([municipalityId, platform]) en el schema) — reconectar sustituye,
  // no duplica.
  upsertFromOAuth(params: UpsertSocialAccountParams): Promise<SocialAccount>;

  // Para AuthorizeSocialMutationService: comprobar existencia/municipio
  // antes de mutar, igual que NewsWriterPort.findAdminById.
  findAdminById(id: string): Promise<SocialAccount | null>;

  updateTokens(
    id: string,
    fields: { accessToken: string; tokenExpiresAt: Date },
  ): Promise<SocialAccount>;

  markError(id: string, message: string): Promise<SocialAccount>;

  disconnect(id: string): Promise<void>;
}

export const SOCIAL_ACCOUNT_WRITER_PORT = Symbol('SOCIAL_ACCOUNT_WRITER_PORT');
