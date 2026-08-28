import { Module } from '@nestjs/common';
import { MunicipalitiesModule } from '../municipalities/municipalities.module';
import { NotifyDevicesService } from './application/services/notify-devices.service';
import { RequireRegisteredDeviceService } from './application/services/require-registered-device.service';
import { PurgeInactiveDevicesUseCase } from './application/use-cases/purge-inactive-devices.use-case';
import { RegisterDeviceUseCase } from './application/use-cases/register-device.use-case';
import { UpdateDeviceMunicipalityUseCase } from './application/use-cases/update-device-municipality.use-case';
import { UpdateDevicePushRegistrationUseCase } from './application/use-cases/update-device-push-registration.use-case';
import { DEVICE_READER_PORT } from './domain/ports/device-reader.port';
import { DEVICE_WRITER_PORT } from './domain/ports/device-writer.port';
import { DevicesController } from './infrastructure/http/devices.controller';
import { DevicePrismaRepository } from './infrastructure/persistence/prisma/device-prisma.repository';
import { InactiveDevicesCleanupCron } from '../../shared/infrastructure/cron/inactive-devices-cleanup.cron';

@Module({
  imports: [MunicipalitiesModule],
  controllers: [DevicesController],
  providers: [
    RegisterDeviceUseCase,
    UpdateDeviceMunicipalityUseCase,
    UpdateDevicePushRegistrationUseCase,
    PurgeInactiveDevicesUseCase,
    NotifyDevicesService,
    RequireRegisteredDeviceService,
    InactiveDevicesCleanupCron,
    DevicePrismaRepository,
    { provide: DEVICE_WRITER_PORT, useExisting: DevicePrismaRepository },
    { provide: DEVICE_READER_PORT, useExisting: DevicePrismaRepository },
  ],
  // Otros contextos (incidencias, eventos) envían push dirigido a través de
  // este servicio; el puerto de lectura queda disponible para sus casos de uso.
  exports: [
    NotifyDevicesService,
    RequireRegisteredDeviceService,
    DEVICE_READER_PORT,
  ],
})
export class DevicesModule {}
