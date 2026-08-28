import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { OPAQUE_TOKEN_PORT } from '../../domain/ports/opaque-token.port';
import type { OpaqueTokenPort } from '../../domain/ports/opaque-token.port';
import { REFRESH_TOKEN_REPOSITORY_PORT } from '../../domain/ports/refresh-token-repository.port';
import type { RefreshTokenRepositoryPort } from '../../domain/ports/refresh-token-repository.port';

@Injectable()
export class LogoutManagerUseCase {
  constructor(
    @Inject(REFRESH_TOKEN_REPOSITORY_PORT)
    private readonly refreshTokens: RefreshTokenRepositoryPort,
    @Inject(OPAQUE_TOKEN_PORT) private readonly opaqueTokens: OpaqueTokenPort,
  ) {}

  async execute(rawRefreshToken: string): Promise<Result<void>> {
    const tokenHash = this.opaqueTokens.hash(rawRefreshToken);
    const stored = await this.refreshTokens.findByHash(tokenHash);
    if (stored) {
      await this.refreshTokens.revokeIfActive(stored.id);
    }
    return Result.success(undefined);
  }
}
