import '../../../../shared/data/models/localized_text_model.dart';

class FormFieldModel {
  const FormFieldModel({
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
  final LocalizedTextModel label;
  final String type;
  final bool required;
  final List<String> options;
  final int position;

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];
    return FormFieldModel(
      id: json['id'] as String,
      key: json['key'] as String,
      label: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['label'] as Map),
      ),
      type: json['type'] as String,
      required: json['required'] as bool,
      options: rawOptions is List<dynamic>
          ? rawOptions.whereType<String>().toList(growable: false)
          : const <String>[],
      position: json['position'] as int,
    );
  }
}

class FormModel {
  const FormModel({
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
  final LocalizedTextModel title;
  final LocalizedTextModel description;
  final DateTime? deadline;
  final bool isOpen;
  final bool alreadySubmitted;
  final List<FormFieldModel> fields;

  factory FormModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawFields = json['fields'];
    return FormModel(
      id: json['id'] as String,
      municipalityId: json['municipalityId'] as String,
      title: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['title'] as Map),
      ),
      description: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['description'] as Map),
      ),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      isOpen: json['isOpen'] as bool,
      alreadySubmitted: json['alreadySubmitted'] as bool,
      fields: rawFields is List<dynamic>
          ? rawFields
                .whereType<Map<String, dynamic>>()
                .map(FormFieldModel.fromJson)
                .toList(growable: false)
          : const <FormFieldModel>[],
    );
  }
}

class FormPageModel {
  const FormPageModel({required this.items, this.nextCursor});

  final List<FormModel> items;
  final String? nextCursor;

  factory FormPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return FormPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(FormModel.fromJson)
                .toList(growable: false)
          : const <FormModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
