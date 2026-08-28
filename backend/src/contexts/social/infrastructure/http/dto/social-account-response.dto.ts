import { ApiProperty } from '@nestjs/swagger';

export class SocialAccountResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  municipalityId!: string;

  @ApiProperty({ enum: ['instagram', 'facebook'] })
  platform!: string;

  @ApiProperty()
  accountName!: string;

  @ApiProperty({ enum: ['connected', 'expired', 'error', 'revoked'] })
  status!: string;

  @ApiProperty()
  tokenExpiresAt!: string;

  @ApiProperty({ required: false, nullable: true })
  lastErrorMessage!: string | null;

  @ApiProperty()
  connectedAt!: string;

  @ApiProperty({ required: false, nullable: true })
  lastRefreshedAt!: string | null;
}

export class StartSocialOAuthResponseDto {
  @ApiProperty()
  authorizeUrl!: string;
}
