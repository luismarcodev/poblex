import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/municipality.dart';
import '../../domain/usecases/list_municipalities.dart';

final municipalitiesViewModelProvider =
    AsyncNotifierProvider<MunicipalitiesViewModel, MunicipalitiesUiState>(
      MunicipalitiesViewModel.new,
    );

class MunicipalitiesUiState extends Equatable {
  const MunicipalitiesUiState({
    this.items = const <Municipality>[],
    this.failure,
    this.selectingId,
  });

  final List<Municipality> items;
  final AppFailure? failure;
  final String? selectingId;

  MunicipalitiesUiState copyWith({
    List<Municipality>? items,
    AppFailure? failure,
    bool clearFailure = false,
    String? selectingId,
    bool clearSelecting = false,
  }) => MunicipalitiesUiState(
    items: items ?? this.items,
    failure: clearFailure ? null : failure ?? this.failure,
    selectingId: clearSelecting ? null : selectingId ?? this.selectingId,
  );

  @override
  List<Object?> get props => <Object?>[items, failure, selectingId];
}

class MunicipalitiesViewModel extends AsyncNotifier<MunicipalitiesUiState> {
  late final ListMunicipalities _list = getIt<ListMunicipalities>();

  @override
  Future<MunicipalitiesUiState> build() => _load();

  Future<MunicipalitiesUiState> _load() async {
    final Result<List<Municipality>> result = await _list();
    return switch (result) {
      Success<List<Municipality>>(:final value) => MunicipalitiesUiState(
        items: value,
      ),
      Failed<List<Municipality>>(:final failure) => MunicipalitiesUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<MunicipalitiesUiState>();
    state = AsyncData<MunicipalitiesUiState>(await _load());
  }

  Future<bool> select(Municipality municipality) async {
    final MunicipalitiesUiState current =
        state.value ?? const MunicipalitiesUiState();
    state = AsyncData<MunicipalitiesUiState>(
      current.copyWith(selectingId: municipality.id, clearFailure: true),
    );
    final Result<void> result = await ref
        .read(sessionViewModelProvider.notifier)
        .selectMunicipality(municipality);
    return switch (result) {
      Success<void>() => true,
      Failed<void>(:final failure) => _selectionFailed(current, failure),
    };
  }

  bool _selectionFailed(MunicipalitiesUiState current, AppFailure failure) {
    state = AsyncData<MunicipalitiesUiState>(
      current.copyWith(failure: failure, clearSelecting: true),
    );
    return false;
  }
}
