import { Inject, Injectable, Logger } from '@nestjs/common';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SOCIAL_ACCOUNT_READER_PORT } from '../../domain/ports/social-account-reader.port';
import type { SocialAccountReaderPort } from '../../domain/ports/social-account-reader.port';
import { SOCIAL_PUBLICATION_WRITER_PORT } from '../../domain/ports/social-publication.port';
import type { SocialPublicationWriterPort } from '../../domain/ports/social-publication.port';
import { SOCIAL_PUBLISHER_PORT } from '../../domain/ports/social-publisher.port';
import type { SocialPublisherPort } from '../../domain/ports/social-publisher.port';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../../domain/value-objects/social-publication-status.vo';

export interface PublishNewsToSocialChannelsInput {
  newsId: string;
  municipalityId: string;
  platforms: string[];
  title: LocalizedText;
  body: LocalizedText;
  imageUrl?: string;
  // Anti-bucle: la noticia importada desde una red social nunca se reenvía
  // hacia la plataforma de la que vino, aunque se solicite por error.
  excludePlatform?: string;
}

@Injectable()
export class PublishNewsToSocialChannelsUseCase {
  private readonly logger = new Logger(PublishNewsToSocialChannelsUseCase.name);

  constructor(
    @Inject(SOCIAL_ACCOUNT_READER_PORT)
    private readonly accounts: SocialAccountReaderPort,
    @Inject(SOCIAL_PUBLICATION_WRITER_PORT)
    private readonly publications: SocialPublicationWriterPort,
    @Inject(SOCIAL_PUBLISHER_PORT)
    private readonly publisher: SocialPublisherPort,
  ) {}

  // Cada plataforma vive en su propio try/catch: un fallo de Instagram nunca
  // impide que Facebook se publique, y ninguno de los dos puede tumbar la
  // creación de la noticia que ya está guardada cuando esto se invoca.
  async execute(input: PublishNewsToSocialChannelsInput): Promise<void> {
    const municipalityId = MunicipalityId.create(input.municipalityId);
    const caption = this.buildCaption(input.title, input.body);

    for (const raw of input.platforms) {
      if (raw === input.excludePlatform) continue;

      let platform: SocialPlatform;
      try {
        platform = SocialPlatform.create(raw);
      } catch {
        continue;
      }

      try {
        await this.publishToPlatform(
          input.newsId,
          municipalityId,
          platform,
          caption,
          input.imageUrl,
        );
      } catch (error) {
        this.logger.error(
          `Failed to publish news ${input.newsId} to ${platform.value}: ${String(error)}`,
        );
      }
    }
  }

  private async publishToPlatform(
    newsId: string,
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
    caption: string,
    imageUrl?: string,
  ): Promise<void> {
    const account = await this.accounts.findAccessTokenForPublishing(
      municipalityId,
      platform,
    );
    if (!account) {
      this.logger.warn(
        `No connected ${platform.value} account for municipality ${municipalityId.value}`,
      );
      return;
    }

    const publication = await this.publications.create({
      newsId,
      municipalityId,
      platform,
    });

    if (platform.isFacebook) {
      const result = await this.publisher.publishToFacebook({
        pageAccessToken: account.accessToken,
        pageId: account.account.externalAccountId,
        message: caption,
        imageUrl,
      });
      await this.publications.updateStatus(publication.id, {
        status: SocialPublicationStatus.published(),
        externalPostId: result.externalPostId,
        publishedAt: new Date(),
      });
      return;
    }

    if (!imageUrl) {
      await this.publications.updateStatus(publication.id, {
        status: SocialPublicationStatus.failed(),
        lastError: 'Instagram requires an image',
      });
      return;
    }

    const { containerId } = await this.publisher.createInstagramContainer({
      igBusinessAccountId: account.account.externalAccountId,
      accessToken: account.accessToken,
      imageUrl,
      caption,
    });
    await this.publications.updateStatus(publication.id, {
      status: SocialPublicationStatus.containerCreated(),
      containerId,
    });
    // El resto de la máquina de estados (procesando → publicado) la avanza
    // AdvanceInstagramPublicationUseCase, disparado por el cron periódico.
  }

  private buildCaption(title: LocalizedText, body: LocalizedText): string {
    const titleText = title.resolve('es').text;
    const bodyText = body.resolve('es').text;
    return `${titleText}\n\n${bodyText}`;
  }
}
