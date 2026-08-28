import type {
  Form as PrismaForm,
  FormField as PrismaFormField,
  FormFieldType as PrismaFormFieldType,
} from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Form, FormField } from '../../../domain/entities/form.entity';
import { FormFieldType } from '../../../domain/value-objects/form-field-type.vo';

export type PrismaFormWithFields = PrismaForm & { fields: PrismaFormField[] };

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class FormMapper {
  static toDomain(row: PrismaFormWithFields): Form {
    return Form.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      title: LocalizedText.create(row.title as RawLocalizedJson),
      description: LocalizedText.create(row.description as RawLocalizedJson),
      deadline: row.deadline,
      fields: [...row.fields]
        .sort((left, right) => left.position - right.position)
        .map((field) =>
          FormField.create({
            id: field.id,
            key: field.key,
            label: LocalizedText.create(field.label as RawLocalizedJson),
            type: FormFieldType.create(field.type.toLowerCase()),
            required: field.required,
            // `options` es jsonb libre: solo se aceptan arrays de cadenas.
            options: Array.isArray(field.options)
              ? (field.options as unknown[]).map((option) => String(option))
              : [],
            position: field.position,
          }),
        ),
    });
  }

  static toPrismaFieldType(type: FormFieldType): PrismaFormFieldType {
    return type.value.toUpperCase() as PrismaFormFieldType;
  }
}
