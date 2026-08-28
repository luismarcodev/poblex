import { ConfigService } from '@nestjs/config';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import { OAuthStateInvalidError } from '../../domain/errors/social-errors';
import type {
  ManagedPage,
  OAuthTokenExchange,
  SocialOAuthPort,
} from '../../domain/ports/social-oauth.port';
import type {
  SocialAccountWriterPort,
  UpsertSocialAccountParams,
} from '../../domain/ports/social-account-writer.port';
import { SocialOAuthStateService } from '../services/social-oauth-state.service';
import { CompleteSocialOAuthCallbackUseCase } from './complete-social-oauth-callback.use-case';

const MUNICIPALITY_ID = '11111111-1111-4111-8111-111111111111';

function buildStateService(): SocialOAuthStateService {
  const config = { get: () => 'test-app-secret' } as unknown as ConfigService;
  return new SocialOAuthStateService(config);
}

function buildOAuthPort(
  overrides: Partial<SocialOAuthPort> = {},
): SocialOAuthPort {
  return {
    buildAuthorizeUrl: () => 'https://facebook.com/authorize',
    exchangeCodeForToken: (): Promise<OAuthTokenExchange> =>
      Promise.resolve({
        userAccessToken: 'user-token',
        expiresInSeconds: 5_184_000,
      }),
    listManagedPages: (): Promise<ManagedPage[]> =>
      Promise.resolve([
        {
          pageId: 'page-1',
          pageName: 'Ayuntamiento',
          pageAccessToken: 'page-token',
        },
      ]),
    getInstagramBusinessAccountId: () => Promise.resolve('ig-account-1'),
    refreshLongLivedToken: () =>
      Promise.resolve({ accessToken: 'x', expiresInSeconds: 1 }),
    ...overrides,
  };
}

function buildWriter(): SocialAccountWriterPort & {
  calls: UpsertSocialAccountParams[];
} {
  const calls: UpsertSocialAccountParams[] = [];
  return {
    calls,
    upsertFromOAuth: (params) => {
      calls.push(params);
      return Promise.resolve(
        SocialAccount.create({
          id: 'account-1',
          municipalityId: params.municipalityId,
          platform: params.platform,
          externalAccountId: params.externalAccountId,
          accountName: params.accountName,
          tokenExpiresAt: params.tokenExpiresAt,
          status: 'connected',
          lastErrorMessage: null,
          connectedByManagerId: params.connectedByManagerId,
          connectedAt: new Date(),
          lastRefreshedAt: null,
        }),
      );
    },
    findAdminById: () => Promise.resolve(null),
    updateTokens: () => {
      throw new Error('not used in this test');
    },
    markError: () => {
      throw new Error('not used in this test');
    },
    disconnect: () => Promise.resolve(undefined),
  };
}

describe('CompleteSocialOAuthCallbackUseCase', () => {
  it('rejects an invalid state', async () => {
    const useCase = new CompleteSocialOAuthCallbackUseCase(
      buildOAuthPort(),
      buildWriter(),
      buildStateService(),
    );

    const result = await useCase.execute({ state: 'garbage', code: 'abc' });

    expect(result.isFailure).toBe(true);
    if (result.isFailure) {
      expect(result.error).toBeInstanceOf(OAuthStateInvalidError);
    }
  });

  it('connects the Facebook Page from the signed state', async () => {
    const stateService = buildStateService();
    const writer = buildWriter();
    const useCase = new CompleteSocialOAuthCallbackUseCase(
      buildOAuthPort(),
      writer,
      stateService,
    );
    const state = stateService.sign({
      managerId: 'manager-1',
      municipalityId: MUNICIPALITY_ID,
      platform: 'facebook',
    });

    const result = await useCase.execute({ state, code: 'abc' });

    expect(result.isSuccess).toBe(true);
    expect(writer.calls).toHaveLength(1);
    expect(writer.calls[0].externalAccountId).toBe('page-1');
  });

  it('connects the linked Instagram Business account from the signed state', async () => {
    const stateService = buildStateService();
    const writer = buildWriter();
    const useCase = new CompleteSocialOAuthCallbackUseCase(
      buildOAuthPort(),
      writer,
      stateService,
    );
    const state = stateService.sign({
      managerId: 'manager-1',
      municipalityId: MUNICIPALITY_ID,
      platform: 'instagram',
    });

    const result = await useCase.execute({ state, code: 'abc' });

    expect(result.isSuccess).toBe(true);
    expect(writer.calls[0].externalAccountId).toBe('ig-account-1');
  });

  it('fails when no managed Page has a linked Instagram Business account', async () => {
    const stateService = buildStateService();
    const useCase = new CompleteSocialOAuthCallbackUseCase(
      buildOAuthPort({
        getInstagramBusinessAccountId: () => Promise.resolve(null),
      }),
      buildWriter(),
      stateService,
    );
    const state = stateService.sign({
      managerId: 'manager-1',
      municipalityId: MUNICIPALITY_ID,
      platform: 'instagram',
    });

    const result = await useCase.execute({ state, code: 'abc' });

    expect(result.isFailure).toBe(true);
  });
});
