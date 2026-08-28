import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/facility.dart';
import '../../domain/usecases/facility_usecases.dart';

final myReservationsViewModelProvider =
    AsyncNotifierProvider<MyReservationsViewModel, MyReservationsUiState>(
      MyReservationsViewModel.new,
    );

class MyReservationsUiState extends Equatable {
  const MyReservationsUiState({
    this.items = const <Reservation>[],
    this.facilitiesById = const <String, Facility>{},
    this.refreshing = false,
    this.loadingMore = false,
    this.cancellingId,
    this.failure,
    this.nextCursor,
  });

  final List<Reservation> items;

  /// Los DTO de reserva no traen el nombre de la instalación (deliberado en
  /// el contrato del backend) — se resuelve en cliente contra la lista de
  /// instalaciones del municipio, cargada en paralelo.
  final Map<String, Facility> facilitiesById;
  final bool refreshing;
  final bool loadingMore;
  final String? cancellingId;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  MyReservationsUiState copyWith({
    List<Reservation>? items,
    Map<String, Facility>? facilitiesById,
    bool? refreshing,
    bool? loadingMore,
    String? cancellingId,
    bool clearCancellingId = false,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => MyReservationsUiState(
    items: items ?? this.items,
    facilitiesById: facilitiesById ?? this.facilitiesById,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    cancellingId: clearCancellingId ? null : cancellingId ?? this.cancellingId,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    facilitiesById,
    refreshing,
    loadingMore,
    cancellingId,
    failure,
    nextCursor,
  ];
}

class MyReservationsViewModel extends AsyncNotifier<MyReservationsUiState> {
  late final GetMyReservations _getMyReservations = getIt<GetMyReservations>();
  late final GetFacilities _getFacilities = getIt<GetFacilities>();
  late final CancelReservation _cancelReservation = getIt<CancelReservation>();
  int _requestVersion = 0;

  @override
  Future<MyReservationsUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const MyReservationsUiState(failure: ValidationFailure());
    }
    return _load(
      municipalityId: municipalityId,
      base: const MyReservationsUiState(),
    );
  }

  Future<MyReservationsUiState> _load({
    required String municipalityId,
    required MyReservationsUiState base,
  }) async {
    final Future<Result<ReservationPage>> reservationsFuture =
        _getMyReservations();
    final Future<Result<List<Facility>>> facilitiesFuture = _getFacilities(
      municipalityId: municipalityId,
    );
    final (Result<ReservationPage>, Result<List<Facility>>) results = await (
      reservationsFuture,
      facilitiesFuture,
    ).wait;

    final Map<String, Facility> facilitiesById = switch (results.$2) {
      Success<List<Facility>>(:final value) => <String, Facility>{
        for (final Facility facility in value) facility.id: facility,
      },
      Failed<List<Facility>>() => base.facilitiesById,
    };

    return switch (results.$1) {
      Success<ReservationPage>(:final value) => base.copyWith(
        items: value.items,
        facilitiesById: facilitiesById,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<ReservationPage>(:final failure) => base.copyWith(
        facilitiesById: facilitiesById,
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final MyReservationsUiState current =
        state.value ?? const MyReservationsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<MyReservationsUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<MyReservationsUiState>();
    final MyReservationsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<MyReservationsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final MyReservationsUiState current =
        state.value ?? const MyReservationsUiState();
    if (!current.canLoadMore) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<MyReservationsUiState>(
      current.copyWith(loadingMore: true),
    );
    final Result<ReservationPage> result = await _getMyReservations(
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<MyReservationsUiState>(switch (result) {
      Success<ReservationPage>(:final value) => current.copyWith(
        items: <Reservation>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<ReservationPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }

  Future<void> cancel(String reservationId) async {
    final MyReservationsUiState current =
        state.value ?? const MyReservationsUiState();
    if (current.cancellingId != null) return;
    state = AsyncData<MyReservationsUiState>(
      current.copyWith(cancellingId: reservationId, clearFailure: true),
    );
    final Result<void> result = await _cancelReservation(reservationId);
    switch (result) {
      case Success<void>():
        state = AsyncData<MyReservationsUiState>(
          current.copyWith(
            items: current.items
                .where(
                  (Reservation reservation) =>
                      reservation.id != reservationId,
                )
                .toList(growable: false),
            clearCancellingId: true,
          ),
        );
      case Failed<void>(:final failure):
        state = AsyncData<MyReservationsUiState>(
          current.copyWith(clearCancellingId: true, failure: failure),
        );
    }
  }
}
