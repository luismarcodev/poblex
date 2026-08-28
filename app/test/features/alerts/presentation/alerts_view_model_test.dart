import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/alerts/domain/entities/alert.dart';
import 'package:poblex/features/alerts/domain/repositories/alert_repository.dart';
import 'package:poblex/features/alerts/domain/usecases/alert_usecases.dart';
import 'package:poblex/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';

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

class _RecordingAlertRepository implements AlertRepository {
  int listCalls = 0;
  bool? lastIncludeExpired;

  @override
  Future<Result<AlertPage>> list({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) async {
    listCalls++;
    lastIncludeExpired = includeExpired;
    return Success<AlertPage>(
      AlertPage(
        items: includeExpired
            ? <MunicipalAlert>[_alert]
            : const <MunicipalAlert>[],
        nextCursor: null,
      ),
    );
  }

  @override
  Future<Result<MunicipalAlert>> detail({
    required String id,
    required String municipalityId,
  }) async => Success<MunicipalAlert>(_alert);
}

final MunicipalAlert _alert = MunicipalAlert(
  id: 'alert-1',
  municipalityId: 'municipality-1',
  source: AlertSource.aemet,
  severity: AlertSeverityLevel.orange,
  phenomenonType: AlertPhenomenonType.meteorologico,
  phenomenon: 'Viento',
  body: const LocalizedText(es: 'Rachas fuertes', va: 'Ratxes fortes'),
  startAt: DateTime.utc(2026, 8, 1),
  endAt: DateTime.utc(2026, 7, 1),
  forcesNotification: false,
);

void main() {
  late _RecordingAlertRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _RecordingAlertRepository();
    getIt
      ..registerSingleton<GetAlerts>(GetAlerts(repository))
      ..registerSingleton<GetAlertDetail>(GetAlertDetail(repository));
    container = ProviderContainer(
      overrides: <Override>[
        sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('toggling includeExpired reloads with the new flag', () async {
    final AlertsUiState initial = await container.read(
      alertsViewModelProvider.future,
    );
    expect(initial.includeExpired, isFalse);
    expect(initial.items, isEmpty);
    expect(repository.lastIncludeExpired, isFalse);

    await container
        .read(alertsViewModelProvider.notifier)
        .setIncludeExpired(true);

    final AlertsUiState toggled = container
        .read(alertsViewModelProvider)
        .requireValue;
    expect(toggled.includeExpired, isTrue);
    expect(toggled.items, <MunicipalAlert>[_alert]);
    expect(repository.listCalls, 2);
    expect(repository.lastIncludeExpired, isTrue);
  });

  test('setting the same value again does not trigger a reload', () async {
    await container.read(alertsViewModelProvider.future);
    final int callsAfterLoad = repository.listCalls;

    await container
        .read(alertsViewModelProvider.notifier)
        .setIncludeExpired(false);

    expect(repository.listCalls, callsAfterLoad);
  });
}
