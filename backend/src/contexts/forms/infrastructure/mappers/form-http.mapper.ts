import { Form } from '../../domain/entities/form.entity';
import { FormResponseDto } from '../http/dto/form.dto';

export class FormHttpMapper {
  static toResponseDto(form: Form, alreadySubmitted: boolean): FormResponseDto {
    return {
      id: form.id,
      municipalityId: form.municipalityId.value,
      title: form.title.toJSON(),
      description: form.description.toJSON(),
      deadline: form.deadline?.toISOString() ?? null,
      isOpen: form.isOpenAt(new Date()),
      alreadySubmitted,
      fields: form.fields.map((field) => ({
        id: field.id,
        key: field.key,
        label: field.label.toJSON(),
        type: field.type.value,
        required: field.required,
        options: field.options,
        position: field.position,
      })),
    };
  }
}
