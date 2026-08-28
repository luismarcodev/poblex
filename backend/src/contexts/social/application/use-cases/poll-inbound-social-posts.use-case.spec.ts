import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import type {
  CreateNewsFromSocialPostParams,
  CreatedInboundNews,
  InboundNewsWriterPort,
} from '../../domain/ports/inbound-news-writer.port';
import type {
  SocialAccountReaderPort,
  SocialAccountWithToken,
} from '../../domain/ports/social-account-reader.port';
import type {
  InboundSocialPost,
  SocialListenerPort,
} from '../../domain/ports/social-listener.port';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { PollInboundSocialPostsUseCase } from './poll-inbound-social-posts.use-case';

const MUNICIPALITY_ID = '11111111-1111-4111-8111-111111111111';

function buildConnectedAccount(): SocialAccountWithToken {
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
    findAccessTokenForPublishing: () => Promise.resolve(null),
    findAllConnected: () => Promise.resolve([buildConnectedAccount()]),
    findAllExpiringBefore: () => Promise.resolve([]),
  };
}

function buildListener(posts: InboundSocialPost[]): SocialListenerPort {
  return {
    fetchRecentPosts: () => Promise.resolve(posts),
  };
}

function buildNewsWriter(
  alreadyImportedIds: Set<string> = new Set(),
): InboundNewsWriterPort & {
  created: CreateNewsFromSocialPostParams[];
} {
  const created: CreateNewsFromSocialPostParams[] = [];
  return {
    created,
    existsBySourcePost: (_municipalityId, _platform, externalPostId) =>
      Promise.resolve(alreadyImportedIds.has(externalPostId)),
    createFromSocialPost: (params): Promise<CreatedInboundNews> => {
      created.push(params);
      alreadyImportedIds.add(params.externalPostId);
      return Promise.resolve({
        id: `news-${params.externalPostId}`,
        title: params.title,
        body: params.body,
      });
    },
  };
}

function buildBroadcast(): BroadcastNotifier {
  return {
    broadcast: () => Promise.resolve(undefined),
  } as unknown as BroadcastNotifier;
}

describe('PollInboundSocialPostsUseCase', () => {
  it('creates a news item from a parseable post', async () => {
    const newsWriter = buildNewsWriter();
    const useCase = new PollInboundSocialPostsUseCase(
      buildAccountsReader(),
      buildListener([
        {
          externalId: 'post-1',
          caption: 'Fiestas patronales este fin de semana',
          imageUrl: null,
          permalink: 'https://instagram.com/p/1',
          publishedAt: new Date(),
        },
      ]),
      newsWriter,
      buildBroadcast(),
      new TaskHealthRegistry(),
    );

    const result = await useCase.execute();

    expect(result).toEqual({ created: 1, failedAccounts: 0 });
    expect(newsWriter.created).toHaveLength(1);
    expect(newsWriter.created[0].externalPostId).toBe('post-1');
  });

  it('does not duplicate a post already imported in a previous run', async () => {
    const newsWriter = buildNewsWriter(new Set(['post-1']));
    const useCase = new PollInboundSocialPostsUseCase(
      buildAccountsReader(),
      buildListener([
        {
          externalId: 'post-1',
          caption: 'Fiestas patronales este fin de semana',
          imageUrl: null,
          permalink: 'https://instagram.com/p/1',
          publishedAt: new Date(),
        },
      ]),
      newsWriter,
      buildBroadcast(),
      new TaskHealthRegistry(),
    );

    const result = await useCase.execute();

    expect(result).toEqual({ created: 0, failedAccounts: 0 });
    expect(newsWriter.created).toHaveLength(0);
  });

  it('skips a post with no usable text or image', async () => {
    const newsWriter = buildNewsWriter();
    const useCase = new PollInboundSocialPostsUseCase(
      buildAccountsReader(),
      buildListener([
        {
          externalId: 'post-empty',
          caption: null,
          imageUrl: null,
          permalink: 'https://instagram.com/p/2',
          publishedAt: new Date(),
        },
      ]),
      newsWriter,
      buildBroadcast(),
      new TaskHealthRegistry(),
    );

    const result = await useCase.execute();

    expect(result).toEqual({ created: 0, failedAccounts: 0 });
    expect(newsWriter.created).toHaveLength(0);
  });
});
