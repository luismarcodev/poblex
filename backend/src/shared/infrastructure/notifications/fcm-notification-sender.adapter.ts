import { createSign } from 'node:crypto';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type {
  NotificationSenderPort,
  SendToTokensParams,
  SendToTokensResult,
  SendToTopicParams,
} from './notification-sender.port';

const OAUTH_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const TOKEN_TTL_SECONDS = 3600;
// Margen para no usar un token que caduca mientras vuela la petición.
const TOKEN_REFRESH_MARGIN_MS = 60_000;

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id?: string;
}

interface OAuthTokenResponse {
  access_token: string;
  expires_in: number;
}

// Respuesta de error de la API FCM v1. Solo interesa el status: UNREGISTERED
// e INVALID_ARGUMENT identifican tokens muertos que hay que purgar.
interface FcmErrorResponse {
  error?: { status?: string; message?: string };
}

const DEAD_TOKEN_STATUSES = new Set(['UNREGISTERED', 'INVALID_ARGUMENT']);

function base64url(input: string | Buffer): string {
  return Buffer.from(input).toString('base64url');
}

// Adaptador de Firebase Cloud Messaging (HTTP v1).
//
// Firma el JWT del service account con node:crypto y lo canjea por un access
// token OAuth2. Se hace a mano en vez de traer firebase-admin (~15 MB y un
// árbol de dependencias entero) porque lo único que se necesita del SDK es
// esto: firmar, canjear y hacer un POST.
@Injectable()
export class FcmNotificationSenderAdapter implements NotificationSenderPort {
  private readonly logger = new Logger(FcmNotificationSenderAdapter.name);
  private readonly serviceAccount: ServiceAccount | null;
  private readonly projectId: string;
  private cachedToken: { value: string; expiresAtMs: number } | null = null;

  constructor(config: ConfigService) {
    const raw = config.get<string>('FCM_CREDENTIALS_JSON');
    this.serviceAccount = raw
      ? (JSON.parse(raw) as ServiceAccount)
      : /* istanbul ignore next */ null;
    this.projectId =
      config.get<string>('FCM_PROJECT_ID') ??
      this.serviceAccount?.project_id ??
      '';
  }

  async sendToTopic(params: SendToTopicParams): Promise<void> {
    await this.send({
      topic: params.topic,
      notification: { title: params.title, body: params.body },
      data: params.data,
    });
  }

  async sendToTokens(params: SendToTokensParams): Promise<SendToTokensResult> {
    // La API v1 no tiene envío por lote desde que se retiró /batch: un POST
    // por token, en paralelo, y se recogen los muertos.
    const outcomes = await Promise.all(
      params.tokens.map(async (token) => {
        const status = await this.send({
          token,
          notification: { title: params.title, body: params.body },
          data: params.data,
        });
        return {
          token,
          isDead: status !== null && DEAD_TOKEN_STATUSES.has(status),
        };
      }),
    );

    return {
      invalidTokens: outcomes
        .filter((outcome) => outcome.isDead)
        .map((outcome) => outcome.token),
    };
  }

  // Devuelve el `status` del error de FCM si lo hubo, o null si fue bien.
  // Un fallo de push nunca tumba el caso de uso que lo disparó: se registra.
  private async send(message: Record<string, unknown>): Promise<string | null> {
    if (!this.serviceAccount || !this.projectId) {
      this.logger.warn('FCM not configured — skipping push');
      return null;
    }

    try {
      const accessToken = await this.getAccessToken();
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ message }),
        },
      );

      if (response.ok) return null;

      const payload = (await response.json()) as FcmErrorResponse;
      const status = payload.error?.status ?? `HTTP_${response.status}`;
      this.logger.error(
        `FCM send failed (${status}): ${payload.error?.message ?? ''}`,
      );
      return status;
    } catch (error) {
      this.logger.error(`FCM send threw: ${String(error)}`);
      return null;
    }
  }

  private async getAccessToken(): Promise<string> {
    const now = Date.now();
    if (this.cachedToken && this.cachedToken.expiresAtMs > now) {
      return this.cachedToken.value;
    }

    const account = this.serviceAccount!;
    const issuedAt = Math.floor(now / 1000);
    const header = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
    const claims = base64url(
      JSON.stringify({
        iss: account.client_email,
        scope: FCM_SCOPE,
        aud: OAUTH_TOKEN_URL,
        iat: issuedAt,
        exp: issuedAt + TOKEN_TTL_SECONDS,
      }),
    );
    const signer = createSign('RSA-SHA256');
    signer.update(`${header}.${claims}`);
    const signature = signer.sign(account.private_key).toString('base64url');

    const response = await fetch(OAUTH_TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: `${header}.${claims}.${signature}`,
      }),
    });

    if (!response.ok) {
      throw new Error(`FCM OAuth exchange failed: HTTP ${response.status}`);
    }

    const token = (await response.json()) as OAuthTokenResponse;
    this.cachedToken = {
      value: token.access_token,
      expiresAtMs: now + token.expires_in * 1000 - TOKEN_REFRESH_MARGIN_MS,
    };
    return token.access_token;
  }
}
