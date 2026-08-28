import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/survey.dart';
import '../models/survey_model.dart';

abstract final class SurveyMapper {
  static SurveyOption optionToDomain(SurveyOptionModel model) => SurveyOption(
    id: model.id,
    label: LocalizedText(es: model.label.es, va: model.label.va),
    position: model.position,
    votes: model.votes,
  );

  static Survey toDomain(SurveyModel model) => Survey(
    id: model.id,
    municipalityId: model.municipalityId,
    question: LocalizedText(es: model.question.es, va: model.question.va),
    closesAt: model.closesAt,
    isOpen: model.isOpen,
    binding: model.binding,
    options: model.options.map(optionToDomain).toList(growable: false),
    votedOptionId: model.votedOptionId,
  );
}
