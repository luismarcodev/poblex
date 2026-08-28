import { Inject, Injectable } from '@nestjs/common';
import { UnauthorizedError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../domain/ports/manager-repository.port';
import { OPAQUE_TOKEN_PORT } from '../../domain/ports/opaque-token.port';
import type { OpaqueTokenPort } from '../../domain/ports/opaque-token.port';
import { PASSWORD_HASHER_PORT } from '../../domain/ports/password-hasher.port';
import type { PasswordHasherPort } from '../../domain/ports/password-hasher.port';
import { PASSWORD_RESET_REPOSITORY_PORT } from '../../domain/ports/password-reset-repository.port';
import type { PasswordResetRepositoryPort } from '../../domain/ports/password-reset-repository.port';
import { REFRESH_TOKEN_REPOSITORY_PORT } from '../../domain/ports/refresh-token-repository.port';
import type { RefreshTokenRepositoryPort } from '../../domain/ports/refresh-token-repository.port';

export interface ResetManagerPasswordInput {
  token: string;
  newPassword: string;
}

const INVALID_RESET_TOKEN_MESSAGE = 'Invalid or expired password reset token';

@Injectable()
export class ResetManagerPasswordUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    @Inject(PASSWORD_RESET_REPOSITORY_PORT)
    private readonly passwordResets: PasswordResetRepositoryPort,
    @Inject(REFRESH_TOKEN_REPOSITORY_PORT)
    private readonly refreshTokens: RefreshTokenRepositoryPort,
    @Inject(PASSWORD_HASHER_PORT) private readonly hasher: PasswordHasherPort,
    @Inject(OPAQUE_TOKEN_PORT) private readonly opaqueTokens: OpaqueTokenPort,
  ) {}

  async execute(input: ResetManagerPasswordInput): Promise<Result<void>> {
    const tokenHash = this.opaqueTokens.hash(input.token);
    const stored = await this.passwordResets.findByHash(tokenHash);

    if (!stored || stored.usedAt || stored.expiresAt.getTime() < Date.now()) {
      return Result.failure(new UnauthorizedError(INVALID_RESET_TOKEN_MESSAGE));
    }

    const newHash = await this.hasher.hash(input.newPassword);
    await this.managers.updatePasswordHash(stored.managerId, newHash);
    await this.passwordResets.markUsed(stored.id);
    // Fuerza reingreso en todas las sesiones tras un reset de contraseña.
    await this.refreshTokens.revokeAllForManager(stored.managerId);

    return Result.success(undefined);
  }
}
