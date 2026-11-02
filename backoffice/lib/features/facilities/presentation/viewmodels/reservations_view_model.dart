import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_facility.dart';
import '../../domain/usecases/facility_usecases.dart';

class ReservationsUiState extends Equatable {
  const ReservationsUiState({
    required this.municipalityId,
    required this.facilities,
    required this.items,
    required this.nextCursor,
    this.facilityFilter,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedFacility> facilities;
  final List<ManagedReservation> items;
  final String? nextCursor;
  final String? facilityFilter;
  final Set<String> busyIds;
  final bool isLoadingMore;

  ManagedFacility? facilityFor(String facilityId) {
    for (final facility in facilities) {
      if (facility.id == facilityId) return facility;
    }
    return null;
  }

  ReservationsUiState copyWith({
    String? municipalityId,
    List<ManagedFacility>? facilities,
    List<ManagedReservation>? items,
    String? nextCursor,
    bool clearCursor = false,
    String? facilityFilter,
    bool clearFacilityFilter = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => ReservationsUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    facilities: facilities ?? this.facilities,
    items: items ?? this.items,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    facilityFilter: clearFacilityFilter
        ? null
        : facilityFilter ?? this.facilityFilter,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    facilities,
    items,
    nextCursor,
    facilityFilter,
    busyIds,
    isLoadingMore,
  ];
}

final reservationsViewModelProvider =
    AsyncNotifierProvider<ReservationsViewModel, ReservationsUiState>(
      ReservationsViewModel.new,
    );

class ReservationsViewModel extends AsyncNotifier<ReservationsUiState> {
  String? _facilityFilter;
  int _revision = 0;

  @override
  Future<ReservationsUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final facilitiesFuture = getIt<GetManagedFacilities>()(
      municipalityId: municipalityId,
    );
    final reservationsFuture = getIt<GetManagedReservations>()(
      municipalityId: municipalityId,
      facilityId: _facilityFilter,
    );
    final results = await (facilitiesFuture, reservationsFuture).wait;

    final facilities = switch (results.$1) {
      Success(value: final page) => page.items,
      Failure() => const <ManagedFacility>[],
    };
    return switch (results.$2) {
      Success(value: final page) => ReservationsUiState(
        municipalityId: municipalityId,
        facilities: facilities,
        items: page.items,
        nextCursor: page.nextCursor,
        facilityFilter: _facilityFilter,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setFacilityFilter(String? facilityId) async {
    if (_facilityFilter == facilityId) return;
    _facilityFilter = facilityId;
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return;
    }
    final requestedCursor = current.nextCursor!;
    final requestedRevision = _revision;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<GetManagedReservations>()(
      municipalityId: current.municipalityId,
      facilityId: current.facilityFilter,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.nextCursor != requestedCursor) {
      return;
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
      return;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
  }

  Future<AppFailure?> cancel({
    required String reservationId,
    required String note,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(reservationId)) return null;
    _setBusy(reservationId, true);
    final result = await getIt<CancelManagedReservation>()(
      reservationId: reservationId,
      note: note,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        !latest.items.any((item) => item.id == reservationId)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(reservationId, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((item) => item.id != reservationId).toList(),
        busyIds: {...latest.busyIds}..remove(reservationId),
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
