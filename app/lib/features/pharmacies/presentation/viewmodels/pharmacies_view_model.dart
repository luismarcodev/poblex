import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../../domain/usecases/duty_pharmacy_usecases.dart';

final pharmaciesViewModelProvider =
    AsyncNotifierProvider<PharmaciesViewModel, PharmaciesUiState>(
      PharmaciesViewModel.new,
    );

const int _upcomingWindowDays = 14;

class PharmaciesUiState extends Equatable {
  const PharmaciesUiState({
    this.today,
    this.upcoming = const <DutyPharmacy>[],
    this.refreshing = false,
    this.failure,
  });

  /// Null means either no pharmacy is registered for today (a valid, common
  /// state — see [pharmacyNoneToday]) or the load hasn't happened yet.
  final DutyPharmacy? today;
  final List<DutyPharmacy> upcoming;
  final bool refreshing;
  final AppFailure? failure;

  PharmaciesUiState copyWith({
    DutyPharmacy? today,
    bool clearToday = false,
    List<DutyPharmacy>? upcoming,
    bool? refreshing,
    AppFailure? failure,
    bool clearFailure = false,
  }) => PharmaciesUiState(
    today: clearToday ? null : today ?? this.today,
    upcoming: upcoming ?? this.upcoming,
    refreshing: refreshing ?? this.refreshing,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[today, upcoming, refreshing, failure];
}

class PharmaciesViewModel extends AsyncNotifier<PharmaciesUiState> {
  late final GetTodayDutyPharmacy _getToday = getIt<GetTodayDutyPharmacy>();
  late final GetDutyPharmacies _getUpcoming = getIt<GetDutyPharmacies>();
  int _requestVersion = 0;

  @override
  Future<PharmaciesUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const PharmaciesUiState(failure: ValidationFailure());
    }
    return _load(municipalityId);
  }

  Future<PharmaciesUiState> _load(String municipalityId) async {
    final Result<DutyPharmacy> todayResult = await _getToday(municipalityId);
    final Result<List<DutyPharmacy>> upcomingResult = await _getUpcoming(
      municipalityId: municipalityId,
      from: DateTime.now().add(const Duration(days: 1)),
      days: _upcomingWindowDays,
    );

    DutyPharmacy? today;
    AppFailure? todayFailure;
    switch (todayResult) {
      case Success<DutyPharmacy>(:final value):
        today = value;
      case Failed<DutyPharmacy>(failure: NotFoundFailure()):
        today = null;
      case Failed<DutyPharmacy>(:final failure):
        todayFailure = failure;
    }

    return switch (upcomingResult) {
      Success<List<DutyPharmacy>>(:final value) => PharmaciesUiState(
        today: today,
        upcoming: value,
        failure: todayFailure,
      ),
      Failed<List<DutyPharmacy>>(:final failure) => PharmaciesUiState(
        today: today,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final PharmaciesUiState current = state.value ?? const PharmaciesUiState();
    final int requestVersion = ++_requestVersion;
    state = current.today != null || current.upcoming.isNotEmpty
        ? AsyncData<PharmaciesUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<PharmaciesUiState>();
    final PharmaciesUiState loaded = await _load(municipalityId);
    if (requestVersion == _requestVersion) {
      state = AsyncData<PharmaciesUiState>(loaded);
    }
  }
}
