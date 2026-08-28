import { Module } from '@nestjs/common';
import { AemetSyncCron } from '../../shared/infrastructure/cron/aemet-sync.cron';
import { ManagersModule } from '../managers/managers.module';
import { MunicipalitiesModule } from '../municipalities/municipalities.module';
import { AuthorizeAlertMutationService } from './application/services/authorize-alert-mutation.service';
import { CreateManualAlertUseCase } from './application/use-cases/create-manual-alert.use-case';
import { DeleteManualAlertUseCase } from './application/use-cases/delete-manual-alert.use-case';
import { GetAlertDetailUseCase } from './application/use-cases/get-alert-detail.use-case';
import { ListAlertsUseCase } from './application/use-cases/list-alerts.use-case';
import { SyncAemetAlertsUseCase } from './application/use-cases/sync-aemet-alerts.use-case';
import { UpdateManualAlertUseCase } from './application/use-cases/update-manual-alert.use-case';
import { ALERT_READER_PORT } from './domain/ports/alert-reader.port';
import { ALERT_WRITER_PORT } from './domain/ports/alert-writer.port';
import { WEATHER_WARNING_PROVIDER_PORT } from './domain/ports/weather-warning.port';
import { AemetWeatherWarningAdapter } from './infrastructure/aemet/aemet-weather-warning.adapter';
import { AlertsAdminController } from './infrastructure/http/alerts-admin.controller';
import { AlertsController } from './infrastructure/http/alerts.controller';
import { AlertPrismaRepository } from './infrastructure/persistence/prisma/alert-prisma.repository';

@Module({
  imports: [ManagersModule, MunicipalitiesModule],
  controllers: [AlertsController, AlertsAdminController],
  providers: [
    ListAlertsUseCase,
    GetAlertDetailUseCase,
    CreateManualAlertUseCase,
    UpdateManualAlertUseCase,
    DeleteManualAlertUseCase,
    SyncAemetAlertsUseCase,
    AuthorizeAlertMutationService,
    AemetSyncCron,
    AlertPrismaRepository,
    { provide: ALERT_READER_PORT, useExisting: AlertPrismaRepository },
    { provide: ALERT_WRITER_PORT, useExisting: AlertPrismaRepository },
    {
      provide: WEATHER_WARNING_PROVIDER_PORT,
      useClass: AemetWeatherWarningAdapter,
    },
  ],
})
export class AlertsModule {}
