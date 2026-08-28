import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/surveys/domain/entities/survey.dart';
import 'package:poblex/features/surveys/domain/repositories/survey_repository.dart';
import 'package:poblex/features/surveys/domain/usecases/survey_usecases.dart';
import 'package:poblex/features/surveys/presentation/viewmodels/survey_detail_view_model.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';

class _ControlledSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => const SessionState(
    deviceId: 'device-1',
    municipalityId: 'municipality-1',
    municipalityName: 'Sollana',
    municipalitySlug: 'sollana',
    deviceLocale: AppLocale.es,
  );
}

const List<SurveyOption> _openOptions = <SurveyOption>[
  SurveyOption(
    id: 'option-a',
    label: LocalizedText(es: 'Paella', va: 'Paella'),
    position: 0,
    votes: null,
  ),
  SurveyOption(
    id: 'option-b',
    label: LocalizedText(es: 'Fideuà', va: 'Fideuà'),
    position: 1,
    votes: null,
  ),
];

class _MutableSurveyRepository implements SurveyRepository {
  bool _voted = false;
  int voteCalls = 0;

  @override
  Future<Result<SurveyPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async => const Success<SurveyPage>(
    SurveyPage(items: <Survey>[], nextCursor: null),
  );

  @override
  Future<Result<Survey>> detail({
    required String id,
    required String municipalityId,
  }) async {
    if (!_voted) {
      return Success<Survey>(
        Survey(
          id: id,
          municipalityId: municipalityId,
          question: const LocalizedText(
            es: '¿Paella o fideuà?',
            va: 'Paella o fideuà?',
          ),
          closesAt: DateTime.utc(2026, 12, 31),
          isOpen: true,
          binding: false,
          options: _openOptions,
          votedOptionId: null,
        ),
      );
    }
    return Success<Survey>(
      Survey(
        id: id,
        municipalityId: municipalityId,
        question: const LocalizedText(
          es: '¿Paella o fideuà?',
          va: 'Paella o fideuà?',
        ),
        closesAt: DateTime.utc(2026, 12, 31),
        isOpen: true,
        binding: false,
        options: const <SurveyOption>[
          SurveyOption(
            id: 'option-a',
            label: LocalizedText(es: 'Paella', va: 'Paella'),
            position: 0,
            votes: 5,
          ),
          SurveyOption(
            id: 'option-b',
            label: LocalizedText(es: 'Fideuà', va: 'Fideuà'),
            position: 1,
            votes: 2,
          ),
        ],
        votedOptionId: 'option-a',
      ),
    );
  }

  @override
  Future<Result<void>> vote({
    required String surveyId,
    required String optionId,
  }) async {
    voteCalls++;
    _voted = true;
    return const Success<void>(null);
  }
}

void main() {
  late _MutableSurveyRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _MutableSurveyRepository();
    getIt
      ..registerSingleton<GetSurveyDetail>(GetSurveyDetail(repository))
      ..registerSingleton<VoteSurvey>(VoteSurvey(repository));
    container = ProviderContainer(
      overrides: <Override>[
        sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
      ],
    );
    // autoDispose.family: keep it alive across the awaits below, or the
    // provider tears down and a fresh instance replaces the voted state.
    container.listen(surveyDetailViewModelProvider('survey-1'), (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'voting reloads the detail instead of guessing the new tallies',
    () async {
      final SurveyDetailUiState before = await container.read(
        surveyDetailViewModelProvider('survey-1').future,
      );
      expect(before.survey!.hasVoted, isFalse);
      expect(
        before.survey!.options.every((SurveyOption o) => o.votes == null),
        isTrue,
      );

      await container
          .read(surveyDetailViewModelProvider('survey-1').notifier)
          .vote('option-a');

      final SurveyDetailUiState after = container
          .read(surveyDetailViewModelProvider('survey-1'))
          .requireValue;
      expect(repository.voteCalls, 1);
      expect(after.survey!.votedOptionId, 'option-a');
      expect(after.survey!.resultsVisible, isTrue);
      expect(after.survey!.totalVotes, 7);
    },
  );
}
