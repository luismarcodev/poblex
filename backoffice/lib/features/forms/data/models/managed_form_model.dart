import '../../domain/entities/managed_form.dart';

class ManagedFormModel {
  const ManagedFormModel(this.entity);

  final ManagedForm entity;

  factory ManagedFormModel.fromJson(Map<String, dynamic> json) {
    FormLocalizedText localized(Object? raw) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid localized form text');
      }
      return FormLocalizedText(
        es: raw['es'] as String? ?? '',
        va: raw['va'] as String?,
      );
    }

    final rawFields = json['fields'];
    if (rawFields is! List<dynamic>) {
      throw const FormatException('Missing form fields');
    }
    final fields =
        rawFields
            .map((raw) {
              if (raw is! Map<String, dynamic>) {
                throw const FormatException('Invalid form field');
              }
              final rawOptions = raw['options'];
              if (rawOptions is! List<dynamic>) {
                throw const FormatException('Invalid form field options');
              }
              return ManagedFormField(
                id: raw['id'] as String,
                key: raw['key'] as String,
                label: localized(raw['label']),
                type: ManagedFormFieldType.fromApi(raw['type'] as String),
                required: raw['required'] as bool,
                options: rawOptions.cast<String>().toList(growable: false),
                position: raw['position'] as int,
              );
            })
            .toList(growable: false)
          ..sort((first, second) => first.position.compareTo(second.position));

    final rawDeadline = json['deadline'];
    return ManagedFormModel(
      ManagedForm(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        title: localized(json['title']),
        description: localized(json['description']),
        deadline: rawDeadline is String ? DateTime.parse(rawDeadline) : null,
        isOpen: json['isOpen'] as bool,
        fields: fields,
      ),
    );
  }
}
