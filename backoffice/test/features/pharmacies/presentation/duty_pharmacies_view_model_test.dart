import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/repositories/duty_pharmacy_repository.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/usecases/duty_pharmacy_usecases.dart';
import 'package:poblex_backoffice/features/pharmacies/presentation/viewmodels/duty_pharmacies_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeDutyPharmacyRepository implements DutyPharmacyRepository {
  int calls = 0;
  final requestedMonths = <DateTime>[];

  @override
  Future<Result<List<DutyPharmacy>>> getInRange({
    required String municipalityId,
    required DateTime from,
    required int days,
  }) async {
    calls++;
    requestedMonths.add(from);
    return Success([
      _pharmacy('later', DateTime(from.year, from.month, 20)),
      _pharmacy('earlier', DateTime(from.year, from.month, 2)),
    ]);
  }

  @override
  Future<Result<DutyPharmacy>> upsert({
    required String municipalityId,
    required SaveDutyPharmacyInput input,
  }) => throw UnimplementedError();
}

void main() {
  late FakeDutyPharmacyRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeDutyPharmacyRepository();
    getIt.registerFactory(() => GetDutyPharmacies(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(dutyPharmaciesViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('sorts the monthly list chronologically', () {
    final state = container.read(dutyPharmaciesViewModelProvider).value!;

    expect(state.items.map((item) => item.id), ['earlier', 'later']);
  });

  test('moves one month without issuing duplicate loads', () async {
    final initial = container
        .read(dutyPharmaciesViewModelProvider)
        .value!
        .month;

    await container
        .read(dutyPharmaciesViewModelProvider.notifier)
        .showNextMonth();

    final current = container
        .read(dutyPharmaciesViewModelProvider)
        .value!
        .month;
    expect(current, DateTime(initial.year, initial.month + 1));
    expect(repository.calls, 2);
  });

  test('does not reload when irrelevant municipality fields change', () async {
    container
        .read(selectedMunicipalityProvider.notifier)
        .select(
          const ManagedMunicipality(
            id: 'sollana',
            name: 'Sollana actualizada',
            province: 'València',
            languages: ['es', 'va'],
          ),
        );
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 1);
  });
}

DutyPharmacy _pharmacy(String id, DateTime date) => DutyPharmacy(
  id: id,
  municipalityId: municipality.id,
  date: date,
  pharmacyName: 'Farmacia Ribera',
  address: 'Carrer Major, 12',
  phone: '961 234 567',
  schedule: '9:00 - 22:00',
);
