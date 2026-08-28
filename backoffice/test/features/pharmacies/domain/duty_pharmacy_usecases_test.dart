import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/repositories/duty_pharmacy_repository.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/usecases/duty_pharmacy_usecases.dart';

class FakeDutyPharmacyRepository implements DutyPharmacyRepository {
  final ranges = <({String municipalityId, DateTime from, int days})>[];
  final writes = <String>[];
  List<DutyPharmacy> existing = const [];

  @override
  Future<Result<List<DutyPharmacy>>> getInRange({
    required String municipalityId,
    required DateTime from,
    required int days,
  }) async {
    ranges.add((municipalityId: municipalityId, from: from, days: days));
    return Success(existing);
  }

  @override
  Future<Result<DutyPharmacy>> upsert({
    required String municipalityId,
    required SaveDutyPharmacyInput input,
  }) async {
    writes.add(municipalityId);
    return Success(_pharmacy(municipalityId));
  }
}

void main() {
  test('requests every day of the selected month', () async {
    final repository = FakeDutyPharmacyRepository();

    await GetDutyPharmacies(repository)(
      municipalityId: 'sollana',
      month: DateTime(2028, 2, 20),
    );

    expect(repository.ranges.single.from, DateTime(2028, 2));
    expect(repository.ranges.single.days, 29);
  });

  test('blocks an accidental overwrite before writing', () async {
    final repository = FakeDutyPharmacyRepository()
      ..existing = [_pharmacy('sollana')];

    final result = await SaveDutyPharmacy(repository)(_input());

    expect(result, isA<Failure<List<DutyPharmacy>>>());
    expect(
      (result as Failure<List<DutyPharmacy>>).error,
      isA<ConflictFailure>(),
    );
    expect(repository.writes, isEmpty);
  });

  test('publishes to each unique selected municipality', () async {
    final repository = FakeDutyPharmacyRepository();

    final result = await SaveDutyPharmacy(repository)(
      _input(municipalityIds: const ['sollana', 'sueca', 'sollana']),
    );

    expect(result, isA<Success<List<DutyPharmacy>>>());
    expect(repository.writes, ['sollana', 'sueca']);
  });

  test('editing intentionally replaces the existing day', () async {
    final repository = FakeDutyPharmacyRepository()
      ..existing = [_pharmacy('sollana')];

    final result = await SaveDutyPharmacy(repository)(
      _input(replaceExisting: true),
    );

    expect(result, isA<Success<List<DutyPharmacy>>>());
    expect(repository.ranges, isEmpty);
    expect(repository.writes, ['sollana']);
  });
}

SaveDutyPharmacyInput _input({
  List<String> municipalityIds = const ['sollana'],
  bool replaceExisting = false,
}) => SaveDutyPharmacyInput(
  date: DateTime(2026, 8, 12),
  pharmacyName: 'Farmacia Ribera',
  address: 'Carrer Major, 12',
  phone: '961 234 567',
  schedule: '9:00 - 22:00',
  municipalityIds: municipalityIds,
  replaceExisting: replaceExisting,
);

DutyPharmacy _pharmacy(String municipalityId) => DutyPharmacy(
  id: 'pharmacy-$municipalityId',
  municipalityId: municipalityId,
  date: DateTime(2026, 8, 12),
  pharmacyName: 'Farmacia Ribera',
  address: 'Carrer Major, 12',
  phone: '961 234 567',
  schedule: '9:00 - 22:00',
);
