import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { SocialAccountForbiddenError } from '../../domain/errors/social-errors';
import { SOCIAL_OAUTH_PORT } from '../../domain/ports/social-oauth.port';
import type { SocialOAuthPort } from '../../domain/ports/social-oauth.port';
import { SocialPlatform } from '../../domain/value-objects/social-platform.vo';
import { SocialOAuthStateService } from '../services/social-oauth-state.service';

export interface StartSocialOAuthInput {
  managerId: string;
  municipalityId: string;
  platform: string;
}

export interface StartSocialOAuthOutput {
  authorizeUrl: string;
}

@Injectable()
export class StartSocialOAuthUseCase {
  constructor(
    @Inject(SOCIAL_OAUTH_PORT) private readonly oauth: SocialOAuthPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly stateService: SocialOAuthStateService,
  ) {}

  async execute(
    input: StartSocialOAuthInput,
  ): Promise<Result<StartSocialOAuthOutput>> {
    let platform: SocialPlatform;
    try {
      platform = SocialPlatform.create(input.platform);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      input.municipalityId,
    );
    if (!isAuthorized) {
      return Result.failure(
        new SocialAccountForbiddenError(input.managerId, input.municipalityId),
      );
    }

    const state = this.stateService.sign({
      managerId: input.managerId,
      municipalityId: input.municipalityId,
      platform: platform.value,
    });

    return Result.success({
      authorizeUrl: this.oauth.buildAuthorizeUrl(state),
    });
  }
}
