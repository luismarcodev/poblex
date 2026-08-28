import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/incidents/data/datasources/incident_remote_datasource.dart';
import 'package:poblex_backoffice/features/incidents/domain/entities/managed_incident.dart';

void main() {
  test('serializes filters and cursor in the managed list request', () async {
    final requests = <RequestOptions>[];
    final dio = _dio((options) {
      requests.add(options);
      return {
        'items': [_json],
        'nextCursor': 'next-page',
      };
    });

    final page = await IncidentRemoteDataSource(dio).getManagedIncidents(
      municipalityId: 'municipality-1',
      status: IncidentStatus.inProgress,
      category: 'alumbrado',
      cursor: 'cursor-1',
    );

    expect(requests.single.path, '/admin/incidents');
    expect(requests.single.queryParameters, {
      'municipalityId': 'municipality-1',
      'limit': 20,
      'status': 'en_curso',
      'category': 'alumbrado',
      'cursor': 'cursor-1',
    });
    expect(page.items.single.id, 'incident-1');
    expect(page.nextCursor, 'next-page');
  });

  test('sends the status and optional trimmed note contract', () async {
    late RequestOptions request;
    final dio = _dio((options) {
      request = options;
      return {..._json, 'status': 'resuelta'};
    });

    await IncidentRemoteDataSource(dio).changeStatus(
      ChangeIncidentStatusInput(
        incident: _incident,
        status: IncidentStatus.resolved,
        note: 'Reparada',
      ),
    );

    expect(request.path, '/admin/incidents/incident-1/status');
    expect(request.method, 'PATCH');
    expect(request.data, {'status': 'resuelta', 'note': 'Reparada'});
  });

  test('omits an absent note from the mutation payload', () async {
    late RequestOptions request;
    final dio = _dio((options) {
      request = options;
      return {..._json, 'status': 'resuelta'};
    });

    await IncidentRemoteDataSource(dio).changeStatus(
      ChangeIncidentStatusInput(
        incident: _incident,
        status: IncidentStatus.resolved,
      ),
    );

    expect(request.data, {'status': 'resuelta'});
  });
}

Dio _dio(Map<String, dynamic> Function(RequestOptions) response) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: response(options),
        ),
      ),
    ),
  );
  return dio;
}

final ManagedIncident _incident = ManagedIncident(
  id: 'incident-1',
  municipalityId: 'municipality-1',
  category: 'alumbrado',
  description: 'Farola apagada en la plaza.',
  status: IncidentStatus.inProgress,
  createdAt: DateTime.utc(2026, 8, 10, 8),
  updatedAt: DateTime.utc(2026, 8, 10, 9),
);

final Map<String, dynamic> _json = {
  'id': 'incident-1',
  'municipalityId': 'municipality-1',
  'category': 'alumbrado',
  'description': 'Farola apagada en la plaza.',
  'photoUrl': null,
  'lat': null,
  'lng': null,
  'status': 'en_curso',
  'createdAt': '2026-08-10T08:00:00.000Z',
  'updatedAt': '2026-08-10T09:00:00.000Z',
};
