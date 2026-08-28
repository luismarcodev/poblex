import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Result } from '../../../../shared/domain/result';
import { EMAIL_SENDER_PORT } from '../../../../shared/infrastructure/email/email-sender.port';
import type { EmailSenderPort } from '../../../../shared/infrastructure/email/email-sender.port';
import { MANAGER_REPOSITORY_PORT } from '../../domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../domain/ports/manager-repository.port';
import { OPAQUE_TOKEN_PORT } from '../../domain/ports/opaque-token.port';
import type { OpaqueTokenPort } from '../../domain/ports/opaque-token.port';
import { PASSWORD_RESET_REPOSITORY_PORT } from '../../domain/ports/password-reset-repository.port';
import type { PasswordResetRepositoryPort } from '../../domain/ports/password-reset-repository.port';

export interface ForgotManagerPasswordInput {
  email: string;
}

// Responde éxito SIEMPRE, exista o no el email — evita que alguien use este
// endpoint para averiguar qué emails tienen cuenta de gestor (enumeración).
@Injectable()
export class ForgotManagerPasswordUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    @Inject(PASSWORD_RESET_REPOSITORY_PORT)
    private readonly passwordResets: PasswordResetRepositoryPort,
    @Inject(OPAQUE_TOKEN_PORT) private readonly opaqueTokens: OpaqueTokenPort,
    @Inject(EMAIL_SENDER_PORT) private readonly emailSender: EmailSenderPort,
    private readonly config: ConfigService,
  ) {}

  async execute(input: ForgotManagerPasswordInput): Promise<Result<void>> {
    const manager = await this.managers.findByEmail(input.email);

    if (manager) {
      const ttlMinutes = this.config.get<number>(
        'PASSWORD_RESET_TOKEN_TTL_MIN',
        60,
      );
      const { rawToken, tokenHash } = this.opaqueTokens.generate();

      await this.passwordResets.create({
        managerId: manager.id,
        tokenHash,
        expiresAt: new Date(Date.now() + ttlMinutes * 60_000),
      });

      // CORS_ORIGIN may contain several comma-separated origins. It is not a
      // public URL and using the whole value produced an invalid reset link.
      const backofficeBaseUrl = (
        this.config.get<string>('BACKOFFICE_PUBLIC_URL') ??
        this.config.get<string>('CORS_ORIGIN', '').split(',')[0]
      ).replace(/\/$/, '');
      const resetUrl = `${backofficeBaseUrl}/reset-password?token=${encodeURIComponent(rawToken)}`;

      await this.emailSender.send({
        to: manager.email,
        subject: 'Recuperación de contraseña — Poblex',
        text: `Enlace para restablecer tu contraseña (caduca en ${ttlMinutes} minutos): ${resetUrl}`,
      });
    }

    return Result.success(undefined);
  }
}
