import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/surveys/domain/entities/managed_survey.dart';
import 'package:poblex_backoffice/features/surveys/domain/repositories/survey_repository.dart';
import 'package:poblex_backoffice/features/surveys/domain/usecases/survey_usecases.dart';
import 'package:poblex_backoffice/features/surveys/presentation/viewmodels/surveys_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeSurveyRepository implements SurveyRepository {
  final loadMoreResult = Completer<Result<ManagedSurveysPage>>();
  final deleteResults = <String, Completer<Result<void>>>{};
  int loadMoreCalls = 0;

  @override
  Future<Result<ManagedSurveysPage>> getSurveys({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    if (cursor == null) {
      return Success(
        ManagedSurveysPage(
          items: [_survey('one'), _survey('two')],
          nextCursor: 'next',
        ),
      );
    }
    loadMoreCalls++;
    return loadMoreResult.future;
  }

  @override
  Future<Result<void>> delete(String id) =>
      deleteResults.putIfAbsent(id, Completer<Result<void>>.new).future;

  @override
  Future<Result<ManagedSurvey>> getDetail({
    required String id,
    required String municipalityId,
  }) async => Success(
    _survey(id).copyWith(
      options: _survey(id).options
          .map((option) => option.copyWith(votes: option.position + 2))
          .toList(),
    ),
  );

  @override
  Future<Result<ManagedSurvey>> setResultsVisibility(
    String id,
    bool visible,
  ) async => Success(_survey(id));

  @override
  Future<Result<ManagedSurvey>> close(String id) => throw UnimplementedError();
  @override
  Future<Result<ManagedSurvey>> create(CreateSurveyInput input) =>
      throw UnimplementedError();
  @override
  Future<Result<String>> exportResultsCsv(String id) =>
      throw UnimplementedError();
}

void main() {
  late FakeSurveyRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeSurveyRepository();
    getIt.registerFactory(() => GetManagedSurveys(repository));
    getIt.registerFactory(() => GetManagedSurveyDetail(repository));
    getIt.registerFactory(() => DeleteSurvey(repository));
    getIt.registerFactory(() => SetSurveyResultsVisibility(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(surveysViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'prevents duplicate pagination and preserves items on failure',
    () async {
      final viewModel = container.read(surveysViewModelProvider.notifier);
      final first = viewModel.loadMore();
      final duplicate = viewModel.loadMore();

      expect(repository.loadMoreCalls, 1);
      repository.loadMoreResult.complete(
        const Failure(NetworkFailure(message: 'offline')),
      );

      expect(await first, isA<NetworkFailure>());
      expect(await duplicate, isNull);
      final state = container.read(surveysViewModelProvider).value!;
      expect(state.items.map((survey) => survey.id), ['one', 'two']);
      expect(state.isLoadingMore, isFalse);
    },
  );

  test('discards a stale pagination response after a refresh', () async {
    final viewModel = container.read(surveysViewModelProvider.notifier);
    final pagination = viewModel.loadMore();

    await viewModel.refresh();
    repository.loadMoreResult.complete(
      Success(ManagedSurveysPage(items: [_survey('stale')], nextCursor: null)),
    );

    expect(await pagination, isNull);
    expect(
      container
          .read(surveysViewModelProvider)
          .value!
          .items
          .map((item) => item.id),
      ['one', 'two'],
    );
  });

  test('keeps concurrent deletes independent', () async {
    final viewModel = container.read(surveysViewModelProvider.notifier);
    final items = container.read(surveysViewModelProvider).value!.items;
    final first = viewModel.delete(items[0]);
    final second = viewModel.delete(items[1]);

    repository.deleteResults['two']!.complete(const Success(null));
    await second;
    expect(
      container
          .read(surveysViewModelProvider)
          .value!
          .items
          .map((survey) => survey.id),
      ['one'],
    );

    repository.deleteResults['one']!.complete(
      const Failure(NetworkFailure(message: 'offline')),
    );
    expect(await first, isA<NetworkFailure>());
    final state = container.read(surveysViewModelProvider).value!;
    expect(state.items.map((survey) => survey.id), ['one']);
    expect(state.busyIds, isEmpty);
  });

  test('loads visible tallies only into the requested survey detail', () async {
    final viewModel = container.read(surveysViewModelProvider.notifier);
    final survey = container.read(surveysViewModelProvider).value!.items.first;

    expect(await viewModel.loadDetail(survey), isNull);

    final state = container.read(surveysViewModelProvider).value!;
    expect(state.details[survey.id]!.resultsAvailable, isTrue);
    expect(state.details[survey.id]!.totalVotes, 5);
    expect(state.details.containsKey('two'), isFalse);
  });
}

ManagedSurvey _survey(String id) => ManagedSurvey(
  id: id,
  municipalityId: municipality.id,
  question: SurveyLocalizedText(es: 'Pregunta $id', va: 'Pregunta va $id'),
  closesAt: DateTime.utc(2026, 9, 1),
  isOpen: true,
  binding: false,
  options: const [
    ManagedSurveyOption(
      id: 'one',
      label: SurveyLocalizedText(es: 'Una', va: 'Una va'),
      position: 0,
    ),
    ManagedSurveyOption(
      id: 'two',
      label: SurveyLocalizedText(es: 'Dos', va: 'Dos va'),
      position: 1,
    ),
  ],
);
