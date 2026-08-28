import type { CookieOptions, Response } from 'express';
import { parseDurationMs } from '../../../../shared/infrastructure/config/parse-duration';

export const REFRESH_TOKEN_COOKIE_NAME = 'poblex_refresh_token';
export const REFRESH_TOKEN_COOKIE_PATH = '/v1/admin/auth';

// El backoffice es una aplicación Flutter Web servida desde OTRO origen que la
// API. Con `sameSite: 'strict'` el navegador no adjunta la cookie en esa
// petición entre sitios y el refresh falla siempre: el gestor se ve expulsado
// en cuanto caduca el access token, sin ningún error visible.
//
// Por eso en producción va `none` + `secure` (obligatorio: los navegadores
// rechazan `sameSite: none` sin HTTPS). En desarrollo, API y backoffice viven
// ambos en localhost — mismo sitio — y `lax` es suficiente sin exigir TLS.
function cookieSecurityOptions(): Pick<CookieOptions, 'sameSite' | 'secure'> {
  return process.env.NODE_ENV === 'production'
    ? { sameSite: 'none', secure: true }
    : { sameSite: 'lax', secure: false };
}

export function setRefreshTokenCookie(res: Response, rawToken: string): void {
  res.cookie(REFRESH_TOKEN_COOKIE_NAME, rawToken, {
    httpOnly: true,
    path: REFRESH_TOKEN_COOKIE_PATH,
    maxAge: parseDurationMs(process.env.JWT_REFRESH_EXPIRES_IN ?? '30d'),
    ...cookieSecurityOptions(),
  });
}

export function clearRefreshTokenCookie(res: Response): void {
  // Los atributos deben coincidir con los del `set`, o el navegador no
  // identifica la cookie que se le pide borrar y el logout no la elimina.
  res.clearCookie(REFRESH_TOKEN_COOKIE_NAME, {
    httpOnly: true,
    path: REFRESH_TOKEN_COOKIE_PATH,
    ...cookieSecurityOptions(),
  });
}
