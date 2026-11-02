import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_incident.dart';
import '../../domain/usecases/incident_usecases.dart';

class IncidentsUiState extends Equatable {
  const IncidentsUiState({
    required this.municipalityId,
    required this.items,
    required this.nextCursor,
    this.statusFilter,
    this.categoryFilter,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedIncident> items;
  final String? nextCursor;
  final IncidentStatus? statusFilter;
  final String? categoryFilter;
  final Set<String> busyIds;
  final bool isLoadingMore;

  IncidentsUiState copyWith({
    List<ManagedIncident>? items,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => IncidentsUiState(
    municipalityId: municipalityId,
    items: items ?? this.items,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    statusFilter: statusFilter,
    categoryFilter: categoryFilter,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    nextCursor,
    statusFilter,
    categoryFilter,
    busyIds,
    isLoadingMore,
  ];
}

final incidentsViewModelProvider =
    AsyncNotifierProvider<IncidentsViewModel, IncidentsUiState>(
      IncidentsViewModel.new,
    );

final incidentCategoriesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, municipalityId) async {
      final result = await getIt<ListIncidentCategories>()(municipalityId);
      return switch (result) {
        Success(value: final categories) => categories,
        Failure() => const <String>[],
      };
    });

final incidentHistoryProvider = FutureProvider.autoDispose
    .family<List<IncidentStatusChange>, String>((ref, incidentId) async {
      final result = await getIt<GetIncidentHistory>()(incidentId);
      return switch (result) {
        Success(value: final history) => history,
        Failure(error: final error) => throw error,
      };
    });

class IncidentsViewModel extends AsyncNotifier<IncidentsUiState> {
  IncidentStatus? _statusFilter;
  String? _categoryFilter;

  @override
  Future<IncidentsUiState> build() async {
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedIncidents>()(
      municipalityId: municipalityId,
      status: _statusFilter,
      category: _categoryFilter,
    );
    return switch (result) {
      Success(value: final page) => IncidentsUiState(
        municipalityId: municipalityId,
        items: page.items,
        nextCursor: page.nextCursor,
        statusFilter: _statusFilter,
        categoryFilter: _categoryFilter,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> applyFilters({IncidentStatus? status, String? category}) async {
    final normalizedCategory = category?.trim().toLowerCase();
    final nextCategory =
        normalizedCategory == null || normalizedCategory.isEmpty
        ? null
        : normalizedCategory;
    if (_statusFilter == status && _categoryFilter == nextCategory) return;
    _statusFilter = status;
    _categoryFilter = nextCategory;
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
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<GetManagedIncidents>()(
      municipalityId: current.municipalityId,
      status: current.statusFilter,
      category: current.categoryFilter,
      cursor: current.nextCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        !_sameQuery(latest, current) ||
        !latest.isLoadingMore ||
        latest.nextCursor != current.nextCursor) {
      return null;
    }

    if (result case Success(value: final page)) {
      final ids = latest.items.map((incident) => incident.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((incident) => ids.add(incident.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedIncidentsPage>).error;
  }

  Future<AppFailure?> changeStatus({
    required ManagedIncident incident,
    required IncidentStatus status,
    String? note,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(incident.id)) return null;
    _setBusy(incident.id, true);

    final result = await getIt<ChangeManagedIncidentStatus>()(
      ChangeIncidentStatusInput(incident: incident, status: status, note: note),
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        latest.municipalityId != current.municipalityId ||
        !latest.items.any((item) => item.id == incident.id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(incident.id, false);
      return error;
    }

    final updated = (result as Success<ManagedIncident>).value;
    final remainsVisible =
        (latest.statusFilter == null ||
            latest.statusFilter == updated.status) &&
        (latest.categoryFilter == null ||
            latest.categoryFilter == updated.category);
    state = AsyncData(
      latest.copyWith(
        items: remainsVisible
            ? latest.items
                  .map((item) => item.id == updated.id ? updated : item)
                  .toList(growable: false)
            : latest.items
                  .where((item) => item.id != updated.id)
                  .toList(growable: false),
        busyIds: {...latest.busyIds}..remove(updated.id),
      ),
    );
    return null;
  }

  bool _sameQuery(IncidentsUiState a, IncidentsUiState b) =>
      a.municipalityId == b.municipalityId &&
      a.statusFilter == b.statusFilter &&
      a.categoryFilter == b.categoryFilter;

  void _setBusy(String id, bool busy) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.busyIds};
    busy ? ids.add(id) : ids.remove(id);
    state = AsyncData(current.copyWith(busyIds: ids));
  }
}
