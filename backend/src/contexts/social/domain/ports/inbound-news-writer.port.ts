import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialPlatform } from '../value-objects/social-platform.vo';

export interface CreateNewsFromSocialPostParams {
  municipalityId: MunicipalityId;
  platform: SocialPlatform;
  externalPostId: string;
  title: LocalizedText;
  body: LocalizedText;
  imageUrl?: string;
}

export interface CreatedInboundNews {
  id: string;
  title: LocalizedText;
  body: LocalizedText;
}

// Escritor mínimo y deliberadamente separado de NewsWriterPort (contexto
// `news`): la vía del gestor es autenticada, multi-municipio y bilingüe; la
// vía automática es del sistema, un único municipio, un único idioma
// detectado, sin gestor detrás. Forzarlas por el mismo puerto acoplaría dos
// flujos que no se parecen en nada salvo el destino final.
export interface InboundNewsWriterPort {
  existsBySourcePost(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
    externalPostId: string,
  ): Promise<boolean>;

  createFromSocialPost(
    params: CreateNewsFromSocialPostParams,
  ): Promise<CreatedInboundNews>;
}

export const INBOUND_NEWS_WRITER_PORT = Symbol('INBOUND_NEWS_WRITER_PORT');
