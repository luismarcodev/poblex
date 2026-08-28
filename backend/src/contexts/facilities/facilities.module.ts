import { Module } from '@nestjs/common';
import { DevicesModule } from '../devices/devices.module';
import { ManagersModule } from '../managers/managers.module';
import { MunicipalitiesModule } from '../municipalities/municipalities.module';
import { CancelReservationAsManagerUseCase } from './application/use-cases/cancel-reservation-as-manager.use-case';
import { CancelReservationUseCase } from './application/use-cases/cancel-reservation.use-case';
import { CreateFacilityUseCase } from './application/use-cases/create-facility.use-case';
import { CreateReservationUseCase } from './application/use-cases/create-reservation.use-case';
import { GetFacilityAvailabilityUseCase } from './application/use-cases/get-facility-availability.use-case';
import { GetFacilityUseCase } from './application/use-cases/get-facility.use-case';
import { ListFacilitiesUseCase } from './application/use-cases/list-facilities.use-case';
import { ListManagedReservationsUseCase } from './application/use-cases/list-managed-reservations.use-case';
import { ListMyReservationsUseCase } from './application/use-cases/list-my-reservations.use-case';
import { UpdateFacilityUseCase } from './application/use-cases/update-facility.use-case';
import { FACILITY_READER_PORT } from './domain/ports/facility-reader.port';
import { FACILITY_WRITER_PORT } from './domain/ports/facility-writer.port';
import { RESERVATION_READER_PORT } from './domain/ports/reservation-reader.port';
import { RESERVATION_WRITER_PORT } from './domain/ports/reservation-writer.port';
import {
  FacilitiesAdminController,
  ReservationsAdminController,
} from './infrastructure/http/facilities-admin.controller';
import {
  FacilitiesController,
  ReservationsController,
} from './infrastructure/http/facilities.controller';
import { FacilityPrismaRepository } from './infrastructure/persistence/prisma/facility-prisma.repository';
import { ReservationPrismaRepository } from './infrastructure/persistence/prisma/reservation-prisma.repository';

@Module({
  imports: [ManagersModule, DevicesModule, MunicipalitiesModule],
  controllers: [
    FacilitiesController,
    ReservationsController,
    FacilitiesAdminController,
    ReservationsAdminController,
  ],
  providers: [
    ListFacilitiesUseCase,
    GetFacilityUseCase,
    GetFacilityAvailabilityUseCase,
    CreateReservationUseCase,
    CancelReservationUseCase,
    CancelReservationAsManagerUseCase,
    ListMyReservationsUseCase,
    ListManagedReservationsUseCase,
    CreateFacilityUseCase,
    UpdateFacilityUseCase,
    FacilityPrismaRepository,
    ReservationPrismaRepository,
    { provide: FACILITY_READER_PORT, useExisting: FacilityPrismaRepository },
    { provide: FACILITY_WRITER_PORT, useExisting: FacilityPrismaRepository },
    {
      provide: RESERVATION_READER_PORT,
      useExisting: ReservationPrismaRepository,
    },
    {
      provide: RESERVATION_WRITER_PORT,
      useExisting: ReservationPrismaRepository,
    },
  ],
})
export class FacilitiesModule {}
