import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { DeviceNotRegisteredError } from '../../domain/errors/device-errors';
import { Device } from '../../domain/entities/device.entity';
import { DEVICE_READER_PORT } from '../../domain/ports/device-reader.port';
import type { DeviceReaderPort } from '../../domain/ports/device-reader.port';

// Guardia de escritura del vecino, reutilizada por eventos, incidencias,
// encuestas y formularios: valida el formato del X-Device-Id y comprueba que
// el dispositivo está dado de alta.
@Injectable()
export class RequireRegisteredDeviceService {
  constructor(
    @Inject(DEVICE_READER_PORT) private readonly devices: DeviceReaderPort,
  ) {}

  async ensure(rawDeviceId: string | undefined): Promise<Result<Device>> {
    let deviceId: DeviceId;
    try {
      deviceId = DeviceId.create(rawDeviceId ?? '');
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const device = await this.devices.findRegisteredAndTouch(deviceId);
    if (!device) {
      return Result.failure(new DeviceNotRegisteredError(deviceId.value));
    }
    return Result.success(device);
  }
}
