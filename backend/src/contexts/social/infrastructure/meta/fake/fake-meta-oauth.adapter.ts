import { Injectable } from '@nestjs/common';
import type {
  ManagedPage,
  OAuthTokenExchange,
  RefreshedToken,
  SocialOAuthPort,
} from '../../../domain/ports/social-oauth.port';

// Adaptador de desarrollo: ninguna llamada real a Meta. Se activa cuando
// META_APP_ID no está configurado (ver social.module.ts), lo que desbloquea
// todo el resto del sistema sin esperar la aprobación real de la app de
// Meta, que tarda semanas. Nunca se usa en producción.
@Injectable()
export class FakeMetaOAuthAdapter implements SocialOAuthPort {
  buildAuthorizeUrl(state: string): string {
    return `https://fake-meta.local/oauth/authorize?state=${encodeURIComponent(state)}`;
  }

  exchangeCodeForToken(code: string): Promise<OAuthTokenExchange> {
    return Promise.resolve({
      userAccessToken: `fake-user-token-${code}`,
      expiresInSeconds: 60 * 24 * 3600, // ~60 días, como un long-lived token real
    });
  }

  listManagedPages(userAccessToken: string): Promise<ManagedPage[]> {
    return Promise.resolve([
      {
        pageId: `fake-page-${userAccessToken.slice(-6)}`,
        pageName: 'Ayuntamiento (cuenta de prueba)',
        pageAccessToken: `fake-page-token-${userAccessToken.slice(-6)}`,
      },
    ]);
  }

  getInstagramBusinessAccountId(pageId: string): Promise<string | null> {
    return Promise.resolve(`fake-ig-${pageId}`);
  }

  refreshLongLivedToken(currentToken: string): Promise<RefreshedToken> {
    return Promise.resolve({
      accessToken: `${currentToken}-refreshed`,
      expiresInSeconds: 60 * 24 * 3600,
    });
  }
}
