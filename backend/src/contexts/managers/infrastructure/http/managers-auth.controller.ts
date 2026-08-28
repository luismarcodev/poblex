import { Body, Controller, Post, Req, Res, UseGuards } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import type { Request, Response } from 'express';
import { UnauthorizedError } from '../../../../shared/domain/errors/common-errors';
import { ForgotManagerPasswordUseCase } from '../../application/use-cases/forgot-manager-password.use-case';
import { LoginManagerUseCase } from '../../application/use-cases/login-manager.use-case';
import { LogoutManagerUseCase } from '../../application/use-cases/logout-manager.use-case';
import { RefreshManagerSessionUseCase } from '../../application/use-cases/refresh-manager-session.use-case';
import { ResetManagerPasswordUseCase } from '../../application/use-cases/reset-manager-password.use-case';
import { AccessTokenResponseDto } from './dto/access-token-response.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { LoginThrottlerGuard } from '../security/login-throttler.guard';
import {
  REFRESH_TOKEN_COOKIE_NAME,
  clearRefreshTokenCookie,
  setRefreshTokenCookie,
} from './refresh-token-cookie';

interface RequestWithRefreshCookie extends Request {
  cookies: Record<string, string | undefined>;
}

@ApiTags('managers-auth')
@Controller('admin/auth')
export class ManagersAuthController {
  constructor(
    private readonly loginManager: LoginManagerUseCase,
    private readonly refreshManagerSession: RefreshManagerSessionUseCase,
    private readonly logoutManager: LogoutManagerUseCase,
    private readonly forgotManagerPassword: ForgotManagerPasswordUseCase,
    private readonly resetManagerPassword: ResetManagerPasswordUseCase,
  ) {}

  @Post('login')
  @UseGuards(LoginThrottlerGuard)
  async login(
    @Body() dto: LoginDto,
    @Res({ passthrough: true }) res: Response,
  ): Promise<AccessTokenResponseDto> {
    const result = await this.loginManager.execute({
      email: dto.email,
      password: dto.password,
    });
    if (result.isFailure) throw result.error;

    setRefreshTokenCookie(res, result.value.refreshToken);
    return { accessToken: result.value.accessToken };
  }

  @Post('refresh')
  async refresh(
    @Req() req: RequestWithRefreshCookie,
    @Res({ passthrough: true }) res: Response,
  ): Promise<AccessTokenResponseDto> {
    const rawToken = req.cookies[REFRESH_TOKEN_COOKIE_NAME];
    if (!rawToken) {
      throw new UnauthorizedError('Missing refresh token cookie');
    }

    const result = await this.refreshManagerSession.execute(rawToken);
    if (result.isFailure) throw result.error;

    setRefreshTokenCookie(res, result.value.refreshToken);
    return { accessToken: result.value.accessToken };
  }

  @Post('logout')
  async logout(
    @Req() req: RequestWithRefreshCookie,
    @Res({ passthrough: true }) res: Response,
  ): Promise<{ success: true }> {
    const rawToken = req.cookies[REFRESH_TOKEN_COOKIE_NAME];
    if (rawToken) {
      await this.logoutManager.execute(rawToken);
    }
    clearRefreshTokenCookie(res);
    return { success: true };
  }

  @Post('forgot-password')
  async forgotPassword(
    @Body() dto: ForgotPasswordDto,
  ): Promise<{ accepted: true }> {
    await this.forgotManagerPassword.execute({ email: dto.email });
    return { accepted: true };
  }

  @Post('reset-password')
  async resetPassword(
    @Body() dto: ResetPasswordDto,
  ): Promise<{ success: true }> {
    const result = await this.resetManagerPassword.execute({
      token: dto.token,
      newPassword: dto.newPassword,
    });
    if (result.isFailure) throw result.error;
    return { success: true };
  }
}
