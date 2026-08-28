import { Inject, Injectable } from '@nestjs/common';
import { DEVICE_READER_PORT } from '../../domain/ports/device-reader.port';
import type { DeviceReaderPort } from '../../domain/ports/device-reader.port';

const INACTIVITY_DAYS = 180;

// Limpieza semanal: dispositivos sin actividad en 6 meses y sus tokens muertos.
@Injectable()
export class PurgeInactiveDevicesUseCase {
  constructor(
    @Inject(DEVICE_READER_PORT) private readonly devices: DeviceReaderPort,
  ) {}

  async execute(): Promise<number> {
    const threshold = new Date(Date.now() - INACTIVITY_DAYS * 86_400_000);
    return this.devices.deleteInactiveBefore(threshold);
  }
}
