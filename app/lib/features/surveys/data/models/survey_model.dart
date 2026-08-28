import '../../../../shared/data/models/localized_text_model.dart';

class SurveyOptionModel {
  const SurveyOptionModel({
    required this.id,
    required this.label,
    required this.position,
    required this.votes,
  });

  final String id;
  final LocalizedTextModel label;
  final int position;
  final int? votes;

  factory SurveyOptionModel.fromJson(Map<String, dynamic> json) =>
      SurveyOptionModel(
        id: json['id'] as String,
        label: LocalizedTextModel.fromJson(
          Map<String, dynamic>.from(json['label'] as Map),
        ),
        position: json['position'] as int,
        votes: json['votes'] as int?,
      );
}

class SurveyModel {
  const SurveyModel({
    required this.id,
    required this.municipalityId,
    required this.question,
    required this.closesAt,
    required this.isOpen,
    required this.binding,
    required this.options,
    required this.votedOptionId,
  });

  final String id;
  final String municipalityId;
  final LocalizedTextModel question;
  final DateTime closesAt;
  final bool isOpen;
  final bool binding;
  final List<SurveyOptionModel> options;
  final String? votedOptionId;

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];
    return SurveyModel(
      id: json['id'] as String,
      municipalityId: json['municipalityId'] as String,
      question: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['question'] as Map),
      ),
      closesAt: DateTime.parse(json['closesAt'] as String),
      isOpen: json['isOpen'] as bool,
      binding: json['binding'] as bool,
      options: rawOptions is List<dynamic>
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(SurveyOptionModel.fromJson)
                .toList(growable: false)
          : const <SurveyOptionModel>[],
      votedOptionId: json['votedOptionId'] as String?,
    );
  }
}

class SurveyPageModel {
  const SurveyPageModel({required this.items, this.nextCursor});

  final List<SurveyModel> items;
  final String? nextCursor;

  factory SurveyPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return SurveyPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(SurveyModel.fromJson)
                .toList(growable: false)
          : const <SurveyModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
