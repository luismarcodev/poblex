import { SocialAccount } from '../../domain/entities/social-account.entity';
import { SocialAccountResponseDto } from '../http/dto/social-account-response.dto';

export class SocialHttpMapper {
  static toResponseDto(account: SocialAccount): SocialAccountResponseDto {
    return {
      id: account.id,
      municipalityId: account.municipalityId.value,
      platform: account.platform.value,
      accountName: account.accountName,
      status: account.status,
      tokenExpiresAt: account.tokenExpiresAt.toISOString(),
      lastErrorMessage: account.lastErrorMessage,
      connectedAt: account.connectedAt.toISOString(),
      lastRefreshedAt: account.lastRefreshedAt?.toISOString() ?? null,
    };
  }
}
