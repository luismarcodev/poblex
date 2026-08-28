import { Inject, Injectable, Logger } from '@nestjs/common';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { SOCIAL_ACCOUNT_READER_PORT } from '../../domain/ports/social-account-reader.port';
import type { SocialAccountReaderPort } from '../../domain/ports/social-account-reader.port';
import { SOCIAL_ACCOUNT_WRITER_PORT } from '../../domain/ports/social-account-writer.port';
import type { SocialAccountWriterPort } from '../../domain/ports/social-account-writer.port';
import { SOCIAL_OAUTH_PORT } from '../../domain/ports/social-oauth.port';
import type { SocialOAuthPort } from '../../domain/ports/social-oauth.port';

export const SOCIAL_TOKEN_REFRESH_TASK = 'social-token-refresh';

// Los tokens de larga duración de Meta caducan a los ~60 días. Refrescar los
// que caducan dentro de 7 días deja margen de sobra frente a un fallo puntual
// de la llamada de refresco.
const REFRESH_WINDOW_DAYS = 7;

export interface RefreshSocialTokensResult {
  refreshed: number;
  failed: number;
}

@Injectable()
export class RefreshSocialTokensUseCase {
  private readonly logger = new Logger(RefreshSocialTokensUseCase.name);

  constructor(
    @Inject(SOCIAL_ACCOUNT_READER_PORT)
    private readonly reader: SocialAccountReaderPort,
    @Inject(SOCIAL_ACCOUNT_WRITER_PORT)
    private readonly writer: SocialAccountWriterPort,
    @Inject(SOCIAL_OAUTH_PORT) private readonly oauth: SocialOAuthPort,
    private readonly health: TaskHealthRegistry,
  ) {}

  async execute(): Promise<RefreshSocialTokensResult> {
    const threshold = new Date(Date.now() + REFRESH_WINDOW_DAYS * 86_400_000);
    const expiring = await this.reader.findAllExpiringBefore(threshold);

    let refreshed = 0;
    let failed = 0;

    for (const connected of expiring) {
      try {
        const result = await this.oauth.refreshLongLivedToken(
          connected.accessToken,
        );
        await this.writer.updateTokens(connected.account.id, {
          accessToken: result.accessToken,
          tokenExpiresAt: new Date(Date.now() + result.expiresInSeconds * 1000),
        });
        refreshed += 1;
      } catch (error) {
        failed += 1;
        const message = error instanceof Error ? error.message : String(error);
        this.logger.error(
          `Failed to refresh token for social account ${connected.account.id}: ${message}`,
        );
        // Visible en el backoffice, no solo por email a ops: el gestor tiene
        // que saber que su cuenta necesita reconectarse.
        await this.writer.markError(connected.account.id, message);
      }
    }

    if (failed > 0) {
      this.health.recordFailure(SOCIAL_TOKEN_REFRESH_TASK);
    } else {
      this.health.recordSuccess(SOCIAL_TOKEN_REFRESH_TASK);
    }

    return { refreshed, failed };
  }
}
