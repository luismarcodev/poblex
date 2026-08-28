import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Incident } from '../entities/incident.entity';
import { IncidentStatus } from '../value-objects/incident-status.vo';

export interface CreateIncidentParams {
  municipalityId: MunicipalityId;
  deviceId: DeviceId;
  category: string;
  description: string;
  photoUrl: string | null;
  lat: number | null;
  lng: number | null;
}

export interface ChangeStatusParams {
  incidentId: string;
  status: IncidentStatus;
  note: string | null;
  changedBy: string;
  // Fecha de purga de la foto, calculada por el dominio al resolver.
  photoPurgeAt: Date | null;
}

// Foto pendiente de borrar: la tarea diaria necesita la URL para localizar el
// objeto en el almacenamiento.
export interface PurgeablePhoto {
  incidentId: string;
  photoUrl: string;
}

export interface IncidentWriterPort {
  create(params: CreateIncidentParams): Promise<Incident>;

  // El cambio de estado y su entrada de historial van en la MISMA
  // transacción: un estado sin registro de quién lo cambió no es auditable.
  changeStatus(params: ChangeStatusParams): Promise<Incident>;

  attachPhoto(incidentId: string, photoUrl: string): Promise<Incident>;

  findPhotosToPurge(before: Date, limit: number): Promise<PurgeablePhoto[]>;
  clearPhoto(incidentId: string): Promise<void>;
}

export const INCIDENT_WRITER_PORT = Symbol('INCIDENT_WRITER_PORT');
