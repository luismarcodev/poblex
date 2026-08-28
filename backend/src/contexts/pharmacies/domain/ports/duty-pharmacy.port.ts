import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { DutyPharmacy } from '../entities/duty-pharmacy.entity';

export interface FindPharmaciesParams {
  municipalityId: MunicipalityId;
  from: Date;
  to: Date;
}

export interface UpsertDutyPharmacyParams {
  municipalityId: MunicipalityId;
  date: Date;
  pharmacyName: string;
  address: string;
  phone: string;
  schedule: string;
}

export interface DutyPharmacyReaderPort {
  findInRange(params: FindPharmaciesParams): Promise<DutyPharmacy[]>;
  findByDate(
    municipalityId: MunicipalityId,
    date: Date,
  ): Promise<DutyPharmacy | null>;
}

export interface DutyPharmacyWriterPort {
  // UNIQUE (municipality_id, date): reasignar la guardia de un día sustituye
  // la anterior en vez de duplicarla.
  upsert(params: UpsertDutyPharmacyParams): Promise<DutyPharmacy>;
  delete(id: string): Promise<void>;
}

export const DUTY_PHARMACY_READER_PORT = Symbol('DUTY_PHARMACY_READER_PORT');
export const DUTY_PHARMACY_WRITER_PORT = Symbol('DUTY_PHARMACY_WRITER_PORT');
