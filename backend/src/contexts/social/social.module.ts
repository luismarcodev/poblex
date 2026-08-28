import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ManagersModule } from '../managers/managers.module';
import { SocialInboundPollCron } from '../../shared/infrastructure/cron/social-inbound-poll.cron';
import { SocialInstagramPublishCron } from '../../shared/infrastructure/cron/social-instagram-publish.cron';
import { SocialTokenRefreshCron } from '../../shared/infrastructure/cron/social-token-refresh.cron';
import { SocialOAuthStateService } from './application/services/social-oauth-state.service';
import { AdvanceInstagramPublicationUseCase } from './application/use-cases/advance-instagram-publication.use-case';
import { CompleteSocialOAuthCallbackUseCase } from './application/use-cases/complete-social-oauth-callback.use-case';
import { DisconnectSocialAccountUseCase } from './application/use-cases/disconnect-social-account.use-case';
import { ListSocialAccountsUseCase } from './application/use-cases/list-social-accounts.use-case';
import { PollInboundSocialPostsUseCase } from './application/use-cases/poll-inbound-social-posts.use-case';
import { PublishNewsToSocialChannelsUseCase } from './application/use-cases/publish-news-to-social-channels.use-case';
import { RefreshSocialTokensUseCase } from './application/use-cases/refresh-social-tokens.use-case';
import { StartSocialOAuthUseCase } from './application/use-cases/start-social-oauth.use-case';
import { SOCIAL_ACCOUNT_READER_PORT } from './domain/ports/social-account-reader.port';
import { SOCIAL_ACCOUNT_WRITER_PORT } from './domain/ports/social-account-writer.port';
import { INBOUND_NEWS_WRITER_PORT } from './domain/ports/inbound-news-writer.port';
import { SOCIAL_LISTENER_PORT } from './domain/ports/social-listener.port';
import { SOCIAL_OAUTH_PORT } from './domain/ports/social-oauth.port';
import {
  SOCIAL_PUBLICATION_READER_PORT,
  SOCIAL_PUBLICATION_WRITER_PORT,
} from './domain/ports/social-publication.port';
import { SOCIAL_PUBLISHER_PORT } from './domain/ports/social-publisher.port';
import { FakeMetaListenerAdapter } from './infrastructure/meta/fake/fake-meta-listener.adapter';
import { FakeMetaOAuthAdapter } from './infrastructure/meta/fake/fake-meta-oauth.adapter';
import { FakeMetaPublisherAdapter } from './infrastructure/meta/fake/fake-meta-publisher.adapter';
import { MetaGraphHttpClient } from './infrastructure/meta/meta-graph-http.client';
import { MetaListenerAdapter } from './infrastructure/meta/meta-listener.adapter';
import { MetaOAuthAdapter } from './infrastructure/meta/meta-oauth.adapter';
import { MetaPublisherAdapter } from './infrastructure/meta/meta-publisher.adapter';
import { NewsSocialShareAdapter } from './infrastructure/adapters/news-social-share.adapter';
import { SocialAccountsAdminController } from './infrastructure/http/social-accounts-admin.controller';
import { SocialOAuthCallbackController } from './infrastructure/http/social-oauth-callback.controller';
import { InboundNewsPrismaRepository } from './infrastructure/persistence/prisma/inbound-news-prisma.repository';
import { SocialAccountPrismaRepository } from './infrastructure/persistence/prisma/social-account-prisma.repository';
import { SocialPublicationPrismaRepository } from './infrastructure/persistence/prisma/social-publication-prisma.repository';
import { TokenCipherService } from '../../shared/infrastructure/security/token-cipher.service';

// Sin META_APP_ID configurado (todo desarrollo local, hasta que la app de
// Meta esté aprobada) se cae a los adaptadores fake — mismo patrón que
// NotificationsModule con FCM/consola.
@Module({
  imports: [ManagersModule],
  controllers: [SocialAccountsAdminController, SocialOAuthCallbackController],
  providers: [
    TokenCipherService,
    SocialOAuthStateService,
    MetaGraphHttpClient,
    StartSocialOAuthUseCase,
    CompleteSocialOAuthCallbackUseCase,
    DisconnectSocialAccountUseCase,
    ListSocialAccountsUseCase,
    PublishNewsToSocialChannelsUseCase,
    AdvanceInstagramPublicationUseCase,
    PollInboundSocialPostsUseCase,
    RefreshSocialTokensUseCase,
    SocialInstagramPublishCron,
    SocialInboundPollCron,
    SocialTokenRefreshCron,
    NewsSocialShareAdapter,
    SocialAccountPrismaRepository,
    SocialPublicationPrismaRepository,
    InboundNewsPrismaRepository,
    {
      provide: SOCIAL_ACCOUNT_READER_PORT,
      useExisting: SocialAccountPrismaRepository,
    },
    {
      provide: SOCIAL_ACCOUNT_WRITER_PORT,
      useExisting: SocialAccountPrismaRepository,
    },
    {
      provide: SOCIAL_PUBLICATION_READER_PORT,
      useExisting: SocialPublicationPrismaRepository,
    },
    {
      provide: SOCIAL_PUBLICATION_WRITER_PORT,
      useExisting: SocialPublicationPrismaRepository,
    },
    {
      provide: INBOUND_NEWS_WRITER_PORT,
      useExisting: InboundNewsPrismaRepository,
    },
    {
      provide: SOCIAL_OAUTH_PORT,
      useFactory: (config: ConfigService, http: MetaGraphHttpClient) =>
        config.get<string>('META_APP_ID')
          ? new MetaOAuthAdapter(http, config)
          : new FakeMetaOAuthAdapter(),
      inject: [ConfigService, MetaGraphHttpClient],
    },
    {
      provide: SOCIAL_PUBLISHER_PORT,
      useFactory: (config: ConfigService, http: MetaGraphHttpClient) =>
        config.get<string>('META_APP_ID')
          ? new MetaPublisherAdapter(http)
          : new FakeMetaPublisherAdapter(),
      inject: [ConfigService, MetaGraphHttpClient],
    },
    {
      provide: SOCIAL_LISTENER_PORT,
      useFactory: (config: ConfigService, http: MetaGraphHttpClient) =>
        config.get<string>('META_APP_ID')
          ? new MetaListenerAdapter(http)
          : new FakeMetaListenerAdapter(),
      inject: [ConfigService, MetaGraphHttpClient],
    },
  ],
  exports: [PublishNewsToSocialChannelsUseCase, NewsSocialShareAdapter],
})
export class SocialModule {}
