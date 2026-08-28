import { Inject, Injectable } from '@nestjs/common';
import { UnauthorizedError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { parseDurationMs } from '../../../../shared/infrastructure/config/parse-duration';
import { Manager } from '../../domain/entities/manager.entity';
import { MANAGER_REPOSITORY_PORT } from '../../domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../domain/ports/manager-repository.port';
import { OPAQUE_TOKEN_PORT } from '../../domain/ports/opaque-token.port';
import type { OpaqueTokenPort } from '../../domain/ports/opaque-token.port';
import { PASSWORD_HASHER_PORT } from '../../domain/ports/password-hasher.port';
import type { PasswordHasherPort } from '../../domain/ports/password-hasher.port';
import { REFRESH_TOKEN_REPOSITORY_PORT } from '../../domain/ports/refresh-token-repository.port';
import type { RefreshTokenRepositoryPort } from '../../domain/ports/refresh-token-repository.port';
import { TOKEN_GENERATOR_PORT } from '../../domain/ports/token-generator.port';
import type { TokenGeneratorPort } from '../../domain/ports/token-generator.port';

export interface LoginManagerInput {
  email: string;
  password: string;
}

export interface ManagerSession {
  accessToken: string;
  refreshToken: string;
  manager: Manager;
}

const INVALID_CREDENTIALS_MESSAGE = 'Invalid email or password';

@Injectable()
export class LoginManagerUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    @Inject(REFRESH_TOKEN_REPOSITORY_PORT)
    private readonly refreshTokens: RefreshTokenRepositoryPort,
    @Inject(PASSWORD_HASHER_PORT) private readonly hasher: PasswordHasherPort,
    @Inject(TOKEN_GENERATOR_PORT) private readonly tokens: TokenGeneratorPort,
    @Inject(OPAQUE_TOKEN_PORT) private readonly opaqueTokens: OpaqueTokenPort,
  ) {}

  async execute(input: LoginManagerInput): Promise<Result<ManagerSession>> {
    const manager = await this.managers.findByEmail(input.email);
    if (!manager) {
      return Result.failure(new UnauthorizedError(INVALID_CREDENTIALS_MESSAGE));
    }

    const passwordMatches = await this.hasher.verify(
      manager.passwordHash,
      input.password,
    );
    if (!passwordMatches) {
      return Result.failure(new UnauthorizedError(INVALID_CREDENTIALS_MESSAGE));
    }

    const accessToken = this.tokens.signAccessToken({ managerId: manager.id });
    const { rawToken, tokenHash } = this.opaqueTokens.generate();
    const refreshTtlMs = parseDurationMs(
      process.env.JWT_REFRESH_EXPIRES_IN ?? '30d',
    );

    await this.refreshTokens.create({
      managerId: manager.id,
      tokenHash,
      expiresAt: new Date(Date.now() + refreshTtlMs),
    });

    return Result.success({ accessToken, refreshToken: rawToken, manager });
  }
}
