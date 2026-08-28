import { Injectable } from '@nestjs/common';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { TokenCipherService } from '../../../../../shared/infrastructure/security/token-cipher.service';
import { SocialAccount } from '../../../domain/entities/social-account.entity';
import type {
  SocialAccountReaderPort,
  SocialAccountWithToken,
} from '../../../domain/ports/social-account-reader.port';
import type {
  SocialAccountWriterPort,
  UpsertSocialAccountParams,
} from '../../../domain/ports/social-account-writer.port';
import { SocialPlatform } from '../../../domain/value-objects/social-platform.vo';
import { SocialAccountMapper } from './social-account.mapper';

@Injectable()
export class SocialAccountPrismaRepository
  implements SocialAccountReaderPort, SocialAccountWriterPort
{
  constructor(
    private readonly prisma: PrismaService,
    private readonly cipher: TokenCipherService,
  ) {}

  async findByMunicipality(
    municipalityId: MunicipalityId,
  ): Promise<SocialAccount[]> {
    const rows = await this.prisma.socialAccount.findMany({
      where: { municipalityId: municipalityId.value },
      orderBy: { connectedAt: 'desc' },
    });
    return rows.map((row) => SocialAccountMapper.toDomain(row));
  }

  async findConnected(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
  ): Promise<SocialAccount | null> {
    const row = await this.prisma.socialAccount.findUnique({
      where: {
        municipalityId_platform: {
          municipalityId: municipalityId.value,
          platform: SocialAccountMapper.toPrismaPlatform(platform),
        },
      },
    });
    return row ? SocialAccountMapper.toDomain(row) : null;
  }

  async findAccessTokenForPublishing(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
  ): Promise<SocialAccountWithToken | null> {
    const row = await this.prisma.socialAccount.findUnique({
      where: {
        municipalityId_platform: {
          municipalityId: municipalityId.value,
          platform: SocialAccountMapper.toPrismaPlatform(platform),
        },
      },
    });
    if (!row || row.status !== 'CONNECTED') return null;

    return {
      account: SocialAccountMapper.toDomain(row),
      accessToken: this.cipher.decrypt(Buffer.from(row.accessTokenCipher)),
    };
  }

  async findAllConnected(): Promise<SocialAccountWithToken[]> {
    const rows = await this.prisma.socialAccount.findMany({
      where: { status: 'CONNECTED' },
    });
    return rows.map((row) => ({
      account: SocialAccountMapper.toDomain(row),
      accessToken: this.cipher.decrypt(Buffer.from(row.accessTokenCipher)),
    }));
  }

  async findAllExpiringBefore(date: Date): Promise<SocialAccountWithToken[]> {
    const rows = await this.prisma.socialAccount.findMany({
      where: { status: 'CONNECTED', tokenExpiresAt: { lt: date } },
    });
    return rows.map((row) => ({
      account: SocialAccountMapper.toDomain(row),
      accessToken: this.cipher.decrypt(Buffer.from(row.accessTokenCipher)),
    }));
  }

  async upsertFromOAuth(
    params: UpsertSocialAccountParams,
  ): Promise<SocialAccount> {
    const platform = SocialAccountMapper.toPrismaPlatform(params.platform);
    // Prisma tipa Bytes como Uint8Array<ArrayBuffer> en modo estricto; el
    // Buffer de node:crypto no encaja tal cual, hace falta la copia.
    const accessTokenCipher = new Uint8Array(
      this.cipher.encrypt(params.accessToken),
    );

    // Reconectar sustituye la fila existente, no duplica — UNIQUE([municipalityId, platform]).
    const row = await this.prisma.socialAccount.upsert({
      where: {
        municipalityId_platform: {
          municipalityId: params.municipalityId.value,
          platform,
        },
      },
      create: {
        municipalityId: params.municipalityId.value,
        platform,
        externalAccountId: params.externalAccountId,
        accountName: params.accountName,
        accessTokenCipher,
        tokenExpiresAt: params.tokenExpiresAt,
        status: 'CONNECTED',
        connectedByManagerId: params.connectedByManagerId,
      },
      update: {
        externalAccountId: params.externalAccountId,
        accountName: params.accountName,
        accessTokenCipher,
        tokenExpiresAt: params.tokenExpiresAt,
        status: 'CONNECTED',
        lastErrorMessage: null,
        connectedByManagerId: params.connectedByManagerId,
        connectedAt: new Date(),
      },
    });
    return SocialAccountMapper.toDomain(row);
  }

  async findAdminById(id: string): Promise<SocialAccount | null> {
    const row = await this.prisma.socialAccount.findUnique({ where: { id } });
    return row ? SocialAccountMapper.toDomain(row) : null;
  }

  async updateTokens(
    id: string,
    fields: { accessToken: string; tokenExpiresAt: Date },
  ): Promise<SocialAccount> {
    const row = await this.prisma.socialAccount.update({
      where: { id },
      data: {
        accessTokenCipher: new Uint8Array(
          this.cipher.encrypt(fields.accessToken),
        ),
        tokenExpiresAt: fields.tokenExpiresAt,
        status: 'CONNECTED',
        lastErrorMessage: null,
        lastRefreshedAt: new Date(),
      },
    });
    return SocialAccountMapper.toDomain(row);
  }

  async markError(id: string, message: string): Promise<SocialAccount> {
    const row = await this.prisma.socialAccount.update({
      where: { id },
      data: { status: 'ERROR', lastErrorMessage: message },
    });
    return SocialAccountMapper.toDomain(row);
  }

  async disconnect(id: string): Promise<void> {
    await this.prisma.socialAccount.delete({ where: { id } });
  }
}
