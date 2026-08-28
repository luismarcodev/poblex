import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PollInboundSocialPostsUseCase } from '../../../contexts/social/application/use-cases/poll-inbound-social-posts.use-case';

// Misma cadencia que AEMET: el contrato de "vigilar fuente externa" del
// proyecto ya está fijado en 15 minutos.
@Injectable()
export class SocialInboundPollCron {
  private readonly logger = new Logger(SocialInboundPollCron.name);

  constructor(private readonly poll: PollInboundSocialPostsUseCase) {}

  @Cron('0 */15 * * * *')
  async run(): Promise<void> {
    const result = await this.poll.execute();
    if (result.created > 0 || result.failedAccounts > 0) {
      this.logger.log(
        `Inbound social poll: ${result.created} new news, ${result.failedAccounts} failed account(s)`,
      );
    }
  }
}
