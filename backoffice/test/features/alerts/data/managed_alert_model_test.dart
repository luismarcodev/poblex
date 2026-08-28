import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/alerts/data/models/managed_alert_model.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';

void main() {
  test('maps the complete alert contract and optional audit fields', () {
    final model = ManagedAlertModel.fromJson({
      'id': 'alert-1',
      'municipalityId': 'municipality-1',
      'source': 'manual',
      'severity': 'rojo',
      'phenomenonType': 'incendio',
      'phenomenon': 'Inundación',
      'body': {'es': 'Evita la zona', 'va': 'Evita la zona'},
      'startAt': '2026-08-10T10:00:00.000Z',
      'endAt': null,
      'forcesNotification': true,
      'createdBy': 'manager-1',
      'updatedBy': 'manager-2',
      'createdAt': '2026-08-10T09:00:00.000Z',
    });

    expect(model.entity.source, ManagedAlertSource.manual);
    expect(model.entity.severity, ManagedAlertSeverity.red);
    expect(model.entity.forcesNotification, isTrue);
    expect(model.entity.createdBy, 'manager-1');
    expect(model.entity.createdAt?.isUtc, isTrue);
    expect(
      model.entity.statusAt(DateTime.utc(2026, 8, 10, 11)),
      ManagedAlertStatus.active,
    );
  });

  test('rejects an unknown severity instead of creating an invalid entity', () {
    expect(
      () => ManagedAlertModel.fromJson({
        'id': 'alert-1',
        'municipalityId': 'municipality-1',
        'source': 'aemet',
        'severity': 'violeta',
        'phenomenon': 'Tormenta',
        'body': {'es': 'Precaución'},
        'startAt': '2026-08-10T10:00:00.000Z',
        'endAt': null,
        'forcesNotification': false,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
