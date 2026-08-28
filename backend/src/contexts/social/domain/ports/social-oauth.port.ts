export interface OAuthTokenExchange {
  userAccessToken: string;
  expiresInSeconds: number;
}

// Página de Facebook administrada por el usuario que completó el login —
// cada una puede tener (o no) una cuenta de Instagram Business vinculada.
export interface ManagedPage {
  pageId: string;
  pageName: string;
  pageAccessToken: string;
}

export interface RefreshedToken {
  accessToken: string;
  expiresInSeconds: number;
}

// El dominio no sabe que Meta existe — solo conoce el flujo abstracto de
// "Login for Business": autorizar, intercambiar código, listar páginas
// administradas, resolver la cuenta de Instagram vinculada, refrescar.
export interface SocialOAuthPort {
  buildAuthorizeUrl(state: string): string;

  exchangeCodeForToken(code: string): Promise<OAuthTokenExchange>;

  listManagedPages(userAccessToken: string): Promise<ManagedPage[]>;

  // Null si esa Página no tiene una cuenta de Instagram Business vinculada.
  getInstagramBusinessAccountId(
    pageId: string,
    pageAccessToken: string,
  ): Promise<string | null>;

  refreshLongLivedToken(currentToken: string): Promise<RefreshedToken>;
}

export const SOCIAL_OAUTH_PORT = Symbol('SOCIAL_OAUTH_PORT');
