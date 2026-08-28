import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { IncidentStatusChange } from '../entities/incident-status-change.entity';
import { Incident } from '../entities/incident.entity';
import { IncidentStatus } from '../value-objects/incident-status.vo';

export interface FindDeviceIncidentsParams {
  deviceId: DeviceId;
  cursor?: string;
  limit: number;
}

export interface FindManagerIncidentsParams {
  municipalityId: MunicipalityId;
  status?: IncidentStatus;
  category?: string;
  cursor?: string;
  limit: number;
}

export interface IncidentListResult {
  items: Incident[];
  nextCursor: string | null;
}

export interface IncidentReaderPort {
  findByDevice(params: FindDeviceIncidentsParams): Promise<IncidentListResult>;
  findForManager(
    params: FindManagerIncidentsParams,
  ): Promise<IncidentListResult>;
  findById(id: string): Promise<Incident | null>;
  findStatusHistory(incidentId: string): Promise<IncidentStatusChange[]>;
}

export const INCIDENT_READER_PORT = Symbol('INCIDENT_READER_PORT');
