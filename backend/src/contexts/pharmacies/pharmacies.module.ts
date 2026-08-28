import { Module } from '@nestjs/common';
import { ManagersModule } from '../managers/managers.module';
import {
  GetTodayDutyPharmacyUseCase,
  ListDutyPharmaciesUseCase,
  UpsertDutyPharmacyUseCase,
} from './application/use-cases/duty-pharmacy.use-cases';
import {
  DUTY_PHARMACY_READER_PORT,
  DUTY_PHARMACY_WRITER_PORT,
} from './domain/ports/duty-pharmacy.port';
import { PharmaciesAdminController } from './infrastructure/http/pharmacies-admin.controller';
import { PharmaciesController } from './infrastructure/http/pharmacies.controller';
import { DutyPharmacyPrismaRepository } from './infrastructure/persistence/prisma/duty-pharmacy-prisma.repository';

@Module({
  imports: [ManagersModule],
  controllers: [PharmaciesController, PharmaciesAdminController],
  providers: [
    ListDutyPharmaciesUseCase,
    GetTodayDutyPharmacyUseCase,
    UpsertDutyPharmacyUseCase,
    DutyPharmacyPrismaRepository,
    {
      provide: DUTY_PHARMACY_READER_PORT,
      useExisting: DutyPharmacyPrismaRepository,
    },
    {
      provide: DUTY_PHARMACY_WRITER_PORT,
      useExisting: DutyPharmacyPrismaRepository,
    },
  ],
})
export class PharmaciesModule {}
