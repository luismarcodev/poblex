import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../../domain/usecases/duty_pharmacy_usecases.dart';

class DutyPharmaciesUiState extends Equatable {
  const DutyPharmaciesUiState({
    required this.municipalityId,
    required this.month,
    required this.items,
  });

  final String municipalityId;
  final DateTime month;
  final List<DutyPharmacy> items;

  @override
  List<Object?> get props => [municipalityId, month, items];
}

final dutyPharmaciesViewModelProvider =
    AsyncNotifierProvider<DutyPharmaciesViewModel, DutyPharmaciesUiState>(
      DutyPharmaciesViewModel.new,
    );

class DutyPharmaciesViewModel extends AsyncNotifier<DutyPharmaciesUiState> {
  DateTime _month = _firstDayOfMonth(DateTime.now());

  @override
  Future<DutyPharmaciesUiState> build() async {
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final requestedMonth = _month;
    final result = await getIt<GetDutyPharmacies>()(
      municipalityId: municipalityId,
      month: requestedMonth,
    );
    return switch (result) {
      Success(value: final items) => DutyPharmaciesUiState(
        municipalityId: municipalityId,
        month: requestedMonth,
        items: [...items]
          ..sort((left, right) => left.date.compareTo(right.date)),
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> showPreviousMonth() =>
      _showMonth(DateTime(_month.year, _month.month - 1));

  Future<void> showNextMonth() =>
      _showMonth(DateTime(_month.year, _month.month + 1));

  Future<void> showCurrentMonth() => _showMonth(DateTime.now());

  Future<void> _showMonth(DateTime value) async {
    final next = _firstDayOfMonth(value);
    if (_sameDay(next, _month)) return;
    _month = next;
    ref.invalidateSelf();
    await future;
  }
}

DateTime _firstDayOfMonth(DateTime value) => DateTime(value.year, value.month);

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
