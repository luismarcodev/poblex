import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Alert } from '../entities/alert.entity';

export interface FindAlertsParams {
  municipalityId: MunicipalityId;
  // Solo vigentes en este instante, o todo el histórico paginado.
  activeAt?: Date;
  cursor?: string;
  limit: number;
}

export interface AlertListResult {
  items: Alert[];
  nextCursor: string | null;
}

export interface AlertReaderPort {
  find(params: FindAlertsParams): Promise<AlertListResult>;
  findById(id: string): Promise<Alert | null>;
  findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Alert | null>;
}

export const ALERT_READER_PORT = Symbol('ALERT_READER_PORT');
