import { Inject, Injectable, Logger } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import {
  OAuthStateInvalidError,
  SocialTokenExchangeError,
} from '../../domain/errors/social-errors';
import { SOCIAL_ACCOUNT_WRITER_PORT } from '../../domain/ports/social-account-writer.port';
import type { SocialAccountWriterPort } from '../../domain/ports/social-account-writer.port';
import { SOCIAL_OAUTH_PORT } from '../../domain/ports/social-oauth.port';
import type { SocialOAuthPort } from '../../domain/ports/social-oauth.port';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialOAuthStateService } from '../services/social-oauth-state.service';

export interface CompleteSocialOAuthCallbackInput {
  state: string;
  code: string;
}

@Injectable()
export class CompleteSocialOAuthCallbackUseCase {
  private readonly logger = new Logger(CompleteSocialOAuthCallbackUseCase.name);

  constructor(
    @Inject(SOCIAL_OAUTH_PORT) private readonly oauth: SocialOAuthPort,
    @Inject(SOCIAL_ACCOUNT_WRITER_PORT)
    private readonly writer: SocialAccountWriterPort,
    private readonly stateService: SocialOAuthStateService,
  ) {}

  async execute(
    input: CompleteSocialOAuthCallbackInput,
  ): Promise<Result<SocialAccount>> {
    const payload = this.stateService.verify(input.state);
    if (!payload) {
      return Result.failure(new OAuthStateInvalidError());
    }

    let municipalityId: MunicipalityId;
    let platform: SocialPlatform;
    try {
      municipalityId = MunicipalityId.create(payload.municipalityId);
      platform = SocialPlatform.create(payload.platform);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    try {
      const tokenExchange = await this.oauth.exchangeCodeForToken(input.code);
      const pages = await this.oauth.listManagedPages(
        tokenExchange.userAccessToken,
      );
      if (pages.length === 0) {
        return Result.failure(
          new SocialTokenExchangeError(
            'The Meta account has no managed Pages to connect',
          ),
        );
      }

      const tokenExpiresAt = new Date(
        Date.now() + tokenExchange.expiresInSeconds * 1000,
      );

      if (platform.isFacebook) {
        // v1: la primera Página administrada. Elegir entre varias es una
        // mejora de UX pendiente, no un requisito del alcance actual.
        const page = pages[0];
        const account = await this.writer.upsertFromOAuth({
          municipalityId,
          platform,
          externalAccountId: page.pageId,
          accountName: page.pageName,
          accessToken: page.pageAccessToken,
          tokenExpiresAt,
          connectedByManagerId: payload.managerId,
        });
        return Result.success(account);
      }

      // Instagram: la primera Página con una cuenta de Instagram Business
      // vinculada. El token de publicación en IG es el mismo token de Página.
      for (const page of pages) {
        const igAccountId = await this.oauth.getInstagramBusinessAccountId(
          page.pageId,
          page.pageAccessToken,
        );
        if (!igAccountId) continue;

        const account = await this.writer.upsertFromOAuth({
          municipalityId,
          platform,
          externalAccountId: igAccountId,
          accountName: page.pageName,
          accessToken: page.pageAccessToken,
          tokenExpiresAt,
          connectedByManagerId: payload.managerId,
        });
        return Result.success(account);
      }

      return Result.failure(
        new SocialTokenExchangeError(
          'None of the managed Pages has a linked Instagram Business account',
        ),
      );
    } catch (error) {
      this.logger.error(`Social OAuth callback failed: ${String(error)}`);
      return Result.failure(
        new SocialTokenExchangeError(
          error instanceof Error ? error.message : 'Unknown error',
        ),
      );
    }
  }
}
