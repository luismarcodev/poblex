import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { DisconnectSocialAccountUseCase } from '../../application/use-cases/disconnect-social-account.use-case';
import { ListSocialAccountsUseCase } from '../../application/use-cases/list-social-accounts.use-case';
import { StartSocialOAuthUseCase } from '../../application/use-cases/start-social-oauth.use-case';
import { SocialHttpMapper } from '../mappers/social-http.mapper';
import {
  SocialAccountResponseDto,
  StartSocialOAuthResponseDto,
} from './dto/social-account-response.dto';
import { StartSocialOAuthDto } from './dto/start-social-oauth.dto';

class ListSocialAccountsQueryDto {
  @ApiProperty()
  @IsUUID('4')
  municipalityId!: string;
}

@ApiTags('social-accounts-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/social-accounts')
export class SocialAccountsAdminController {
  constructor(
    private readonly listAccounts: ListSocialAccountsUseCase,
    private readonly startOAuth: StartSocialOAuthUseCase,
    private readonly disconnectAccount: DisconnectSocialAccountUseCase,
  ) {}

  @Get()
  async list(
    @CurrentManagerId() managerId: string,
    @Query() query: ListSocialAccountsQueryDto,
  ): Promise<SocialAccountResponseDto[]> {
    const result = await this.listAccounts.execute({
      managerId,
      municipalityId: query.municipalityId,
    });
    if (result.isFailure) throw result.error;
    return result.value.map((account) =>
      SocialHttpMapper.toResponseDto(account),
    );
  }

  @Post(':platform/connect')
  async connect(
    @CurrentManagerId() managerId: string,
    @Param('platform') platform: string,
    @Body() body: StartSocialOAuthDto,
  ): Promise<StartSocialOAuthResponseDto> {
    const result = await this.startOAuth.execute({
      managerId,
      municipalityId: body.municipalityId,
      platform,
    });
    if (result.isFailure) throw result.error;
    return result.value;
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async disconnect(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.disconnectAccount.execute({ id, managerId });
    if (result.isFailure) throw result.error;
  }
}
