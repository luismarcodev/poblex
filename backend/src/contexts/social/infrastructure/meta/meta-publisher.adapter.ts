import { Injectable } from '@nestjs/common';
import type {
  CreateInstagramContainerParams,
  FacebookPublishResult,
  InstagramContainerStatus,
  PublishToFacebookParams,
  SocialPublisherPort,
} from '../../domain/ports/social-publisher.port';
import { MetaGraphHttpClient } from './meta-graph-http.client';

interface FacebookPostResponse {
  id: string;
  post_id?: string;
}

interface CreationIdResponse {
  id: string;
}

interface ContainerStatusResponse {
  status_code: 'IN_PROGRESS' | 'FINISHED' | 'ERROR' | 'EXPIRED';
}

const CONTAINER_STATUS_MAP: Record<
  ContainerStatusResponse['status_code'],
  InstagramContainerStatus
> = {
  IN_PROGRESS: 'in_progress',
  FINISHED: 'finished',
  ERROR: 'error',
  EXPIRED: 'expired',
};

@Injectable()
export class MetaPublisherAdapter implements SocialPublisherPort {
  constructor(private readonly http: MetaGraphHttpClient) {}

  async publishToFacebook(
    params: PublishToFacebookParams,
  ): Promise<FacebookPublishResult> {
    // Con imagen: /{page-id}/photos (publica la foto y crea el post a la vez).
    // Sin imagen: /{page-id}/feed (solo texto).
    const path = params.imageUrl
      ? `/${params.pageId}/photos`
      : `/${params.pageId}/feed`;
    const body: Record<string, string> = {
      access_token: params.pageAccessToken,
      ...(params.imageUrl
        ? { url: params.imageUrl, caption: params.message }
        : { message: params.message }),
    };
    const result = await this.http.post<FacebookPostResponse>(path, body);
    return { externalPostId: result.post_id ?? result.id };
  }

  async createInstagramContainer(
    params: CreateInstagramContainerParams,
  ): Promise<{ containerId: string }> {
    const result = await this.http.post<CreationIdResponse>(
      `/${params.igBusinessAccountId}/media`,
      {
        access_token: params.accessToken,
        image_url: params.imageUrl,
        caption: params.caption,
      },
    );
    return { containerId: result.id };
  }

  async getInstagramContainerStatus(
    containerId: string,
    accessToken: string,
  ): Promise<InstagramContainerStatus> {
    const result = await this.http.get<ContainerStatusResponse>(
      `/${containerId}`,
      {
        fields: 'status_code',
        access_token: accessToken,
      },
    );
    return CONTAINER_STATUS_MAP[result.status_code];
  }

  async publishInstagramContainer(
    igBusinessAccountId: string,
    containerId: string,
    accessToken: string,
  ): Promise<{ externalPostId: string }> {
    const result = await this.http.post<CreationIdResponse>(
      `/${igBusinessAccountId}/media_publish`,
      {
        access_token: accessToken,
        creation_id: containerId,
      },
    );
    return { externalPostId: result.id };
  }
}
