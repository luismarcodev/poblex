import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';
import 'package:poblex_backoffice/features/alerts/domain/repositories/alert_repository.dart';
import 'package:poblex_backoffice/features/alerts/domain/usecases/alert_usecases.dart';
import 'package:poblex_backoffice/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeAlertRepository implements AlertRepository {
  final loadMoreResult = Completer<Result<ManagedAlertsPage>>();
  int loadMoreCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Result<ManagedAlertsPage>> getManagedAlerts({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) async {
    if (cursor == null) {
      return Success(
        ManagedAlertsPage(items: [_manual(), _aemet()], nextCursor: 'next'),
      );
    }
    loadMoreCalls++;
    return loadMoreResult.future;
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleteCalls++;
    return const Success<void>(null);
  }

  @override
  Future<Result<ManagedAlert>> create(SaveManualAlertInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<ManagedAlert>> getById({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedAlert>> update(SaveManualAlertInput input) =>
      throw UnimplementedError();
}

void main() {
  late FakeAlertRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeAlertRepository();
    getIt.registerFactory(() => GetManagedAlerts(repository));
    getIt.registerFactory(() => DeleteManualAlert(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(alertsViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'prevents duplicate pagination and preserves items on failure',
    () async {
      final viewModel = container.read(alertsViewModelProvider.notifier);

      final first = viewModel.loadMore();
      final duplicate = viewModel.loadMore();
      expect(repository.loadMoreCalls, 1);
      repository.loadMoreResult.complete(
        const Failure(NetworkFailure(message: 'offline')),
      );

      expect(await first, isA<NetworkFailure>());
      expect(await duplicate, isNull);
      expect(
        container.read(alertsViewModelProvider).value!.items,
        hasLength(2),
      );
      expect(
        container.read(alertsViewModelProvider).value!.isLoadingMore,
        isFalse,
      );
    },
  );

  test('discards a stale pagination response after a refresh', () async {
    final viewModel = container.read(alertsViewModelProvider.notifier);
    final pagination = viewModel.loadMore();

    await viewModel.refresh();
    repository.loadMoreResult.complete(
      Success(
        ManagedAlertsPage(
          items: [
            ManagedAlert(
              id: 'stale',
              municipalityId: municipality.id,
              source: ManagedAlertSource.manual,
              severity: ManagedAlertSeverity.yellow,
              phenomenonType: ManagedAlertPhenomenonType.meteorologico,
              phenomenon: 'Stale',
              body: const AlertLocalizedText(es: 'Stale'),
              startAt: DateTime.utc(2026, 8, 11),
              forcesNotification: false,
            ),
          ],
          nextCursor: null,
        ),
      ),
    );

    expect(await pagination, isNull);
    expect(
      container
          .read(alertsViewModelProvider)
          .value!
          .items
          .map((item) => item.id),
      ['manual', 'aemet'],
    );
  });

  test(
    'blocks deleting an AEMET alert before reaching the repository',
    () async {
      final failure = await container
          .read(alertsViewModelProvider.notifier)
          .delete(_aemet());

      expect(failure, isA<ValidationFailure>());
      expect(repository.deleteCalls, 0);
    },
  );

  test('removes a manual alert after a successful deletion', () async {
    final failure = await container
        .read(alertsViewModelProvider.notifier)
        .delete(_manual());

    expect(failure, isNull);
    expect(repository.deleteCalls, 1);
    expect(
      container
          .read(alertsViewModelProvider)
          .value!
          .items
          .map((item) => item.id),
      ['aemet'],
    );
  });
}

ManagedAlert _manual() => ManagedAlert(
  id: 'manual',
  municipalityId: municipality.id,
  source: ManagedAlertSource.manual,
  severity: ManagedAlertSeverity.orange,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Lluvias',
  body: const AlertLocalizedText(es: 'Precaución'),
  startAt: DateTime.utc(2026, 8, 10, 10),
  forcesNotification: false,
);

ManagedAlert _aemet() => ManagedAlert(
  id: 'aemet',
  municipalityId: municipality.id,
  source: ManagedAlertSource.aemet,
  severity: ManagedAlertSeverity.red,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Tormenta',
  body: const AlertLocalizedText(es: 'Alerta oficial'),
  startAt: DateTime.utc(2026, 8, 10, 10),
  forcesNotification: true,
);
