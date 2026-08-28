import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MunicipalitiesModule } from '../municipalities/municipalities.module';
import { ForgotManagerPasswordUseCase } from './application/use-cases/forgot-manager-password.use-case';
import { GetManagerProfileUseCase } from './application/use-cases/get-manager-profile.use-case';
import { LoginManagerUseCase } from './application/use-cases/login-manager.use-case';
import { LogoutManagerUseCase } from './application/use-cases/logout-manager.use-case';
import { RefreshManagerSessionUseCase } from './application/use-cases/refresh-manager-session.use-case';
import { ResetManagerPasswordUseCase } from './application/use-cases/reset-manager-password.use-case';
import { MANAGER_REPOSITORY_PORT } from './domain/ports/manager-repository.port';
import { OPAQUE_TOKEN_PORT } from './domain/ports/opaque-token.port';
import { PASSWORD_HASHER_PORT } from './domain/ports/password-hasher.port';
import { PASSWORD_RESET_REPOSITORY_PORT } from './domain/ports/password-reset-repository.port';
import { REFRESH_TOKEN_REPOSITORY_PORT } from './domain/ports/refresh-token-repository.port';
import { TOKEN_GENERATOR_PORT } from './domain/ports/token-generator.port';
import { ManagersAuthController } from './infrastructure/http/managers-auth.controller';
import { ManagersProfileController } from './infrastructure/http/managers-profile.controller';
import { ManagerPrismaRepository } from './infrastructure/persistence/prisma/manager-prisma.repository';
import { PasswordResetPrismaRepository } from './infrastructure/persistence/prisma/password-reset-prisma.repository';
import { RefreshTokenPrismaRepository } from './infrastructure/persistence/prisma/refresh-token-prisma.repository';
import { Argon2PasswordHasherAdapter } from './infrastructure/security/argon2-password-hasher.adapter';
import { CryptoOpaqueTokenAdapter } from './infrastructure/security/crypto-opaque-token.adapter';
import { JwtTokenGeneratorAdapter } from './infrastructure/security/jwt-token-generator.adapter';
import { ManagerJwtStrategy } from './infrastructure/security/manager-jwt.strategy';

@Module({
  imports: [PassportModule, JwtModule.register({}), MunicipalitiesModule],
  controllers: [ManagersAuthController, ManagersProfileController],
  providers: [
    GetManagerProfileUseCase,
    LoginManagerUseCase,
    RefreshManagerSessionUseCase,
    LogoutManagerUseCase,
    ForgotManagerPasswordUseCase,
    ResetManagerPasswordUseCase,
    ManagerJwtStrategy,
    { provide: MANAGER_REPOSITORY_PORT, useClass: ManagerPrismaRepository },
    {
      provide: REFRESH_TOKEN_REPOSITORY_PORT,
      useClass: RefreshTokenPrismaRepository,
    },
    {
      provide: PASSWORD_RESET_REPOSITORY_PORT,
      useClass: PasswordResetPrismaRepository,
    },
    { provide: PASSWORD_HASHER_PORT, useClass: Argon2PasswordHasherAdapter },
    { provide: TOKEN_GENERATOR_PORT, useClass: JwtTokenGeneratorAdapter },
    { provide: OPAQUE_TOKEN_PORT, useClass: CryptoOpaqueTokenAdapter },
  ],
  exports: [MANAGER_REPOSITORY_PORT],
})
export class ManagersModule {}
