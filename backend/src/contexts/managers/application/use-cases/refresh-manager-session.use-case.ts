import { Inject, Injectable } from '@nestjs/common';
import { UnauthorizedError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { parseDurationMs } from '../../../../shared/infrastructure/config/parse-duration';
import { MANAGER_REPOSITORY_PORT } from '../../domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../domain/ports/manager-repository.port';
import { OPAQUE_TOKEN_PORT } from '../../domain/ports/opaque-token.port';
import type { OpaqueTokenPort } from '../../domain/ports/opaque-token.port';
import { REFRESH_TOKEN_REPOSITORY_PORT } from '../../domain/ports/refresh-token-repository.port';
import type { RefreshTokenRepositoryPort } from '../../domain/ports/refresh-token-repository.port';
import { TOKEN_GENERATOR_PORT } from '../../domain/ports/token-generator.port';
import type { TokenGeneratorPort } from '../../domain/ports/token-generator.port';
import type { ManagerSession } from './login-manager.use-case';

const INVALID_REFRESH_TOKEN_MESSAGE = 'Invalid or expired refresh token';

// Rota el par en cada uso: revoca el token presentado y emite uno nuevo.
// Si alguien reutiliza un refresh token ya rotado, deja de ser válido.
@Injectable()
export class RefreshManagerSessionUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    @Inject(REFRESH_TOKEN_REPOSITORY_PORT)
    private readonly refreshTokens: RefreshTokenRepositoryPort,
    @Inject(TOKEN_GENERATOR_PORT) private readonly tokens: TokenGeneratorPort,
    @Inject(OPAQUE_TOKEN_PORT) private readonly opaqueTokens: OpaqueTokenPort,
  ) {}

  async execute(rawRefreshToken: string): Promise<Result<ManagerSession>> {
    const tokenHash = this.opaqueTokens.hash(rawRefreshToken);
    const stored = await this.refreshTokens.findByHash(tokenHash);

    if (
      !stored ||
      stored.revokedAt ||
      stored.expiresAt.getTime() < Date.now()
    ) {
      return Result.failure(
        new UnauthorizedError(INVALID_REFRESH_TOKEN_MESSAGE),
      );
    }

    // Atomic consumption closes the race where two simultaneous requests
    // both read the token as active and each minted a valid replacement.
    const consumed = await this.refreshTokens.revokeIfActive(stored.id);
    if (!consumed) {
      return Result.failure(
        new UnauthorizedError(INVALID_REFRESH_TOKEN_MESSAGE),
      );
    }

    const manager = await this.managers.findById(stored.managerId);
    if (!manager) {
      return Result.failure(
        new UnauthorizedError(INVALID_REFRESH_TOKEN_MESSAGE),
      );
    }

    const accessToken = this.tokens.signAccessToken({ managerId: manager.id });
    const { rawToken, tokenHash: newHash } = this.opaqueTokens.generate();
    const refreshTtlMs = parseDurationMs(
      process.env.JWT_REFRESH_EXPIRES_IN ?? '30d',
    );

    await this.refreshTokens.create({
      managerId: manager.id,
      tokenHash: newHash,
      expiresAt: new Date(Date.now() + refreshTtlMs),
    });

    return Result.success({ accessToken, refreshToken: rawToken, manager });
  }
}
