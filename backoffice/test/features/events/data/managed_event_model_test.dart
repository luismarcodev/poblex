import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/events/data/models/managed_event_model.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';

void main() {
  test('maps the complete managed event contract', () {
    final model = ManagedEventModel.fromJson({
      'id': 'event-1',
      'municipalityId': 'municipality-1',
      'title': {'es': 'Feria', 'va': 'Fira'},
      'description': {'es': 'En la plaza', 'va': 'A la plaça'},
      'startAt': '2026-08-12T10:00:00.000Z',
      'endAt': '2026-08-12T12:00:00.000Z',
      'locationName': 'Plaça Major',
      'lat': 39.278,
      'lng': -0.382,
      'category': 'cultura',
    });

    expect(model.entity.title.va, 'Fira');
    expect(model.entity.description.es, 'En la plaza');
    expect(model.entity.startAt.isUtc, isTrue);
    expect(model.entity.endAt?.isUtc, isTrue);
    expect(model.entity.latitude, 39.278);
    expect(model.entity.longitude, -0.382);
    expect(
      model.entity.statusAt(DateTime.utc(2026, 8, 12, 11)),
      ManagedEventStatus.ongoing,
    );
  });

  test('treats an event without an end as past after its start', () {
    final event = ManagedEventModel.fromJson({
      'id': 'event-1',
      'municipalityId': 'municipality-1',
      'title': {'es': 'Feria'},
      'description': {'es': 'En la plaza'},
      'startAt': '2026-08-12T10:00:00.000Z',
      'endAt': null,
      'locationName': null,
      'lat': null,
      'lng': null,
      'category': 'cultura',
    }).entity;

    expect(
      event.statusAt(DateTime.utc(2026, 8, 12, 10, 1)),
      ManagedEventStatus.past,
    );
  });
}
