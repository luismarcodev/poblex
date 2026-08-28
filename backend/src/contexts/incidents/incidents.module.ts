import { Module } from '@nestjs/common';
import { IncidentPhotoPurgeCron } from '../../shared/infrastructure/cron/incident-photo-purge.cron';
import { DevicesModule } from '../devices/devices.module';
import { ManagersModule } from '../managers/managers.module';
import { MunicipalitiesModule } from '../municipalities/municipalities.module';
import { ChangeIncidentStatusUseCase } from './application/use-cases/change-incident-status.use-case';
import { GetMyIncidentDetailUseCase } from './application/use-cases/get-my-incident-detail.use-case';
import { ListManagedIncidentsUseCase } from './application/use-cases/list-managed-incidents.use-case';
import { ListMyIncidentsUseCase } from './application/use-cases/list-my-incidents.use-case';
import { PurgeIncidentPhotosUseCase } from './application/use-cases/purge-incident-photos.use-case';
import { ReportIncidentUseCase } from './application/use-cases/report-incident.use-case';
import { UploadIncidentPhotoUseCase } from './application/use-cases/upload-incident-photo.use-case';
import { INCIDENT_READER_PORT } from './domain/ports/incident-reader.port';
import { INCIDENT_WRITER_PORT } from './domain/ports/incident-writer.port';
import { IncidentsAdminController } from './infrastructure/http/incidents-admin.controller';
import { IncidentsController } from './infrastructure/http/incidents.controller';
import { IncidentPrismaRepository } from './infrastructure/persistence/prisma/incident-prisma.repository';

@Module({
  imports: [ManagersModule, DevicesModule, MunicipalitiesModule],
  controllers: [IncidentsController, IncidentsAdminController],
  providers: [
    ReportIncidentUseCase,
    UploadIncidentPhotoUseCase,
    ListMyIncidentsUseCase,
    GetMyIncidentDetailUseCase,
    ListManagedIncidentsUseCase,
    ChangeIncidentStatusUseCase,
    PurgeIncidentPhotosUseCase,
    IncidentPhotoPurgeCron,
    IncidentPrismaRepository,
    { provide: INCIDENT_READER_PORT, useExisting: IncidentPrismaRepository },
    { provide: INCIDENT_WRITER_PORT, useExisting: IncidentPrismaRepository },
  ],
})
export class IncidentsModule {}
