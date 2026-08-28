import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_survey.dart';
import '../../domain/usecases/survey_usecases.dart';

class SurveysUiState extends Equatable {
  const SurveysUiState({
    required this.municipalityId,
    required this.items,
    required this.includeClosed,
    required this.nextCursor,
    this.busyIds = const {},
    this.loadingDetailIds = const {},
    this.details = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedSurvey> items;
  final bool includeClosed;
  final String? nextCursor;
  final Set<String> busyIds;
  final Set<String> loadingDetailIds;
  final Map<String, ManagedSurvey> details;
  final bool isLoadingMore;

  SurveysUiState copyWith({
    String? municipalityId,
    List<ManagedSurvey>? items,
    bool? includeClosed,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    Set<String>? loadingDetailIds,
    Map<String, ManagedSurvey>? details,
    bool? isLoadingMore,
  }) => SurveysUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
    includeClosed: includeClosed ?? this.includeClosed,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    loadingDetailIds: loadingDetailIds ?? this.loadingDetailIds,
    details: details ?? this.details,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includeClosed,
    nextCursor,
    busyIds,
    loadingDetailIds,
    details,
    isLoadingMore,
  ];
}

final surveysViewModelProvider =
    AsyncNotifierProvider<SurveysViewModel, SurveysUiState>(
      SurveysViewModel.new,
    );

class SurveysViewModel extends AsyncNotifier<SurveysUiState> {
  bool _includeClosed = false;
  int _revision = 0;

  @override
  Future<SurveysUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedSurveys>()(
      municipalityId: municipalityId,
      includeClosed: _includeClosed,
    );
    return switch (result) {
      Success(value: final page) => SurveysUiState(
        municipalityId: municipalityId,
        items: page.items,
        includeClosed: _includeClosed,
        nextCursor: page.nextCursor,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setIncludeClosed(bool value) async {
    if (_includeClosed == value) return;
    _includeClosed = value;
    ref.invalidateSelf();
    await future;
  }

  Future<AppFailure?> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return null;
    }
    final requestedCursor = current.nextCursor!;
    final requestedRevision = _revision;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<GetManagedSurveys>()(
      municipalityId: current.municipalityId,
      includeClosed: current.includeClosed,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.municipalityId != current.municipalityId ||
        latest.includeClosed != current.includeClosed ||
        latest.nextCursor != requestedCursor) {
      return null;
    }
    if (result case Success(value: final page)) {
      final existingIds = latest.items.map((survey) => survey.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((survey) => existingIds.add(survey.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedSurveysPage>).error;
  }

  Future<AppFailure?> loadDetail(ManagedSurvey survey) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.loadingDetailIds.contains(survey.id)) return null;
    _setDetailLoading(survey.id, true);
    final result = await getIt<GetManagedSurveyDetail>()(
      id: survey.id,
      municipalityId: current.municipalityId,
    );
    final latest = state.valueOrNull;
    if (latest == null || latest.municipalityId != current.municipalityId) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setDetailLoading(survey.id, false);
      return error;
    }
    final detail = (result as Success<ManagedSurvey>).value;
    final loading = {...latest.loadingDetailIds}..remove(survey.id);
    state = AsyncData(
      latest.copyWith(
        loadingDetailIds: loading,
        details: {...latest.details, survey.id: detail},
      ),
    );
    return null;
  }

  Future<AppFailure?> close(ManagedSurvey survey) async {
    if (!_startMutation(survey.id)) return null;
    final result = await getIt<CloseSurvey>()(survey.id);
    if (result case Failure(error: final error)) {
      _finishMutation(survey.id);
      return error;
    }
    final closed = (result as Success<ManagedSurvey>).value;
    _replaceAfterMutation(closed);
    await loadDetail(closed);
    return null;
  }

  Future<AppFailure?> setResultsVisibility(
    ManagedSurvey survey,
    bool visible,
  ) async {
    if (!_startMutation(survey.id)) return null;
    final result = await getIt<SetSurveyResultsVisibility>()(
      survey.id,
      visible,
    );
    if (result case Failure(error: final error)) {
      _finishMutation(survey.id);
      return error;
    }
    final latest = state.valueOrNull;
    if (latest == null) return null;
    final existingDetail = latest.details[survey.id] ?? survey;
    final options = visible
        ? existingDetail.options
        : existingDetail.options
              .map((option) => option.copyWith(clearVotes: true))
              .toList(growable: false);
    final updated = existingDetail.copyWith(options: options);
    state = AsyncData(
      latest.copyWith(
        busyIds: {...latest.busyIds}..remove(survey.id),
        details: {...latest.details, survey.id: updated},
      ),
    );
    if (visible) return loadDetail(updated);
    return null;
  }

  Future<AppFailure?> delete(ManagedSurvey survey) async {
    if (!_startMutation(survey.id)) return null;
    final result = await getIt<DeleteSurvey>()(survey.id);
    if (result case Failure(error: final error)) {
      _finishMutation(survey.id);
      return error;
    }
    final latest = state.valueOrNull;
    if (latest == null) return null;
    final details = {...latest.details}..remove(survey.id);
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((item) => item.id != survey.id).toList(),
        busyIds: {...latest.busyIds}..remove(survey.id),
        details: details,
      ),
    );
    return null;
  }

  Future<Result<String>> exportResultsCsv(ManagedSurvey survey) =>
      getIt<ExportSurveyResultsCsv>()(survey.id);

  bool _startMutation(String id) {
    final current = state.valueOrNull;
    if (current == null || current.busyIds.contains(id)) return false;
    state = AsyncData(current.copyWith(busyIds: {...current.busyIds, id}));
    return true;
  }

  void _finishMutation(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(busyIds: {...current.busyIds}..remove(id)),
    );
  }

  void _setDetailLoading(String id, bool loading) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.loadingDetailIds};
    loading ? ids.add(id) : ids.remove(id);
    state = AsyncData(current.copyWith(loadingDetailIds: ids));
  }

  void _replaceAfterMutation(ManagedSurvey updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    final items = !current.includeClosed && !updated.isOpen
        ? current.items.where((item) => item.id != updated.id).toList()
        : current.items
              .map((item) => item.id == updated.id ? updated : item)
              .toList(growable: false);
    state = AsyncData(
      current.copyWith(
        items: items,
        busyIds: {...current.busyIds}..remove(updated.id),
        details: {...current.details, updated.id: updated},
      ),
    );
  }
}
