import { Module } from '@nestjs/common';
import { DevicesModule } from '../devices/devices.module';
import { ManagersModule } from '../managers/managers.module';
import {
  AuthorizeFormMutationService,
  CreateFormUseCase,
  DeleteFormUseCase,
  ExportFormSubmissionsUseCase,
} from './application/use-cases/manage-forms.use-cases';
import {
  GetFormDetailUseCase,
  ListFormsUseCase,
} from './application/use-cases/query-forms.use-cases';
import { SubmitFormUseCase } from './application/use-cases/submit-form.use-case';
import { FORM_READER_PORT } from './domain/ports/form-reader.port';
import { FORM_WRITER_PORT } from './domain/ports/form-writer.port';
import { FormsAdminController } from './infrastructure/http/forms-admin.controller';
import { FormsController } from './infrastructure/http/forms.controller';
import { FormPrismaRepository } from './infrastructure/persistence/prisma/form-prisma.repository';

@Module({
  imports: [ManagersModule, DevicesModule],
  controllers: [FormsController, FormsAdminController],
  providers: [
    ListFormsUseCase,
    GetFormDetailUseCase,
    SubmitFormUseCase,
    CreateFormUseCase,
    DeleteFormUseCase,
    ExportFormSubmissionsUseCase,
    AuthorizeFormMutationService,
    FormPrismaRepository,
    { provide: FORM_READER_PORT, useExisting: FormPrismaRepository },
    { provide: FORM_WRITER_PORT, useExisting: FormPrismaRepository },
  ],
})
export class FormsModule {}
