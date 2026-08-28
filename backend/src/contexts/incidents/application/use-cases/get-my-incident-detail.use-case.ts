import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { IncidentStatusChange } from '../../domain/entities/incident-status-change.entity';
import { Incident } from '../../domain/entities/incident.entity';
import {
  IncidentNotFoundError,
  IncidentNotOwnedError,
} from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';

export interface IncidentDetail {
  incident: Incident;
  history: IncidentStatusChange[];
}

@Injectable()
export class GetMyIncidentDetailUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(
    incidentId: string,
    rawDeviceId: string | undefined,
  ): Promise<Result<IncidentDetail>> {
    const device = await this.requireDevice.ensure(rawDeviceId);
    if (device.isFailure) return Result.failure(device.error);

    const incident = await this.reader.findById(incidentId);
    if (!incident) {
      return Result.failure(new IncidentNotFoundError(incidentId));
    }
    if (!incident.belongsToDevice(device.value.id)) {
      return Result.failure(new IncidentNotOwnedError(incidentId));
    }

    const history = await this.reader.findStatusHistory(incidentId);
    return Result.success({ incident, history });
  }
}
