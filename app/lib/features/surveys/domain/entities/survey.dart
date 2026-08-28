import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

class SurveyOption extends Equatable {
  const SurveyOption({
    required this.id,
    required this.label,
    required this.position,
    required this.votes,
  });

  final String id;
  final LocalizedText label;
  final int position;

  /// Null while results are not visible yet — never zero-as-unknown.
  final int? votes;

  @override
  List<Object?> get props => <Object?>[id, label, position, votes];
}

class Survey extends Equatable {
  const Survey({
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
  final LocalizedText question;
  final DateTime closesAt;
  final bool isOpen;

  /// Always false in practice — no empadronamiento verification — but the
  /// backend owns the flag, so the app reads it instead of hardcoding it.
  final bool binding;
  final List<SurveyOption> options;
  final String? votedOptionId;

  bool get hasVoted => votedOptionId != null;
  bool get resultsVisible => options.any((SurveyOption o) => o.votes != null);
  int get totalVotes =>
      options.fold(0, (int sum, SurveyOption o) => sum + (o.votes ?? 0));

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    question,
    closesAt,
    isOpen,
    binding,
    options,
    votedOptionId,
  ];
}

class SurveyPage extends Equatable {
  const SurveyPage({required this.items, required this.nextCursor});

  final List<Survey> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
