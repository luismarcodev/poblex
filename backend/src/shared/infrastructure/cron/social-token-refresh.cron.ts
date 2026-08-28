import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { RefreshSocialTokensUseCase } from '../../../contexts/social/application/use-cases/refresh-social-tokens.use-case';

// Diario basta: los tokens de larga duración de Meta caducan a los ~60 días.
@Injectable()
export class SocialTokenRefreshCron {
  private readonly logger = new Logger(SocialTokenRefreshCron.name);

  constructor(private readonly refresh: RefreshSocialTokensUseCase) {}

  @Cron('0 0 3 * * *')
  async run(): Promise<void> {
    const result = await this.refresh.execute();
    if (result.refreshed > 0 || result.failed > 0) {
      this.logger.log(
        `Social token refresh: ${result.refreshed} refreshed, ${result.failed} failed`,
      );
    }
  }
}
