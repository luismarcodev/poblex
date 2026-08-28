import { createHmac, timingSafeEqual } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface OAuthStatePayload {
  managerId: string;
  municipalityId: string;
  platform: string;
  exp: number;
}

// Vida corta a propósito: el state solo tiene que sobrevivir al redirect de
// ida y vuelta a Meta, nunca se reutiliza.
const STATE_TTL_MS = 10 * 60 * 1000;

// Protección CSRF del callback público (`/social/oauth/callback` no lleva
// guard porque lo invoca Meta, no el gestor autenticado) — firmado con
// META_APP_SECRET, que ya es un secreto exclusivo del backend, distinto de
// la clave de cifrado de tokens.
@Injectable()
export class SocialOAuthStateService {
  constructor(private readonly config: ConfigService) {}

  sign(payload: Omit<OAuthStatePayload, 'exp'>): string {
    const full: OAuthStatePayload = {
      ...payload,
      exp: Date.now() + STATE_TTL_MS,
    };
    const encoded = Buffer.from(JSON.stringify(full)).toString('base64url');
    return `${encoded}.${this.hmac(encoded)}`;
  }

  verify(state: string): OAuthStatePayload | null {
    const [encoded, signature] = state.split('.');
    if (!encoded || !signature) return null;

    const expected = this.hmac(encoded);
    const provided = Buffer.from(signature);
    const wanted = Buffer.from(expected);
    if (
      provided.length !== wanted.length ||
      !timingSafeEqual(provided, wanted)
    ) {
      return null;
    }

    const payload = JSON.parse(
      Buffer.from(encoded, 'base64url').toString('utf8'),
    ) as OAuthStatePayload;
    if (payload.exp < Date.now()) return null;
    return payload;
  }

  private hmac(data: string): string {
    const secret = this.config.get<string>('META_APP_SECRET');
    if (!secret) throw new Error('META_APP_SECRET is not configured');
    return createHmac('sha256', secret).update(data).digest('base64url');
  }
}
