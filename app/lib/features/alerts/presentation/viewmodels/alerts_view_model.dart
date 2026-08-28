import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/alert.dart';
import '../../domain/usecases/alert_usecases.dart';

final alertsViewModelProvider =
    AsyncNotifierProvider<AlertsViewModel, AlertsUiState>(AlertsViewModel.new);

class AlertsUiState extends Equatable {
  const AlertsUiState({
    this.items = const <MunicipalAlert>[],
    this.includeExpired = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.nextCursor,
  });

  final List<MunicipalAlert> items;
  final bool includeExpired;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  AlertsUiState copyWith({
    List<MunicipalAlert>? items,
    bool? includeExpired,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => AlertsUiState(
    items: items ?? this.items,
    includeExpired: includeExpired ?? this.includeExpired,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    includeExpired,
    refreshing,
    loadingMore,
    failure,
    nextCursor,
  ];
}

class AlertsViewModel extends AsyncNotifier<AlertsUiState> {
  late final GetAlerts _getAlerts = getIt<GetAlerts>();
  int _requestVersion = 0;

  @override
  Future<AlertsUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const AlertsUiState(failure: ValidationFailure());
    }
    return _load(municipalityId: municipalityId, base: const AlertsUiState());
  }

  Future<AlertsUiState> _load({
    required String municipalityId,
    required AlertsUiState base,
  }) async {
    final Result<AlertPage> result = await _getAlerts(
      municipalityId: municipalityId,
      includeExpired: base.includeExpired,
    );
    return switch (result) {
      Success<AlertPage>(:final value) => base.copyWith(
        items: value.items,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<AlertPage>(:final failure) => base.copyWith(
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final AlertsUiState current = state.value ?? const AlertsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<AlertsUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<AlertsUiState>();
    final AlertsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<AlertsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final AlertsUiState current = state.value ?? const AlertsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<AlertsUiState>(current.copyWith(loadingMore: true));
    final Result<AlertPage> result = await _getAlerts(
      municipalityId: municipalityId,
      includeExpired: current.includeExpired,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<AlertsUiState>(switch (result) {
      Success<AlertPage>(:final value) => current.copyWith(
        items: <MunicipalAlert>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<AlertPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }

  Future<void> setIncludeExpired(bool includeExpired) async {
    final AlertsUiState current = state.value ?? const AlertsUiState();
    if (current.includeExpired == includeExpired) return;
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    final AlertsUiState base = current.copyWith(includeExpired: includeExpired);
    state = const AsyncLoading<AlertsUiState>();
    final AlertsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: base,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<AlertsUiState>(loaded);
    }
  }
}
