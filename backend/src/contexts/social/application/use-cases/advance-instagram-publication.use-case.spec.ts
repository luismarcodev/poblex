import { ConfigService } from '@nestjs/config';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import { SocialPublication } from '../../domain/entities/social-publication.entity';
import type {
  SocialAccountReaderPort,
  SocialAccountWithToken,
} from '../../domain/ports/social-account-reader.port';
import type {
  SocialPublicationReaderPort,
  SocialPublicationWriterPort,
  UpdateSocialPublicationStatusParams,
} from '../../domain/ports/social-publication.port';
import type {
  InstagramContainerStatus,
  SocialPublisherPort,
} from '../../domain/ports/social-publisher.port';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../../domain/value-objects/social-publication-status.vo';
import { AdvanceInstagramPublicationUseCase } from './advance-instagram-publication.use-case';

const MUNICIPALITY_ID = '11111111-1111-4111-8111-111111111111';

function buildPublication(overrides: {
  status: SocialPublicationStatus;
  containerId?: string | null;
  createdAt?: Date;
}): SocialPublication {
  return SocialPublication.create({
    id: 'publication-1',
    newsId: 'news-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    platform: SocialPlatform.instagram(),
    status: overrides.status,
    containerId: overrides.containerId ?? 'container-1',
    externalPostId: null,
    lastError: null,
    attemptCount: 0,
    createdAt: overrides.createdAt ?? new Date(),
    publishedAt: null,
  });
}

function buildAccount(): SocialAccountWithToken {
  return {
    accessToken: 'token',
    account: SocialAccount.create({
      id: 'account-1',
      municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
      platform: SocialPlatform.instagram(),
      externalAccountId: 'ig-account-1',
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
    findAccessTokenForPublishing: () => Promise.resolve(buildAccount()),
    findAllConnected: () => Promise.resolve([]),
    findAllExpiringBefore: () => Promise.resolve([]),
  };
}

function buildPublicationsWriter(): SocialPublicationWriterPort & {
  updates: UpdateSocialPublicationStatusParams[];
} {
  const updates: UpdateSocialPublicationStatusParams[] = [];
  return {
    updates,
    create: () => {
      throw new Error('not used in this test');
    },
    updateStatus: (id, fields) => {
      updates.push(fields);
      return Promise.resolve(
        SocialPublication.create({
          id,
          newsId: 'news-1',
          municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
          platform: SocialPlatform.instagram(),
          status: fields.status,
          containerId: fields.containerId ?? null,
          externalPostId: fields.externalPostId ?? null,
          lastError: fields.lastError ?? null,
          attemptCount: 1,
          createdAt: new Date(),
          publishedAt: fields.publishedAt ?? null,
        }),
      );
    },
  };
}

function buildReader(
  publications: SocialPublication[],
): SocialPublicationReaderPort {
  return {
    findByNews: () => Promise.resolve([]),
    findPendingInstagram: () => Promise.resolve(publications),
  };
}

function buildPublisher(status: InstagramContainerStatus): SocialPublisherPort {
  return {
    publishToFacebook: () => {
      throw new Error('not used in this test');
    },
    createInstagramContainer: () => {
      throw new Error('not used in this test');
    },
    getInstagramContainerStatus: () => Promise.resolve(status),
    publishInstagramContainer: () =>
      Promise.resolve({ externalPostId: 'ig-post-1' }),
  };
}

function buildConfig(timeoutMinutes = 60): ConfigService {
  return { get: () => timeoutMinutes } as unknown as ConfigService;
}

describe('AdvanceInstagramPublicationUseCase', () => {
  it('moves a finished container to processing', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new AdvanceInstagramPublicationUseCase(
      buildReader([
        buildPublication({
          status: SocialPublicationStatus.containerCreated(),
        }),
      ]),
      publications,
      buildAccountsReader(),
      buildPublisher('finished'),
      new TaskHealthRegistry(),
      buildConfig(),
    );

    const result = await useCase.execute();

    expect(result).toEqual({ advanced: 1, failed: 0 });
    expect(publications.updates[0].status.value).toBe('processing');
  });

  it('publishes a container already in processing', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new AdvanceInstagramPublicationUseCase(
      buildReader([
        buildPublication({ status: SocialPublicationStatus.processing() }),
      ]),
      publications,
      buildAccountsReader(),
      buildPublisher('finished'),
      new TaskHealthRegistry(),
      buildConfig(),
    );

    const result = await useCase.execute();

    expect(result).toEqual({ advanced: 1, failed: 0 });
    expect(publications.updates[0].status.value).toBe('published');
    expect(publications.updates[0].externalPostId).toBe('ig-post-1');
  });

  it('marks the publication as failed when Meta reports an error', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new AdvanceInstagramPublicationUseCase(
      buildReader([
        buildPublication({
          status: SocialPublicationStatus.containerCreated(),
        }),
      ]),
      publications,
      buildAccountsReader(),
      buildPublisher('error'),
      new TaskHealthRegistry(),
      buildConfig(),
    );

    await useCase.execute();

    expect(publications.updates[0].status.value).toBe('failed');
  });

  it('marks a stuck container as failed after the timeout', async () => {
    const publications = buildPublicationsWriter();
    const staleCreatedAt = new Date(Date.now() - 61 * 60_000);
    const useCase = new AdvanceInstagramPublicationUseCase(
      buildReader([
        buildPublication({
          status: SocialPublicationStatus.containerCreated(),
          createdAt: staleCreatedAt,
        }),
      ]),
      publications,
      buildAccountsReader(),
      buildPublisher('in_progress'),
      new TaskHealthRegistry(),
      buildConfig(60),
    );

    await useCase.execute();

    expect(publications.updates[0].status.value).toBe('failed');
    expect(publications.updates[0].lastError).toContain('timed out');
  });

  it('does not fail a container still in progress within the timeout window', async () => {
    const publications = buildPublicationsWriter();
    const useCase = new AdvanceInstagramPublicationUseCase(
      buildReader([
        buildPublication({
          status: SocialPublicationStatus.containerCreated(),
        }),
      ]),
      publications,
      buildAccountsReader(),
      buildPublisher('in_progress'),
      new TaskHealthRegistry(),
      buildConfig(60),
    );

    await useCase.execute();

    expect(publications.updates).toHaveLength(0);
  });
});
