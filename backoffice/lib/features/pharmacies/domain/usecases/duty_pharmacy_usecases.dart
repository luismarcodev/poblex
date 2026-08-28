import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/duty_pharmacy.dart';
import '../repositories/duty_pharmacy_repository.dart';

class GetDutyPharmacies {
  const GetDutyPharmacies(this._repository);

  final DutyPharmacyRepository _repository;

  Future<Result<List<DutyPharmacy>>> call({
    required String municipalityId,
    required DateTime month,
  }) {
    final firstDay = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    return _repository.getInRange(
      municipalityId: municipalityId,
      from: firstDay,
      days: days,
    );
  }
}

class SaveDutyPharmacy {
  const SaveDutyPharmacy(this._repository);

  final DutyPharmacyRepository _repository;

  Future<Result<List<DutyPharmacy>>> call(SaveDutyPharmacyInput input) async {
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final municipalityIds = input.municipalityIds.toSet().toList();
    if (!input.replaceExisting) {
      for (final municipalityId in municipalityIds) {
        final existing = await _repository.getInRange(
          municipalityId: municipalityId,
          from: input.date,
          days: 1,
        );
        switch (existing) {
          case Success(value: final items) when items.isNotEmpty:
            return const Failure(
              ConflictFailure(message: 'duty_pharmacy_date_exists'),
            );
          case Failure(error: final error):
            return Failure(error);
          default:
            break;
        }
      }
    }

    final saved = <DutyPharmacy>[];
    for (final municipalityId in municipalityIds) {
      final result = await _repository.upsert(
        municipalityId: municipalityId,
        input: input,
      );
      switch (result) {
        case Success(value: final pharmacy):
          saved.add(pharmacy);
        case Failure(error: final error):
          return Failure(error);
      }
    }
    return Success(saved);
  }

  ValidationFailure? _validate(SaveDutyPharmacyInput input) {
    if (input.municipalityIds.isEmpty) {
      return const ValidationFailure(message: 'municipality_required');
    }
    final fields = <(String, int)>[
      (input.pharmacyName, 200),
      (input.address, 300),
      (input.phone, 50),
      (input.schedule, 100),
    ];
    for (final (value, maxLength) in fields) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.length > maxLength) {
        return const ValidationFailure(message: 'invalid_pharmacy_fields');
      }
    }
    return null;
  }
}
