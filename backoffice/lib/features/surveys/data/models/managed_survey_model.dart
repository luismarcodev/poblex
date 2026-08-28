import '../../domain/entities/managed_survey.dart';

class ManagedSurveyModel {
  const ManagedSurveyModel(this.entity);

  final ManagedSurvey entity;

  factory ManagedSurveyModel.fromJson(Map<String, dynamic> json) {
    SurveyLocalizedText localized(Object? raw) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid localized survey text');
      }
      return SurveyLocalizedText(
        es: raw['es'] as String? ?? '',
        va: raw['va'] as String?,
      );
    }

    final rawOptions = json['options'];
    if (rawOptions is! List<dynamic>) {
      throw const FormatException('Missing survey options');
    }

    final options =
        rawOptions
            .map((raw) {
              if (raw is! Map<String, dynamic>) {
                throw const FormatException('Invalid survey option');
              }
              return ManagedSurveyOption(
                id: raw['id'] as String,
                label: localized(raw['label']),
                position: raw['position'] as int,
                votes: raw['votes'] as int?,
              );
            })
            .toList(growable: false)
          ..sort((first, second) => first.position.compareTo(second.position));

    return ManagedSurveyModel(
      ManagedSurvey(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        question: localized(json['question']),
        closesAt: DateTime.parse(json['closesAt'] as String),
        isOpen: json['isOpen'] as bool,
        binding: json['binding'] as bool? ?? false,
        options: options,
      ),
    );
  }
}
