import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Alert } from '../entities/alert.entity';
import { AlertPhenomenonType } from '../value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../value-objects/alert-severity.vo';
import { AlertSource } from '../value-objects/alert-source.vo';

export interface CreateAlertParams {
  municipalityId: MunicipalityId;
  source: AlertSource;
  severity: AlertSeverity;
  phenomenonType: AlertPhenomenonType;
  phenomenon: string;
  body: LocalizedText;
  startAt: Date;
  endAt: Date | null;
  aemetId: string | null;
  createdBy: string | null;
}

export interface UpdateAlertFields {
  severity?: AlertSeverity;
  phenomenonType?: AlertPhenomenonType;
  phenomenon?: string;
  body?: LocalizedText;
  startAt?: Date;
  endAt?: Date | null;
  updatedBy: string;
}

export interface AlertWriterPort {
  create(params: CreateAlertParams): Promise<Alert>;
  update(id: string, fields: UpdateAlertFields): Promise<Alert>;
  delete(id: string): Promise<void>;

  // Deduplicación de la sincronización con AEMET: UNIQUE (municipality_id,
  // aemet_id) es la garantía real; esta consulta evita el error esperado.
  existsByAemetId(
    municipalityId: MunicipalityId,
    aemetId: string,
  ): Promise<boolean>;
}

export const ALERT_WRITER_PORT = Symbol('ALERT_WRITER_PORT');
