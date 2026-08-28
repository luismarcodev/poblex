import {
  DeleteObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  FileStoragePort,
  PresignedUploadUrl,
  PutObjectParams,
} from './file-storage.port';

const UPLOAD_URL_TTL_SECONDS = 300;

// Adapter para Cloudflare R2 (S3-compatible, jurisdicción UE). Implementa el
// puerto de dominio — el dominio de `news` no sabe que existe R2 ni S3.
@Injectable()
export class R2FileStorageAdapter implements FileStoragePort {
  private readonly client: S3Client;
  private readonly bucket: string;
  private readonly publicBaseUrl: string;

  constructor(config: ConfigService) {
    this.bucket = config.get<string>('R2_BUCKET', '');
    this.publicBaseUrl = config.get<string>('R2_PUBLIC_BASE_URL', '');
    this.client = new S3Client({
      region: 'auto',
      endpoint: config.get<string>('R2_ENDPOINT'),
      credentials: {
        accessKeyId: config.get<string>('R2_ACCESS_KEY', ''),
        secretAccessKey: config.get<string>('R2_SECRET_KEY', ''),
      },
    });
  }

  async createPresignedUploadUrl(params: {
    key: string;
    contentType: string;
  }): Promise<PresignedUploadUrl> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: params.key,
      ContentType: params.contentType,
    });
    const uploadUrl = await getSignedUrl(this.client, command, {
      expiresIn: UPLOAD_URL_TTL_SECONDS,
    });

    return {
      uploadUrl,
      publicUrl: `${this.publicBaseUrl}/${params.key}`,
      expiresInSeconds: UPLOAD_URL_TTL_SECONDS,
    };
  }

  async putObject(params: PutObjectParams): Promise<{ publicUrl: string }> {
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: params.key,
        ContentType: params.contentType,
        Body: params.body,
      }),
    );
    return { publicUrl: `${this.publicBaseUrl}/${params.key}` };
  }

  async deleteByPublicUrl(publicUrl: string): Promise<void> {
    const prefix = `${this.publicBaseUrl}/`;
    if (!publicUrl.startsWith(prefix)) {
      // Una URL ajena al bucket no se borra: sería intentar operar sobre algo
      // que este adaptador no gestiona.
      throw new Error(
        `Public URL does not belong to this bucket: ${publicUrl}`,
      );
    }

    await this.client.send(
      new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: publicUrl.slice(prefix.length),
      }),
    );
  }
}
