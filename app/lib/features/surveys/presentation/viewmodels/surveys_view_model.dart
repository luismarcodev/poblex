import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/usecases/survey_usecases.dart';

final surveysViewModelProvider =
    AsyncNotifierProvider<SurveysViewModel, SurveysUiState>(
      SurveysViewModel.new,
    );

class SurveysUiState extends Equatable {
  const SurveysUiState({
    this.items = const <Survey>[],
    this.includeClosed = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.nextCursor,
  });

  final List<Survey> items;
  final bool includeClosed;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  SurveysUiState copyWith({
    List<Survey>? items,
    bool? includeClosed,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => SurveysUiState(
    items: items ?? this.items,
    includeClosed: includeClosed ?? this.includeClosed,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    includeClosed,
    refreshing,
    loadingMore,
    failure,
    nextCursor,
  ];
}

class SurveysViewModel extends AsyncNotifier<SurveysUiState> {
  late final GetSurveys _getSurveys = getIt<GetSurveys>();
  int _requestVersion = 0;

  @override
  Future<SurveysUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const SurveysUiState(failure: ValidationFailure());
    }
    return _load(municipalityId: municipalityId, base: const SurveysUiState());
  }

  Future<SurveysUiState> _load({
    required String municipalityId,
    required SurveysUiState base,
  }) async {
    final Result<SurveyPage> result = await _getSurveys(
      municipalityId: municipalityId,
      includeClosed: base.includeClosed,
    );
    return switch (result) {
      Success<SurveyPage>(:final value) => base.copyWith(
        items: value.items,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<SurveyPage>(:final failure) => base.copyWith(
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final SurveysUiState current = state.value ?? const SurveysUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<SurveysUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<SurveysUiState>();
    final SurveysUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<SurveysUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final SurveysUiState current = state.value ?? const SurveysUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<SurveysUiState>(current.copyWith(loadingMore: true));
    final Result<SurveyPage> result = await _getSurveys(
      municipalityId: municipalityId,
      includeClosed: current.includeClosed,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<SurveysUiState>(switch (result) {
      Success<SurveyPage>(:final value) => current.copyWith(
        items: <Survey>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<SurveyPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }

  Future<void> setIncludeClosed(bool includeClosed) async {
    final SurveysUiState current = state.value ?? const SurveysUiState();
    if (current.includeClosed == includeClosed) return;
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    final SurveysUiState base = current.copyWith(includeClosed: includeClosed);
    state = const AsyncLoading<SurveysUiState>();
    final SurveysUiState loaded = await _load(
      municipalityId: municipalityId,
      base: base,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<SurveysUiState>(loaded);
    }
  }
}
