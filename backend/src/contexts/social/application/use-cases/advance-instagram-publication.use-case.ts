import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { SOCIAL_ACCOUNT_READER_PORT } from '../../domain/ports/social-account-reader.port';
import type { SocialAccountReaderPort } from '../../domain/ports/social-account-reader.port';
import {
  SOCIAL_PUBLICATION_READER_PORT,
  SOCIAL_PUBLICATION_WRITER_PORT,
} from '../../domain/ports/social-publication.port';
import type {
  SocialPublicationReaderPort,
  SocialPublicationWriterPort,
} from '../../domain/ports/social-publication.port';
import { SOCIAL_PUBLISHER_PORT } from '../../domain/ports/social-publisher.port';
import type { SocialPublisherPort } from '../../domain/ports/social-publisher.port';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import { SocialPublication } from '../../domain/entities/social-publication.entity';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../../domain/value-objects/social-publication-status.vo';

export const SOCIAL_INSTAGRAM_ADVANCE_TASK = 'social-instagram-advance';

const DEFAULT_TIMEOUT_MINUTES = 60;

export interface AdvanceInstagramResult {
  advanced: number;
  failed: number;
}

@Injectable()
export class AdvanceInstagramPublicationUseCase {
  private readonly logger = new Logger(AdvanceInstagramPublicationUseCase.name);

  constructor(
    @Inject(SOCIAL_PUBLICATION_READER_PORT)
    private readonly publicationsReader: SocialPublicationReaderPort,
    @Inject(SOCIAL_PUBLICATION_WRITER_PORT)
    private readonly publicationsWriter: SocialPublicationWriterPort,
    @Inject(SOCIAL_ACCOUNT_READER_PORT)
    private readonly accounts: SocialAccountReaderPort,
    @Inject(SOCIAL_PUBLISHER_PORT)
    private readonly publisher: SocialPublisherPort,
    private readonly health: TaskHealthRegistry,
    private readonly config: ConfigService,
  ) {}

  async execute(): Promise<AdvanceInstagramResult> {
    const pending = await this.publicationsReader.findPendingInstagram();
    let advanced = 0;
    let failed = 0;

    for (const publication of pending) {
      try {
        const didAdvance = await this.advanceOne(publication);
        if (didAdvance) advanced += 1;
      } catch (error) {
        failed += 1;
        this.logger.error(
          `Failed to advance Instagram publication ${publication.id}: ${String(error)}`,
        );
      }
    }

    if (failed > 0) {
      this.health.recordFailure(SOCIAL_INSTAGRAM_ADVANCE_TASK);
    } else {
      this.health.recordSuccess(SOCIAL_INSTAGRAM_ADVANCE_TASK);
    }

    return { advanced, failed };
  }

  private async advanceOne(publication: SocialPublication): Promise<boolean> {
    const account = await this.accounts.findAccessTokenForPublishing(
      publication.municipalityId,
      SocialPlatform.instagram(),
    );
    if (!account) {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: 'No Instagram account connected for this municipality',
      });
      return false;
    }

    if (publication.status.value === 'container_created') {
      return this.advanceContainerCreated(
        publication,
        account.account,
        account.accessToken,
      );
    }

    if (publication.status.value === 'processing') {
      return this.advanceProcessing(
        publication,
        account.account,
        account.accessToken,
      );
    }

    return false;
  }

  private async advanceContainerCreated(
    publication: SocialPublication,
    account: SocialAccount,
    accessToken: string,
  ): Promise<boolean> {
    if (!publication.containerId) {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: 'Instagram publication has no containerId',
      });
      return false;
    }

    const status = await this.publisher.getInstagramContainerStatus(
      publication.containerId,
      accessToken,
    );

    if (status === 'finished') {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.processing(),
      });
      return true;
    }

    if (status === 'error' || status === 'expired') {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: `Instagram container ${status}`,
      });
      return false;
    }

    if (this.isTimedOut(publication)) {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: 'Instagram container timed out while processing',
      });
    }
    return false;
  }

  private async advanceProcessing(
    publication: SocialPublication,
    account: SocialAccount,
    accessToken: string,
  ): Promise<boolean> {
    if (!publication.containerId) {
      await this.publicationsWriter.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: 'Instagram publication has no containerId',
      });
      return false;
    }

    const result = await this.publisher.publishInstagramContainer(
      account.externalAccountId,
      publication.containerId,
      accessToken,
    );
    await this.publicationsWriter.updateStatus(publication.id, {
      status: SocialPublicationStatus.published(),
      externalPostId: result.externalPostId,
      publishedAt: new Date(),
    });
    return true;
  }

  private isTimedOut(publication: SocialPublication): boolean {
    const timeoutMinutes =
      this.config.get<number>('INSTAGRAM_CONTAINER_TIMEOUT_MINUTES') ??
      DEFAULT_TIMEOUT_MINUTES;
    const elapsedMs = Date.now() - publication.createdAt.getTime();
    return elapsedMs > timeoutMinutes * 60_000;
  }
}
