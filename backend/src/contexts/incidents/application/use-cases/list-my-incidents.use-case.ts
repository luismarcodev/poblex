import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type {
  IncidentListResult,
  IncidentReaderPort,
} from '../../domain/ports/incident-reader.port';

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

// Las incidencias son privadas: un dispositivo solo ve las suyas. No existe
// listado público.
@Injectable()
export class ListMyIncidentsUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(
    rawDeviceId: string | undefined,
    cursor?: string,
    limit?: number,
  ): Promise<Result<IncidentListResult>> {
    const device = await this.requireDevice.ensure(rawDeviceId);
    if (device.isFailure) return Result.failure(device.error);

    const result = await this.reader.findByDevice({
      deviceId: device.value.id,
      cursor,
      limit: limit && limit > 0 && limit <= MAX_LIMIT ? limit : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}
