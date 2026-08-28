import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/errors/failure.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/pharmacies/domain/entities/duty_pharmacy.dart';
import 'package:poblex/features/pharmacies/domain/repositories/duty_pharmacy_repository.dart';
import 'package:poblex/features/pharmacies/domain/usecases/duty_pharmacy_usecases.dart';
import 'package:poblex/features/pharmacies/presentation/viewmodels/pharmacies_view_model.dart';

class _ControlledSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => const SessionState(
    deviceId: 'device-1',
    municipalityId: 'municipality-1',
    municipalityName: 'Sollana',
    municipalitySlug: 'sollana',
    deviceLocale: AppLocale.es,
  );
}

class _StubDutyPharmacyRepository implements DutyPharmacyRepository {
  _StubDutyPharmacyRepository({required this.todayResult});
  final Result<DutyPharmacy> todayResult;

  @override
  Future<Result<List<DutyPharmacy>>> list({
    required String municipalityId,
    DateTime? from,
    int? days,
  }) async => const Success<List<DutyPharmacy>>(<DutyPharmacy>[]);

  @override
  Future<Result<DutyPharmacy>> today(String municipalityId) async =>
      todayResult;
}

ProviderContainer _buildContainer(DutyPharmacyRepository repository) {
  getIt
    ..registerSingleton<GetDutyPharmacies>(GetDutyPharmacies(repository))
    ..registerSingleton<GetTodayDutyPharmacy>(GetTodayDutyPharmacy(repository));
  return ProviderContainer(
    overrides: <Override>[
      sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
    ],
  );
}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'no pharmacy registered for today is a valid empty state, not a failure',
    () async {
      final container = _buildContainer(
        _StubDutyPharmacyRepository(
          todayResult: const Failed<DutyPharmacy>(NotFoundFailure()),
        ),
      );
      addTearDown(container.dispose);

      final PharmaciesUiState state = await container.read(
        pharmaciesViewModelProvider.future,
      );

      expect(state.today, isNull);
      expect(state.failure, isNull);
    },
  );

  test('a real error fetching today surfaces as a failure', () async {
    final container = _buildContainer(
      _StubDutyPharmacyRepository(
        todayResult: const Failed<DutyPharmacy>(NetworkFailure()),
      ),
    );
    addTearDown(container.dispose);

    final PharmaciesUiState state = await container.read(
      pharmaciesViewModelProvider.future,
    );

    expect(state.today, isNull);
    expect(state.failure, const NetworkFailure());
  });
}
