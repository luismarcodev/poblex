import { Module } from '@nestjs/common';
import { ManagersModule } from '../managers/managers.module';
import { AuthorizeBusinessMutationService } from './application/services/authorize-business-mutation.service';
import { ConfirmBusinessPhotoUseCase } from './application/use-cases/confirm-business-photo.use-case';
import { CreateBusinessUseCase } from './application/use-cases/create-business.use-case';
import { DeleteBusinessPhotoUseCase } from './application/use-cases/delete-business-photo.use-case';
import { GetBusinessDetailUseCase } from './application/use-cases/get-business-detail.use-case';
import { GetManagedBusinessDetailUseCase } from './application/use-cases/get-managed-business-detail.use-case';
import { ListBusinessCategoriesUseCase } from './application/use-cases/list-business-categories.use-case';
import { ListPublishedBusinessesUseCase } from './application/use-cases/list-published-businesses.use-case';
import {
  DeleteBusinessUseCase,
  ListManagedBusinessesUseCase,
  SetBusinessActiveUseCase,
} from './application/use-cases/manage-businesses.use-cases';
import { ReorderBusinessPhotosUseCase } from './application/use-cases/reorder-business-photos.use-case';
import { RequestBusinessPhotoUploadUrlUseCase } from './application/use-cases/request-business-photo-upload-url.use-case';
import { UpdateBusinessUseCase } from './application/use-cases/update-business.use-case';
import { BUSINESS_READER_PORT } from './domain/ports/business-reader.port';
import { BUSINESS_WRITER_PORT } from './domain/ports/business-writer.port';
import { BusinessesAdminController } from './infrastructure/http/businesses-admin.controller';
import { BusinessesController } from './infrastructure/http/businesses.controller';
import { BusinessPrismaRepository } from './infrastructure/persistence/prisma/business-prisma.repository';

@Module({
  imports: [ManagersModule],
  controllers: [BusinessesController, BusinessesAdminController],
  providers: [
    ListPublishedBusinessesUseCase,
    ListBusinessCategoriesUseCase,
    GetBusinessDetailUseCase,
    GetManagedBusinessDetailUseCase,
    CreateBusinessUseCase,
    UpdateBusinessUseCase,
    RequestBusinessPhotoUploadUrlUseCase,
    ConfirmBusinessPhotoUseCase,
    DeleteBusinessPhotoUseCase,
    ReorderBusinessPhotosUseCase,
    ListManagedBusinessesUseCase,
    SetBusinessActiveUseCase,
    DeleteBusinessUseCase,
    AuthorizeBusinessMutationService,
    BusinessPrismaRepository,
    { provide: BUSINESS_READER_PORT, useExisting: BusinessPrismaRepository },
    { provide: BUSINESS_WRITER_PORT, useExisting: BusinessPrismaRepository },
  ],
})
export class BusinessesModule {}
