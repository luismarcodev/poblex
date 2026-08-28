import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_alert.dart';
import '../../domain/usecases/alert_usecases.dart';

class AlertsUiState extends Equatable {
  const AlertsUiState({
    required this.municipalityId,
    required this.items,
    required this.includeExpired,
    required this.nextCursor,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedAlert> items;
  final bool includeExpired;
  final String? nextCursor;
  final Set<String> busyIds;
  final bool isLoadingMore;

  AlertsUiState copyWith({
    String? municipalityId,
    List<ManagedAlert>? items,
    bool? includeExpired,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => AlertsUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
    includeExpired: includeExpired ?? this.includeExpired,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includeExpired,
    nextCursor,
    busyIds,
    isLoadingMore,
  ];
}

final alertsViewModelProvider =
    AsyncNotifierProvider<AlertsViewModel, AlertsUiState>(AlertsViewModel.new);

class AlertsViewModel extends AsyncNotifier<AlertsUiState> {
  bool _includeExpired = false;
  int _revision = 0;

  @override
  Future<AlertsUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedAlerts>()(
      municipalityId: municipalityId,
      includeExpired: _includeExpired,
    );
    return switch (result) {
      Success(value: final page) => AlertsUiState(
        municipalityId: municipalityId,
        items: page.items,
        includeExpired: _includeExpired,
        nextCursor: page.nextCursor,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setIncludeExpired(bool value) async {
    if (_includeExpired == value) return;
    _includeExpired = value;
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
    final result = await getIt<GetManagedAlerts>()(
      municipalityId: current.municipalityId,
      includeExpired: current.includeExpired,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.municipalityId != current.municipalityId ||
        latest.includeExpired != current.includeExpired ||
        latest.nextCursor != requestedCursor) {
      return null;
    }

    if (result case Success(value: final page)) {
      final existingIds = latest.items.map((item) => item.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((item) => existingIds.add(item.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }

    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedAlertsPage>).error;
  }

  Future<AppFailure?> delete(ManagedAlert alert) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(alert.id)) return null;
    if (!alert.canManage) {
      return const ValidationFailure(message: 'alert_aemet_read_only');
    }

    _setBusy(alert.id, true);
    final result = await getIt<DeleteManualAlert>()(alert);
    final latest = state.valueOrNull;
    if (latest == null ||
        latest.municipalityId != current.municipalityId ||
        !latest.items.any((item) => item.id == alert.id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(alert.id, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((item) => item.id != alert.id).toList(),
        busyIds: {...latest.busyIds}..remove(alert.id),
      ),
    );
    return null;
  }

  void _setBusy(String id, bool busy) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.busyIds};
    busy ? ids.add(id) : ids.remove(id);
    state = AsyncData(current.copyWith(busyIds: ids));
  }
}
