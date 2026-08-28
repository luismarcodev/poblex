import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';
import 'package:poblex_backoffice/features/alerts/domain/repositories/alert_repository.dart';
import 'package:poblex_backoffice/features/alerts/domain/usecases/alert_usecases.dart';

class FakeAlertRepository implements AlertRepository {
  int createCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Result<ManagedAlert>> create(SaveManualAlertInput input) async {
    createCalls++;
    return Success(_alert());
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleteCalls++;
    return const Success<void>(null);
  }

  @override
  Future<Result<ManagedAlert>> getById({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedAlertsPage>> getManagedAlerts({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedAlert>> update(SaveManualAlertInput input) =>
      throw UnimplementedError();
}

void main() {
  test('rejects an end before the start without publishing', () async {
    final repository = FakeAlertRepository();
    final result = await SaveManualAlert(repository)(
      _input(endAt: DateTime.utc(2026, 8, 10, 9)),
    );

    expect(result, isA<Failure<ManagedAlert>>());
    expect(repository.createCalls, 0);
  });

  test('publishes a valid manual alert', () async {
    final repository = FakeAlertRepository();
    final result = await SaveManualAlert(repository)(_input());

    expect(result, isA<Success<ManagedAlert>>());
    expect(repository.createCalls, 1);
  });

  test('never deletes an AEMET alert through the admin endpoint', () async {
    final repository = FakeAlertRepository();
    final result = await DeleteManualAlert(repository)(
      _alert(source: ManagedAlertSource.aemet),
    );

    expect(result, isA<Failure<void>>());
    expect(repository.deleteCalls, 0);
  });
}

SaveManualAlertInput _input({DateTime? endAt}) => SaveManualAlertInput(
  municipalityId: 'municipality-1',
  severity: ManagedAlertSeverity.orange,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Lluvias',
  body: const AlertLocalizedText(es: 'Precaución'),
  startAt: DateTime.utc(2026, 8, 10, 10),
  endAt: endAt,
);

ManagedAlert _alert({ManagedAlertSource source = ManagedAlertSource.manual}) =>
    ManagedAlert(
      id: 'alert-1',
      municipalityId: 'municipality-1',
      source: source,
      severity: ManagedAlertSeverity.orange,
      phenomenonType: ManagedAlertPhenomenonType.meteorologico,
      phenomenon: 'Lluvias',
      body: const AlertLocalizedText(es: 'Precaución'),
      startAt: DateTime.utc(2026, 8, 10, 10),
      forcesNotification: false,
    );
