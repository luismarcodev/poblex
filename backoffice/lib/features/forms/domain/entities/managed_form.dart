import 'package:equatable/equatable.dart';

class FormLocalizedText extends Equatable {
  const FormLocalizedText({required this.es, this.va});

  final String es;
  final String? va;

  Map<String, dynamic> toJson() => {
    'es': es.trim(),
    if (va != null && va!.trim().isNotEmpty) 'va': va!.trim(),
  };

  String resolve(bool prefersValencian) {
    final valencian = va?.trim();
    if (prefersValencian && valencian != null && valencian.isNotEmpty) {
      return valencian;
    }
    if (es.trim().isNotEmpty) return es.trim();
    return valencian ?? '';
  }

  @override
  List<Object?> get props => [es, va];
}

enum ManagedFormFieldType {
  text('text'),
  number('number'),
  select('select'),
  date('date'),
  boolean('boolean');

  const ManagedFormFieldType(this.apiValue);
  final String apiValue;

  static ManagedFormFieldType fromApi(String value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => throw FormatException('Unknown form field type: $value'),
  );
}

class ManagedFormField extends Equatable {
  const ManagedFormField({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
    required this.position,
  });

  final String id;
  final String key;
  final FormLocalizedText label;
  final ManagedFormFieldType type;
  final bool required;
  final List<String> options;
  final int position;

  @override
  List<Object?> get props => [
    id,
    key,
    label,
    type,
    required,
    options,
    position,
  ];
}

class ManagedForm extends Equatable {
  const ManagedForm({
    required this.id,
    required this.municipalityId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isOpen,
    required this.fields,
  });

  final String id;
  final String municipalityId;
  final FormLocalizedText title;
  final FormLocalizedText description;
  final DateTime? deadline;
  final bool isOpen;
  final List<ManagedFormField> fields;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    title,
    description,
    deadline,
    isOpen,
    fields,
  ];
}

class ManagedFormsPage extends Equatable {
  const ManagedFormsPage({required this.items, required this.nextCursor});

  final List<ManagedForm> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

class FormFieldDraft extends Equatable {
  const FormFieldDraft({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.options = const [],
  });

  final String key;
  final FormLocalizedText label;
  final ManagedFormFieldType type;
  final bool required;
  final List<String> options;

  Map<String, dynamic> toJson() => {
    'key': key.trim(),
    'label': label.toJson(),
    'type': type.apiValue,
    'required': required,
    if (type == ManagedFormFieldType.select)
      'options': options.map((option) => option.trim()).toList(),
  };

  @override
  List<Object?> get props => [key, label, type, required, options];
}

class CreateFormInput extends Equatable {
  const CreateFormInput({
    required this.municipalityId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.fields,
  });

  final String municipalityId;
  final FormLocalizedText title;
  final FormLocalizedText description;
  final DateTime? deadline;
  final List<FormFieldDraft> fields;

  @override
  List<Object?> get props => [
    municipalityId,
    title,
    description,
    deadline,
    fields,
  ];
}
