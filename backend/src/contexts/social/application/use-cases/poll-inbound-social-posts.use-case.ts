import { Inject, Injectable, Logger } from '@nestjs/common';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { UnparsableInboundPostError } from '../../domain/errors/social-errors';
import { SOCIAL_ACCOUNT_READER_PORT } from '../../domain/ports/social-account-reader.port';
import type { SocialAccountReaderPort } from '../../domain/ports/social-account-reader.port';
import { INBOUND_NEWS_WRITER_PORT } from '../../domain/ports/inbound-news-writer.port';
import type { InboundNewsWriterPort } from '../../domain/ports/inbound-news-writer.port';
import { SOCIAL_LISTENER_PORT } from '../../domain/ports/social-listener.port';
import type { SocialListenerPort } from '../../domain/ports/social-listener.port';
import { assertParseablePost } from '../../infrastructure/meta/meta-post-parser';

export const SOCIAL_INBOUND_POLL_TASK = 'social-inbound-poll';

const TITLE_MAX_CHARS = 80;

export interface PollInboundSocialPostsResult {
  created: number;
  failedAccounts: number;
}

// Molde directo de SyncAemetAlertsUseCase: fuente externa, sondeo periódico,
// deduplicación, aviso de fallos. Publicación automática pura y sin cola de
// revisión — decisión de producto tomada de forma explícita e informada,
// no reintroducir un paso de moderación.
@Injectable()
export class PollInboundSocialPostsUseCase {
  private readonly logger = new Logger(PollInboundSocialPostsUseCase.name);

  constructor(
    @Inject(SOCIAL_ACCOUNT_READER_PORT)
    private readonly accounts: SocialAccountReaderPort,
    @Inject(SOCIAL_LISTENER_PORT) private readonly listener: SocialListenerPort,
    @Inject(INBOUND_NEWS_WRITER_PORT)
    private readonly newsWriter: InboundNewsWriterPort,
    private readonly broadcast: BroadcastNotifier,
    private readonly health: TaskHealthRegistry,
  ) {}

  async execute(): Promise<PollInboundSocialPostsResult> {
    const connectedAccounts = await this.accounts.findAllConnected();
    let created = 0;
    let failedAccounts = 0;

    for (const connected of connectedAccounts) {
      try {
        const posts = await this.listener.fetchRecentPosts(connected);

        for (const post of posts) {
          try {
            assertParseablePost(post);
          } catch (error) {
            if (error instanceof UnparsableInboundPostError) {
              this.logger.warn(error.message);
              continue;
            }
            throw error;
          }

          const alreadyImported = await this.newsWriter.existsBySourcePost(
            connected.account.municipalityId,
            connected.account.platform,
            post.externalId,
          );
          if (alreadyImported) continue;

          const title = LocalizedText.create({
            es: this.buildTitle(post.caption),
          });
          const body = LocalizedText.create({
            es: post.caption?.trim() || this.buildTitle(post.caption),
          });

          const news = await this.newsWriter.createFromSocialPost({
            municipalityId: connected.account.municipalityId,
            platform: connected.account.platform,
            externalPostId: post.externalId,
            title,
            body,
            imageUrl: post.imageUrl ?? undefined,
          });
          created += 1;

          await this.broadcast.broadcast({
            municipalityId: connected.account.municipalityId.value,
            channel: 'news',
            title: news.title,
            body: news.body,
            data: {
              type: 'news',
              id: news.id,
              municipalityId: connected.account.municipalityId.value,
            },
          });
        }
      } catch (error) {
        failedAccounts += 1;
        this.logger.error(
          `Inbound social poll failed for account ${connected.account.id}: ${String(error)}`,
        );
      }
    }

    if (failedAccounts > 0) {
      this.health.recordFailure(SOCIAL_INBOUND_POLL_TASK);
    } else {
      this.health.recordSuccess(SOCIAL_INBOUND_POLL_TASK);
    }

    return { created, failedAccounts };
  }

  private buildTitle(caption: string | null): string {
    const text = (caption ?? '').trim();
    if (text.length === 0) return 'Nueva publicación en redes sociales';
    const firstLine = text.split('\n')[0].trim();
    return firstLine.length <= TITLE_MAX_CHARS
      ? firstLine
      : `${firstLine.slice(0, TITLE_MAX_CHARS - 1).trimEnd()}…`;
  }
}
