import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Form } from '../entities/form.entity';

export interface FindFormsParams {
  municipalityId: MunicipalityId;
  openAt?: Date;
  cursor?: string;
  limit: number;
}

export interface FormListResult {
  items: Form[];
  nextCursor: string | null;
}

// Un envío tal y como sale para la exportación a CSV: los valores indexados
// por id de campo.
export interface SubmissionExportRow {
  submittedAt: Date;
  valuesByFieldId: Map<string, string>;
}

export interface FormReaderPort {
  find(params: FindFormsParams): Promise<FormListResult>;
  findById(id: string): Promise<Form | null>;
  findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Form | null>;
  hasSubmitted(formId: string, deviceId: DeviceId): Promise<boolean>;
  findSubmissionsForExport(formId: string): Promise<SubmissionExportRow[]>;
}

export const FORM_READER_PORT = Symbol('FORM_READER_PORT');
