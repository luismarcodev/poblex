import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { FormFieldType } from '../value-objects/form-field-type.vo';

export interface FormFieldProps {
  id: string;
  key: string;
  label: LocalizedText;
  type: FormFieldType;
  required: boolean;
  // Valores admitidos en los campos de tipo select. Vacío en el resto.
  options: string[];
  position: number;
}

export class FormField {
  private constructor(private readonly props: FormFieldProps) {}

  static create(props: FormFieldProps): FormField {
    if (props.type.requiresOptions && props.options.length === 0) {
      throw new ValidationError(
        `Field "${props.key}" is a select and requires at least one option`,
      );
    }
    return new FormField(props);
  }

  get id(): string {
    return this.props.id;
  }

  get key(): string {
    return this.props.key;
  }

  get label(): LocalizedText {
    return this.props.label;
  }

  get type(): FormFieldType {
    return this.props.type;
  }

  get required(): boolean {
    return this.props.required;
  }

  get options(): string[] {
    return this.props.options;
  }

  get position(): number {
    return this.props.position;
  }
}

export interface FormProps {
  id: string;
  municipalityId: MunicipalityId;
  title: LocalizedText;
  description: LocalizedText;
  deadline: Date | null;
  fields: FormField[];
}

export interface SubmissionAnswer {
  fieldId: string;
  value: string;
}

export class Form {
  private constructor(private readonly props: FormProps) {}

  static create(props: FormProps): Form {
    if (props.fields.length === 0) {
      throw new ValidationError('A form requires at least one field');
    }
    const keys = props.fields.map((field) => field.key);
    if (new Set(keys).size !== keys.length) {
      throw new ValidationError('Form field keys must be unique');
    }
    return new Form(props);
  }

  // Un formulario con plazo vencido no admite envíos. Sin plazo, siempre abierto.
  isOpenAt(instant: Date): boolean {
    return (
      this.props.deadline === null ||
      this.props.deadline.getTime() > instant.getTime()
    );
  }

  // Validación completa del envío contra la definición del formulario. Toda
  // la regla vive aquí, no repartida entre controlador y repositorio.
  // Devuelve la lista de motivos de rechazo; vacía significa que vale.
  validateSubmission(answers: SubmissionAnswer[]): string[] {
    const errors: string[] = [];
    const seenFieldIds = new Set<string>();
    for (const answer of answers) {
      if (seenFieldIds.has(answer.fieldId)) {
        errors.push(`Duplicate answer for field id: ${answer.fieldId}`);
      }
      seenFieldIds.add(answer.fieldId);
    }
    const byFieldId = new Map(
      answers.map((answer) => [answer.fieldId, answer]),
    );

    for (const field of this.props.fields) {
      const answer = byFieldId.get(field.id);
      const value = answer?.value.trim() ?? '';

      if (value === '') {
        if (field.required) {
          errors.push(`Field "${field.key}" is required`);
        }
        continue;
      }

      const reason = field.type.rejectionReason(value);
      if (reason) {
        errors.push(`Field "${field.key}": ${reason}`);
        continue;
      }

      if (field.type.requiresOptions && !field.options.includes(value)) {
        errors.push(
          `Field "${field.key}": "${value}" is not an allowed option`,
        );
      }
    }

    // Respuestas a campos que no existen: el envío no corresponde a este
    // formulario o alguien está inventando campos.
    const knownIds = new Set(this.props.fields.map((field) => field.id));
    for (const answer of answers) {
      if (!knownIds.has(answer.fieldId)) {
        errors.push(`Unknown field id: ${answer.fieldId}`);
      }
    }

    return errors;
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get title(): LocalizedText {
    return this.props.title;
  }

  get description(): LocalizedText {
    return this.props.description;
  }

  get deadline(): Date | null {
    return this.props.deadline;
  }

  get fields(): FormField[] {
    return this.props.fields;
  }
}
