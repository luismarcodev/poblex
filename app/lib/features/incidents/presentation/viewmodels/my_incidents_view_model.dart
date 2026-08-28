import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/incident_usecases.dart';

final myIncidentsViewModelProvider =
    AsyncNotifierProvider<MyIncidentsViewModel, MyIncidentsUiState>(
      MyIncidentsViewModel.new,
    );

class MyIncidentsUiState extends Equatable {
  const MyIncidentsUiState({
    this.items = const <Incident>[],
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.nextCursor,
  });

  final List<Incident> items;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  MyIncidentsUiState copyWith({
    List<Incident>? items,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => MyIncidentsUiState(
    items: items ?? this.items,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    refreshing,
    loadingMore,
    failure,
    nextCursor,
  ];
}

class MyIncidentsViewModel extends AsyncNotifier<MyIncidentsUiState> {
  late final GetMyIncidents _getMyIncidents = getIt<GetMyIncidents>();
  int _requestVersion = 0;

  @override
  Future<MyIncidentsUiState> build() async {
    final bool hasDevice = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.hasMunicipality,
      ),
    );
    if (!hasDevice) {
      return const MyIncidentsUiState(failure: ValidationFailure());
    }
    return _load(base: const MyIncidentsUiState());
  }

  Future<MyIncidentsUiState> _load({required MyIncidentsUiState base}) async {
    final Result<IncidentPage> result = await _getMyIncidents();
    return switch (result) {
      Success<IncidentPage>(:final value) => base.copyWith(
        items: value.items,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<IncidentPage>(:final failure) => base.copyWith(
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final MyIncidentsUiState current =
        state.value ?? const MyIncidentsUiState();
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<MyIncidentsUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<MyIncidentsUiState>();
    final MyIncidentsUiState loaded = await _load(base: current);
    if (requestVersion == _requestVersion) {
      state = AsyncData<MyIncidentsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final MyIncidentsUiState current =
        state.value ?? const MyIncidentsUiState();
    if (!current.canLoadMore) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<MyIncidentsUiState>(current.copyWith(loadingMore: true));
    final Result<IncidentPage> result = await _getMyIncidents(
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<MyIncidentsUiState>(switch (result) {
      Success<IncidentPage>(:final value) => current.copyWith(
        items: <Incident>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<IncidentPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }
}
