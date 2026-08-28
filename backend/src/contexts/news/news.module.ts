import { Module } from '@nestjs/common';
import { ManagersModule } from '../managers/managers.module';
import { SocialModule } from '../social/social.module';
import { NewsSocialShareAdapter } from '../social/infrastructure/adapters/news-social-share.adapter';
import { NewsAutoArchiveCron } from '../../shared/infrastructure/cron/news-auto-archive.cron';
import { AuthorizeNewsMutationService } from './application/services/authorize-news-mutation.service';
import { AutoArchiveNewsUseCase } from './application/use-cases/auto-archive-news.use-case';
import { ConfirmNewsAttachmentUseCase } from './application/use-cases/confirm-news-attachment.use-case';
import { CreateNewsUseCase } from './application/use-cases/create-news.use-case';
import { GetNewsDetailUseCase } from './application/use-cases/get-news-detail.use-case';
import { GetManagedNewsDetailUseCase } from './application/use-cases/get-managed-news-detail.use-case';
import { ListNewsCategoriesUseCase } from './application/use-cases/list-news-categories.use-case';
import { ListPublishedNewsUseCase } from './application/use-cases/list-published-news.use-case';
import {
  DeleteNewsUseCase,
  ListManagedNewsUseCase,
  SetNewsArchivedUseCase,
} from './application/use-cases/manage-news.use-cases';
import { RequestNewsAttachmentUploadUrlUseCase } from './application/use-cases/request-news-attachment-upload-url.use-case';
import { ToggleNewsPinUseCase } from './application/use-cases/toggle-news-pin.use-case';
import { UpdateNewsUseCase } from './application/use-cases/update-news.use-case';
import { NEWS_READER_PORT } from './domain/ports/news-reader.port';
import { NEWS_SOCIAL_SHARE_PORT } from './domain/ports/news-social-share.port';
import { NEWS_WRITER_PORT } from './domain/ports/news-writer.port';
import { NewsAdminController } from './infrastructure/http/news-admin.controller';
import { NewsController } from './infrastructure/http/news.controller';
import { NewsPrismaRepository } from './infrastructure/persistence/prisma/news-prisma.repository';

@Module({
  imports: [ManagersModule, SocialModule],
  controllers: [NewsController, NewsAdminController],
  providers: [
    ListPublishedNewsUseCase,
    ListNewsCategoriesUseCase,
    GetNewsDetailUseCase,
    GetManagedNewsDetailUseCase,
    CreateNewsUseCase,
    UpdateNewsUseCase,
    ToggleNewsPinUseCase,
    RequestNewsAttachmentUploadUrlUseCase,
    ConfirmNewsAttachmentUseCase,
    AutoArchiveNewsUseCase,
    ListManagedNewsUseCase,
    SetNewsArchivedUseCase,
    DeleteNewsUseCase,
    AuthorizeNewsMutationService,
    NewsAutoArchiveCron,
    NewsPrismaRepository,
    { provide: NEWS_READER_PORT, useExisting: NewsPrismaRepository },
    { provide: NEWS_WRITER_PORT, useExisting: NewsPrismaRepository },
    { provide: NEWS_SOCIAL_SHARE_PORT, useExisting: NewsSocialShareAdapter },
  ],
})
export class NewsModule {}
