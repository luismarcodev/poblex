import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { SocialAccount } from '../../domain/entities/social-account.entity';
import { SocialAccountForbiddenError } from '../../domain/errors/social-errors';
import { SOCIAL_ACCOUNT_READER_PORT } from '../../domain/ports/social-account-reader.port';
import type { SocialAccountReaderPort } from '../../domain/ports/social-account-reader.port';

export interface ListSocialAccountsInput {
  managerId: string;
  municipalityId: string;
}

@Injectable()
export class ListSocialAccountsUseCase {
  constructor(
    @Inject(SOCIAL_ACCOUNT_READER_PORT)
    private readonly reader: SocialAccountReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(
    input: ListSocialAccountsInput,
  ): Promise<Result<SocialAccount[]>> {
    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      input.municipalityId,
    );
    if (!isAuthorized) {
      return Result.failure(
        new SocialAccountForbiddenError(input.managerId, input.municipalityId),
      );
    }

    const municipalityId = MunicipalityId.create(input.municipalityId);
    const accounts = await this.reader.findByMunicipality(municipalityId);
    return Result.success(accounts);
  }
}
