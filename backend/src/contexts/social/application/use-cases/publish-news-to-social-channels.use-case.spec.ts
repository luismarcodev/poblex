import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import { SocialPublication } from '../../domain/entities/social-publication.entity';
import type {
  SocialAccountReaderPort,
  SocialAccountWithToken,
} from '../../domain/ports/social-account-reader.port';
import type {
  CreateSocialPublicationParams,
  SocialPublicationWriterPort,
} from '../../domain/ports/social-publication.port';
import type {
  FacebookPublishResult,
  SocialPublisherPort,
} from '../../domain/ports/social-publisher.port';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../../domain/value-objects/social-publication-status.vo';
import { PublishNewsToSocialChannelsUseCase } from './publish-news-to-social-channels.use-case';

const MUNICIPALITY_ID = '11111111-1111-4111-8111-111111111111';

function buildConnectedAccount(
  platform: SocialPlatform,
): SocialAccountWithToken {
  return {
    accessToken: 'token',
    account: SocialAccount.create({
      id: 'account-1',
      municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
      platform,
      externalAccountId: 'external-1',
      accountName: 'Ayuntamiento',
      tokenExpiresAt: new Date(Date.now() + 1_000_000),
      status: 'connected',
      lastErrorMessage: null,
      connectedByManagerId: 'manager-1',
      connectedAt: new Date(),
      lastRefreshedAt: null,
    }),
  };
}

function buildAccountsReader(): SocialAccountReaderPort {
  return {
    findByMunicipality: () => Promise.resolve([]),
    findConnected: () => Promise.resolve(null),
    findAccessTokenForPublishing: (_municipalityId, platform) =>
      Promise.resolve(buildConnectedAccount(platform)),
    findAllConnected: () => Promise.resolve([]),
    findAllExpiringBefore: () => Promise.resolve([]),
  };
}

function buildPublicationsWriter(): SocialPublicationWriterPort & {
  createdFor: string[];
} {
  const createdFor: string[] = [];
  return {
    createdFor,
    create: (params: CreateSocialPublicationParams) => {
      createdFor.push(params.platform.value);
      return Promise.resolve(
        SocialPublication.create({
          id: `publication-${params.platform.value}`,
          newsId: params.newsId,
          municipalityId: params.municipalityId,
          platform: params.platform,
          status: SocialPublicationStatus.pending(),
          containerId: null,
          externalPostId: null,
          lastError: null,
          attemptCount: 0,
          createdAt: new Date(),
          publishedAt: null,
        }),
      );
    },
    updateStatus: (id, fields) =>
      Promise.resolve(
        SocialPublication.create({
          id,
          newsId: 'news-1',
          municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
          platform: SocialPlatform.facebook(),
          status: fields.status,
          containerId: fields.containerId ?? null,
          externalPostId: fields.externalPostId ?? null,
          lastError: fields.lastError ?? null,
          attemptCount: 1,
          createdAt: new Date(),
          publishedAt: fields.publishedAt ?? null,
        }),
      ),
  };
}

function buildPublisher(): SocialPublisherPort {
  return {
    publishToFacebook: (): Promise<FacebookPublishResult> =>
      Promise.resolve({ externalPostId: 'fb-post-1' }),
    createInstagramContainer: () =>
      Promise.resolve({ containerId: 'container-1' }),
    getInstagramContainerStatus: () => Promise.resolve('finished'),
    publishInstagramContainer: () =>
      Promise.resolve({ externalPostId: 'ig-post-1' }),
  };
}

describe('PublishNewsToSocialChannelsUseCase', () => {
  it('publishes to every requested platform with a connected account', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new PublishNewsToSocialChannelsUseCase(
      buildAccountsReader(),
      publications,
      buildPublisher(),
    );

    await useCase.execute({
      newsId: 'news-1',
      municipalityId: MUNICIPALITY_ID,
      platforms: ['facebook', 'instagram'],
      title: LocalizedText.create({ es: 'Título' }),
      body: LocalizedText.create({ es: 'Cuerpo' }),
      imageUrl: 'https://example.com/img.jpg',
    });

    expect(publications.createdFor.sort()).toEqual(['facebook', 'instagram']);
  });

  it('never shares back to the platform a news item originated from', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new PublishNewsToSocialChannelsUseCase(
      buildAccountsReader(),
      publications,
      buildPublisher(),
    );

    await useCase.execute({
      newsId: 'news-1',
      municipalityId: MUNICIPALITY_ID,
      platforms: ['instagram', 'facebook'],
      title: LocalizedText.create({ es: 'Título' }),
      body: LocalizedText.create({ es: 'Cuerpo' }),
      imageUrl: 'https://example.com/img.jpg',
      excludePlatform: 'instagram',
    });

    expect(publications.createdFor).toEqual(['facebook']);
  });
});
