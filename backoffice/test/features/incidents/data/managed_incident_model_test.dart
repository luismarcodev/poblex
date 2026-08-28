import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/incidents/data/models/managed_incident_model.dart';
import 'package:poblex_backoffice/features/incidents/domain/entities/managed_incident.dart';

void main() {
  test('maps the complete managed incident contract', () {
    final incident = ManagedIncidentModel.fromJson(_json).entity;

    expect(incident.id, 'incident-1');
    expect(incident.municipalityId, 'municipality-1');
    expect(incident.status, IncidentStatus.inProgress);
    expect(incident.photoUrl, 'https://cdn.example.test/photo.webp');
    expect(incident.latitude, 39.278);
    expect(incident.longitude, -0.382);
    expect(incident.createdAt.isUtc, isTrue);
    expect(incident.updatedAt.isUtc, isTrue);
  });

  test('rejects an unknown status', () {
    expect(
      () => ManagedIncidentModel.fromJson({..._json, 'status': 'cerrada'}),
      throwsFormatException,
    );
  });

  test('rejects incomplete coordinates', () {
    expect(
      () => ManagedIncidentModel.fromJson({..._json, 'lng': null}),
      throwsFormatException,
    );
  });
}

final Map<String, dynamic> _json = {
  'id': 'incident-1',
  'municipalityId': 'municipality-1',
  'category': 'alumbrado',
  'description': 'Farola apagada en la plaza.',
  'photoUrl': 'https://cdn.example.test/photo.webp',
  'lat': 39.278,
  'lng': -0.382,
  'status': 'en_curso',
  'createdAt': '2026-08-10T08:00:00.000Z',
  'updatedAt': '2026-08-10T09:00:00.000Z',
};
