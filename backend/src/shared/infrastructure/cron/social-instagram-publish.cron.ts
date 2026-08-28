import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { AdvanceInstagramPublicationUseCase } from '../../../contexts/social/application/use-cases/advance-instagram-publication.use-case';

@Injectable()
export class SocialInstagramPublishCron {
  private readonly logger = new Logger(SocialInstagramPublishCron.name);

  constructor(private readonly advance: AdvanceInstagramPublicationUseCase) {}

  @Cron('0 */5 * * * *')
  async run(): Promise<void> {
    const result = await this.advance.execute();
    if (result.advanced > 0 || result.failed > 0) {
      this.logger.log(
        `Instagram publish advance: ${result.advanced} advanced, ${result.failed} failed`,
      );
    }
  }
}
