import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';

export interface ShareNewsParams {
  newsId: string;
  municipalityId: string;
  platforms: string[];
  title: LocalizedText;
  body: LocalizedText;
  imageUrl?: string;
}

// El dominio de `news` no sabe que el contexto `social` existe — solo conoce
// esta forma abstracta. Implementado por un adaptador que vive en `social`,
// que es quien rompe el ciclo de módulos (news → social, nunca al revés).
export interface NewsSocialSharePort {
  shareNews(params: ShareNewsParams): Promise<void>;
}

export const NEWS_SOCIAL_SHARE_PORT = Symbol('NEWS_SOCIAL_SHARE_PORT');
