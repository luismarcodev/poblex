import { Injectable } from '@nestjs/common';
import type { SocialAccountWithToken } from '../../domain/ports/social-account-reader.port';
import type {
  InboundSocialPost,
  SocialListenerPort,
} from '../../domain/ports/social-listener.port';
import { MetaGraphHttpClient } from './meta-graph-http.client';

interface FacebookPost {
  id: string;
  message?: string;
  full_picture?: string;
  permalink_url: string;
  created_time: string;
}

interface FacebookPostsResponse {
  data: FacebookPost[];
}

interface InstagramMedia {
  id: string;
  caption?: string;
  media_url?: string;
  permalink: string;
  timestamp: string;
}

interface InstagramMediaResponse {
  data: InstagramMedia[];
}

@Injectable()
export class MetaListenerAdapter implements SocialListenerPort {
  constructor(private readonly http: MetaGraphHttpClient) {}

  async fetchRecentPosts(
    account: SocialAccountWithToken,
    since?: Date,
  ): Promise<InboundSocialPost[]> {
    return account.account.platform.isInstagram
      ? this.fetchInstagramMedia(account)
      : this.fetchFacebookPosts(account, since);
  }

  private async fetchFacebookPosts(
    account: SocialAccountWithToken,
    since?: Date,
  ): Promise<InboundSocialPost[]> {
    const params: Record<string, string> = {
      access_token: account.accessToken,
      fields: 'id,message,full_picture,permalink_url,created_time',
    };
    if (since) params.since = String(Math.floor(since.getTime() / 1000));

    const result = await this.http.get<FacebookPostsResponse>(
      `/${account.account.externalAccountId}/posts`,
      params,
    );
    return result.data.map((post) => ({
      externalId: post.id,
      caption: post.message ?? null,
      imageUrl: post.full_picture ?? null,
      permalink: post.permalink_url,
      publishedAt: new Date(post.created_time),
    }));
  }

  private async fetchInstagramMedia(
    account: SocialAccountWithToken,
  ): Promise<InboundSocialPost[]> {
    const result = await this.http.get<InstagramMediaResponse>(
      `/${account.account.externalAccountId}/media`,
      {
        access_token: account.accessToken,
        fields: 'id,caption,media_url,permalink,timestamp',
      },
    );
    return result.data.map((media) => ({
      externalId: media.id,
      caption: media.caption ?? null,
      imageUrl: media.media_url ?? null,
      permalink: media.permalink,
      publishedAt: new Date(media.timestamp),
    }));
  }
}
