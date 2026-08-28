import { Controller, Get, Query, Res } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiExcludeController } from '@nestjs/swagger';
import type { Response } from 'express';
import { CompleteSocialOAuthCallbackUseCase } from '../../application/use-cases/complete-social-oauth-callback.use-case';
import { OAuthCallbackQueryDto } from './dto/oauth-callback-query.dto';

// SIN GUARD, a propósito — lo invoca Meta, no el gestor autenticado. En su
// propio fichero para que la ausencia de guard sea obvia por ubicación,
// igual que alerts.controller.ts vs. alerts-admin.controller.ts.
@ApiExcludeController()
@Controller('social/oauth')
export class SocialOAuthCallbackController {
  constructor(
    private readonly completeCallback: CompleteSocialOAuthCallbackUseCase,
    private readonly config: ConfigService,
  ) {}

  @Get('callback')
  async callback(
    @Query() query: OAuthCallbackQueryDto,
    @Res() res: Response,
  ): Promise<void> {
    const backofficeUrl = this.config.get<string>('BACKOFFICE_PUBLIC_URL');
    const redirectBase = `${backofficeUrl ?? ''}/#/noticias/conexiones`;

    if (query.error || !query.code || !query.state) {
      res.redirect(302, `${redirectBase}?status=error`);
      return;
    }

    const result = await this.completeCallback.execute({
      code: query.code,
      state: query.state,
    });

    res.redirect(
      302,
      `${redirectBase}?status=${result.isSuccess ? 'ok' : 'error'}`,
    );
  }
}
