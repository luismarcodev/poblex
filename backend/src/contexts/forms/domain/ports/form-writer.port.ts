import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Form, SubmissionAnswer } from '../entities/form.entity';
import { FormFieldType } from '../value-objects/form-field-type.vo';

export interface CreateFormFieldParams {
  key: string;
  label: LocalizedText;
  type: FormFieldType;
  required: boolean;
  options: string[];
  position: number;
}

export interface CreateFormParams {
  municipalityId: MunicipalityId;
  title: LocalizedText;
  description: LocalizedText;
  deadline: Date | null;
  fields: CreateFormFieldParams[];
}

export interface SubmitFormParams {
  formId: string;
  deviceId: DeviceId;
  answers: SubmissionAnswer[];
}

export interface FormWriterPort {
  create(params: CreateFormParams): Promise<Form>;
  delete(id: string): Promise<void>;

  // Falso si la restricción UNIQUE (form_id, device_id) rechaza el envío.
  submit(params: SubmitFormParams): Promise<boolean>;
}

export const FORM_WRITER_PORT = Symbol('FORM_WRITER_PORT');
