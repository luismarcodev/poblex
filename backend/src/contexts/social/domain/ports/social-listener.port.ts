import { SocialAccountWithToken } from './social-account-reader.port';

// Forma abstracta de un post detectado — el dominio no sabe que Meta
// existe, igual que WeatherWarning no sabe que AEMET existe.
export interface InboundSocialPost {
  externalId: string;
  caption: string | null;
  imageUrl: string | null;
  permalink: string;
  publishedAt: Date;
}

export interface SocialListenerPort {
  fetchRecentPosts(
    account: SocialAccountWithToken,
    since?: Date,
  ): Promise<InboundSocialPost[]>;
}

export const SOCIAL_LISTENER_PORT = Symbol('SOCIAL_LISTENER_PORT');
