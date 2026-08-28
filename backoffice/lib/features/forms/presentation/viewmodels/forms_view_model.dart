import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_form.dart';
import '../../domain/usecases/form_usecases.dart';

class FormsUiState extends Equatable {
  const FormsUiState({
    required this.municipalityId,
    required this.items,
    required this.includeClosed,
    required this.nextCursor,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedForm> items;
  final bool includeClosed;
  final String? nextCursor;
  final Set<String> busyIds;
  final bool isLoadingMore;

  FormsUiState copyWith({
    List<ManagedForm>? items,
    bool? includeClosed,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => FormsUiState(
    municipalityId: municipalityId,
    items: items ?? this.items,
    includeClosed: includeClosed ?? this.includeClosed,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includeClosed,
    nextCursor,
    busyIds,
    isLoadingMore,
  ];
}

final formsViewModelProvider =
    AsyncNotifierProvider<FormsViewModel, FormsUiState>(FormsViewModel.new);

class FormsViewModel extends AsyncNotifier<FormsUiState> {
  bool _includeClosed = false;
  int _revision = 0;

  @override
  Future<FormsUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedForms>()(
      municipalityId: municipalityId,
      includeClosed: _includeClosed,
    );
    return switch (result) {
      Success(value: final page) => FormsUiState(
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
    final result = await getIt<GetManagedForms>()(
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
      final ids = latest.items.map((item) => item.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((item) => ids.add(item.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedFormsPage>).error;
  }

  Future<AppFailure?> delete(ManagedForm form) async {
    final current = state.valueOrNull;
    if (current == null || current.busyIds.contains(form.id)) return null;
    state = AsyncData(current.copyWith(busyIds: {...current.busyIds, form.id}));
    final result = await getIt<DeleteManagedForm>()(form.id);
    final latest = state.valueOrNull;
    if (latest == null || latest.municipalityId != current.municipalityId) {
      return null;
    }
    if (result case Failure(error: final error)) {
      state = AsyncData(
        latest.copyWith(busyIds: {...latest.busyIds}..remove(form.id)),
      );
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((item) => item.id != form.id).toList(),
        busyIds: {...latest.busyIds}..remove(form.id),
      ),
    );
    return null;
  }

  Future<Result<String>> exportSubmissionsCsv(ManagedForm form) =>
      getIt<ExportFormSubmissionsCsv>()(form.id);
}
