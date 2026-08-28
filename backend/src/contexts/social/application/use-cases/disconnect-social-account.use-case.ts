import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import {
  SocialAccountForbiddenError,
  SocialAccountNotFoundError,
} from '../../domain/errors/social-errors';
import { SOCIAL_ACCOUNT_WRITER_PORT } from '../../domain/ports/social-account-writer.port';
import type { SocialAccountWriterPort } from '../../domain/ports/social-account-writer.port';

export interface DisconnectSocialAccountInput {
  id: string;
  managerId: string;
}

@Injectable()
export class DisconnectSocialAccountUseCase {
  constructor(
    @Inject(SOCIAL_ACCOUNT_WRITER_PORT)
    private readonly writer: SocialAccountWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: DisconnectSocialAccountInput): Promise<Result<void>> {
    const account = await this.writer.findAdminById(input.id);
    if (!account) {
      return Result.failure(new SocialAccountNotFoundError(input.id));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      account.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new SocialAccountForbiddenError(
          input.managerId,
          account.municipalityId.value,
        ),
      );
    }

    // Borrado físico, no soft-delete: el histórico de SocialPublication no
    // depende de que la cuenta siga existiendo.
    await this.writer.disconnect(input.id);
    return Result.success(undefined);
  }
}
