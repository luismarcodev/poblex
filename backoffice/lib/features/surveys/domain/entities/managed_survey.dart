import 'package:equatable/equatable.dart';

class SurveyLocalizedText extends Equatable {
  const SurveyLocalizedText({required this.es, this.va});

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

class ManagedSurveyOption extends Equatable {
  const ManagedSurveyOption({
    required this.id,
    required this.label,
    required this.position,
    this.votes,
  });

  final String id;
  final SurveyLocalizedText label;
  final int position;
  final int? votes;

  ManagedSurveyOption copyWith({int? votes, bool clearVotes = false}) =>
      ManagedSurveyOption(
        id: id,
        label: label,
        position: position,
        votes: clearVotes ? null : votes ?? this.votes,
      );

  @override
  List<Object?> get props => [id, label, position, votes];
}

class ManagedSurvey extends Equatable {
  const ManagedSurvey({
    required this.id,
    required this.municipalityId,
    required this.question,
    required this.closesAt,
    required this.isOpen,
    required this.binding,
    required this.options,
  });

  final String id;
  final String municipalityId;
  final SurveyLocalizedText question;
  final DateTime closesAt;
  final bool isOpen;
  final bool binding;
  final List<ManagedSurveyOption> options;

  bool get resultsAvailable => options.every((option) => option.votes != null);
  int get totalVotes =>
      options.fold(0, (total, option) => total + (option.votes ?? 0));

  ManagedSurvey copyWith({
    DateTime? closesAt,
    bool? isOpen,
    List<ManagedSurveyOption>? options,
  }) => ManagedSurvey(
    id: id,
    municipalityId: municipalityId,
    question: question,
    closesAt: closesAt ?? this.closesAt,
    isOpen: isOpen ?? this.isOpen,
    binding: binding,
    options: options ?? this.options,
  );

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    question,
    closesAt,
    isOpen,
    binding,
    options,
  ];
}

class ManagedSurveysPage extends Equatable {
  const ManagedSurveysPage({required this.items, required this.nextCursor});

  final List<ManagedSurvey> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

class CreateSurveyInput extends Equatable {
  const CreateSurveyInput({
    required this.municipalityId,
    required this.question,
    required this.closesAt,
    required this.resultsVisible,
    required this.options,
  });

  final String municipalityId;
  final SurveyLocalizedText question;
  final DateTime closesAt;
  final bool resultsVisible;
  final List<SurveyLocalizedText> options;

  @override
  List<Object?> get props => [
    municipalityId,
    question,
    closesAt,
    resultsVisible,
    options,
  ];
}
