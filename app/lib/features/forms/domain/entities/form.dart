import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

enum FormFieldType {
  text(slug: 'text'),
  number(slug: 'number'),
  select(slug: 'select'),
  date(slug: 'date'),
  boolean(slug: 'boolean');

  const FormFieldType({required this.slug});

  final String slug;

  static FormFieldType fromSlug(String slug) => switch (slug) {
    'number' => FormFieldType.number,
    'select' => FormFieldType.select,
    'date' => FormFieldType.date,
    'boolean' => FormFieldType.boolean,
    _ => FormFieldType.text,
  };
}

class FormFieldDefinition extends Equatable {
  const FormFieldDefinition({
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
  final LocalizedText label;
  final FormFieldType type;
  final bool required;
  final List<String> options;
  final int position;

  @override
  List<Object?> get props => <Object?>[
    id,
    key,
    label,
    type,
    required,
    options,
    position,
  ];
}

class MunicipalForm extends Equatable {
  const MunicipalForm({
    required this.id,
    required this.municipalityId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isOpen,
    required this.alreadySubmitted,
    required this.fields,
  });

  final String id;
  final String municipalityId;
  final LocalizedText title;
  final LocalizedText description;
  final DateTime? deadline;
  final bool isOpen;
  final bool alreadySubmitted;
  final List<FormFieldDefinition> fields;

  bool get canSubmit => isOpen && !alreadySubmitted;

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    title,
    description,
    deadline,
    isOpen,
    alreadySubmitted,
    fields,
  ];
}

class FormPage extends Equatable {
  const FormPage({required this.items, required this.nextCursor});

  final List<MunicipalForm> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
