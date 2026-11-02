import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/facility.dart';
import '../../domain/usecases/facility_usecases.dart';

final facilityDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<FacilityDetailViewModel, FacilityDetailUiState, String>(
      FacilityDetailViewModel.new,
    );

String formatApiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class FacilityDetailUiState extends Equatable {
  const FacilityDetailUiState({
    this.facility,
    required this.selectedDate,
    this.slots = const <AvailabilitySlot>[],
    this.loadingSlots = false,
    this.booking = false,
    this.failure,
    this.bookedSlot,
  });

  final Facility? facility;
  final DateTime selectedDate;
  final List<AvailabilitySlot> slots;
  final bool loadingSlots;
  final bool booking;
  final AppFailure? failure;

  /// Último hueco reservado con éxito en esta sesión de pantalla — dispara
  /// la confirmación visible y desaparece al elegir otro día u otro hueco.
  final AvailabilitySlot? bookedSlot;

  FacilityDetailUiState copyWith({
    Facility? facility,
    DateTime? selectedDate,
    List<AvailabilitySlot>? slots,
    bool? loadingSlots,
    bool? booking,
    AppFailure? failure,
    bool clearFailure = false,
    AvailabilitySlot? bookedSlot,
    bool clearBookedSlot = false,
  }) => FacilityDetailUiState(
    facility: facility ?? this.facility,
    selectedDate: selectedDate ?? this.selectedDate,
    slots: slots ?? this.slots,
    loadingSlots: loadingSlots ?? this.loadingSlots,
    booking: booking ?? this.booking,
    failure: clearFailure ? null : failure ?? this.failure,
    bookedSlot: clearBookedSlot ? null : bookedSlot ?? this.bookedSlot,
  );

  @override
  List<Object?> get props => <Object?>[
    facility,
    selectedDate,
    slots,
    loadingSlots,
    booking,
    failure,
    bookedSlot,
  ];
}

class FacilityDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<FacilityDetailUiState, String> {
  late final GetFacilityDetail _getFacility = getIt<GetFacilityDetail>();
  late final GetFacilityAvailability _getAvailability =
      getIt<GetFacilityAvailability>();
  late final CreateReservation _createReservation = getIt<CreateReservation>();
  int _requestVersion = 0;

  @override
  Future<FacilityDetailUiState> build(String arg) async {
    final DateTime today = DateTime.now().toUtc();
    final DateTime initialDate = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).add(const Duration(days: 1));
    final Result<Facility> result = await _getFacility(arg);
    return switch (result) {
      Success<Facility>(:final value) => await _loadSlots(
        FacilityDetailUiState(facility: value, selectedDate: initialDate),
      ),
      Failed<Facility>(:final failure) => FacilityDetailUiState(
        selectedDate: initialDate,
        failure: failure,
      ),
    };
  }

  Future<FacilityDetailUiState> _loadSlots(FacilityDetailUiState base) async {
    final Result<List<AvailabilitySlot>> result = await _getAvailability(
      facilityId: arg,
      date: formatApiDate(base.selectedDate),
    );
    return switch (result) {
      Success<List<AvailabilitySlot>>(:final value) => base.copyWith(
        slots: value,
        loadingSlots: false,
        clearFailure: true,
      ),
      Failed<List<AvailabilitySlot>>(:final failure) => base.copyWith(
        slots: const <AvailabilitySlot>[],
        loadingSlots: false,
        failure: failure,
      ),
    };
  }

  Future<void> selectDate(DateTime date) async {
    final FacilityDetailUiState current = state.requireValue;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<FacilityDetailUiState>(
      current.copyWith(
        selectedDate: date,
        loadingSlots: true,
        clearBookedSlot: true,
      ),
    );
    final FacilityDetailUiState loaded = await _loadSlots(
      current.copyWith(selectedDate: date, clearBookedSlot: true),
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<FacilityDetailUiState>(loaded);
    }
  }

  Future<void> book(AvailabilitySlot slot) async {
    final FacilityDetailUiState? current = state.value;
    if (current == null || current.booking) return;
    state = AsyncData<FacilityDetailUiState>(
      current.copyWith(booking: true, clearFailure: true),
    );
    final Result<Reservation> result = await _createReservation(
      facilityId: arg,
      slotStart: slot.start,
    );
    switch (result) {
      case Success<Reservation>():
        final FacilityDetailUiState refreshed = await _loadSlots(
          current.copyWith(booking: false),
        );
        state = AsyncData<FacilityDetailUiState>(
          refreshed.copyWith(bookedSlot: slot),
        );
      case Failed<Reservation>(:final failure):
        final FacilityDetailUiState refreshed = await _loadSlots(
          current.copyWith(booking: false, failure: failure),
        );
        state = AsyncData<FacilityDetailUiState>(
          refreshed.copyWith(failure: failure),
        );
    }
  }
}
