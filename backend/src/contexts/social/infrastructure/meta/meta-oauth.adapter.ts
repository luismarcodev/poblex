import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type {
  ManagedPage,
  OAuthTokenExchange,
  RefreshedToken,
  SocialOAuthPort,
} from '../../domain/ports/social-oauth.port';
import { MetaGraphHttpClient } from './meta-graph-http.client';

const OAUTH_DIALOG_BASE = 'https://www.facebook.com/v21.0/dialog/oauth';

// Permisos mínimos para el flujo: leer las Páginas administradas, publicar
// en ellas, y publicar contenido en la cuenta de Instagram Business
// vinculada. Cada uno de estos requiere aprobación de Meta App Review antes
// de funcionar contra cuentas reales que no sean de prueba del propio
// desarrollador.
const OAUTH_SCOPES = [
  'pages_show_list',
  'pages_read_engagement',
  'pages_manage_posts',
  'instagram_basic',
  'instagram_content_publish',
].join(',');

interface TokenResponse {
  access_token: string;
  expires_in: number;
}

interface ManagedPagesResponse {
  data: Array<{ id: string; name: string; access_token: string }>;
}

interface InstagramLookupResponse {
  instagram_business_account?: { id: string };
}

@Injectable()
export class MetaOAuthAdapter implements SocialOAuthPort {
  constructor(
    private readonly http: MetaGraphHttpClient,
    private readonly config: ConfigService,
  ) {}

  buildAuthorizeUrl(state: string): string {
    const url = new URL(OAUTH_DIALOG_BASE);
    url.searchParams.set('client_id', this.appId());
    url.searchParams.set('redirect_uri', this.redirectUri());
    url.searchParams.set('state', state);
    url.searchParams.set('scope', OAUTH_SCOPES);
    url.searchParams.set('response_type', 'code');
    return url.toString();
  }

  async exchangeCodeForToken(code: string): Promise<OAuthTokenExchange> {
    // Paso 1: código → token corto.
    const short = await this.http.get<TokenResponse>('/oauth/access_token', {
      client_id: this.appId(),
      client_secret: this.appSecret(),
      redirect_uri: this.redirectUri(),
      code,
    });

    // Paso 2: token corto → token de larga duración (~60 días).
    const long = await this.http.get<TokenResponse>('/oauth/access_token', {
      grant_type: 'fb_exchange_token',
      client_id: this.appId(),
      client_secret: this.appSecret(),
      fb_exchange_token: short.access_token,
    });

    return {
      userAccessToken: long.access_token,
      expiresInSeconds: long.expires_in,
    };
  }

  async listManagedPages(userAccessToken: string): Promise<ManagedPage[]> {
    const result = await this.http.get<ManagedPagesResponse>('/me/accounts', {
      access_token: userAccessToken,
    });
    return result.data.map((page) => ({
      pageId: page.id,
      pageName: page.name,
      pageAccessToken: page.access_token,
    }));
  }

  async getInstagramBusinessAccountId(
    pageId: string,
    pageAccessToken: string,
  ): Promise<string | null> {
    const result = await this.http.get<InstagramLookupResponse>(`/${pageId}`, {
      fields: 'instagram_business_account',
      access_token: pageAccessToken,
    });
    return result.instagram_business_account?.id ?? null;
  }

  async refreshLongLivedToken(currentToken: string): Promise<RefreshedToken> {
    const result = await this.http.get<TokenResponse>('/oauth/access_token', {
      grant_type: 'fb_exchange_token',
      client_id: this.appId(),
      client_secret: this.appSecret(),
      fb_exchange_token: currentToken,
    });
    return {
      accessToken: result.access_token,
      expiresInSeconds: result.expires_in,
    };
  }

  private appId(): string {
    return this.required('META_APP_ID');
  }

  private appSecret(): string {
    return this.required('META_APP_SECRET');
  }

  private redirectUri(): string {
    return this.required('META_OAUTH_REDIRECT_URI');
  }

  private required(key: string): string {
    const value = this.config.get<string>(key);
    if (!value) throw new Error(`${key} is not configured`);
    return value;
  }
}
