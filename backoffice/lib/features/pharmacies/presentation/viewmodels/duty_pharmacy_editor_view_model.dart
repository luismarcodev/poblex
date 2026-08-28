import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../../domain/usecases/duty_pharmacy_usecases.dart';

class DutyPharmacyEditorUiState extends Equatable {
  const DutyPharmacyEditorUiState({this.pharmacy});

  final DutyPharmacy? pharmacy;

  @override
  List<Object?> get props => [pharmacy];
}

final dutyPharmacyEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      DutyPharmacyEditorViewModel,
      DutyPharmacyEditorUiState
    >(DutyPharmacyEditorViewModel.new);

class DutyPharmacyEditorViewModel
    extends AutoDisposeAsyncNotifier<DutyPharmacyEditorUiState> {
  @override
  DutyPharmacyEditorUiState build() => const DutyPharmacyEditorUiState();

  Future<void> load({
    required String municipalityId,
    required DateTime date,
    DutyPharmacy? initial,
  }) async {
    if (initial != null &&
        initial.municipalityId == municipalityId &&
        _sameDay(initial.date, date)) {
      state = AsyncData(DutyPharmacyEditorUiState(pharmacy: initial));
      return;
    }
    state = const AsyncLoading();
    final result = await getIt<GetDutyPharmacies>()(
      municipalityId: municipalityId,
      month: date,
    );
    state = switch (result) {
      Success(value: final items) => switch (items
          .cast<DutyPharmacy?>()
          .firstWhere(
            (item) => item != null && _sameDay(item.date, date),
            orElse: () => null,
          )) {
        final DutyPharmacy pharmacy => AsyncData(
          DutyPharmacyEditorUiState(pharmacy: pharmacy),
        ),
        null => AsyncError(
          const NotFoundFailure(message: 'duty_pharmacy_not_found'),
          StackTrace.current,
        ),
      },
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<AppFailure?> save(SaveDutyPharmacyInput input) async {
    final previous = state.valueOrNull ?? const DutyPharmacyEditorUiState();
    state = const AsyncLoading();
    final result = await getIt<SaveDutyPharmacy>()(input);
    state = AsyncData(previous);
    return switch (result) {
      Success() => null,
      Failure(error: final error) => error,
    };
  }
}

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
