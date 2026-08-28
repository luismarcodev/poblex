import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/form.dart';
import '../models/form_model.dart';

abstract final class FormMapper {
  static FormFieldDefinition fieldToDomain(FormFieldModel model) =>
      FormFieldDefinition(
        id: model.id,
        key: model.key,
        label: LocalizedText(es: model.label.es, va: model.label.va),
        type: FormFieldType.fromSlug(model.type),
        required: model.required,
        options: model.options,
        position: model.position,
      );

  static MunicipalForm toDomain(FormModel model) => MunicipalForm(
    id: model.id,
    municipalityId: model.municipalityId,
    title: LocalizedText(es: model.title.es, va: model.title.va),
    description: LocalizedText(
      es: model.description.es,
      va: model.description.va,
    ),
    deadline: model.deadline,
    isOpen: model.isOpen,
    alreadySubmitted: model.alreadySubmitted,
    fields: model.fields.map(fieldToDomain).toList(growable: false),
  );
}
