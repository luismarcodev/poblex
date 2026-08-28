import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/events/data/datasources/event_remote_datasource.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';

void main() {
  test(
    'serializes nullable fields explicitly when updating an event',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      late RequestOptions captured;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _response,
              ),
            );
          },
        ),
      );

      await EventRemoteDataSource(dio).update(_input);

      expect(captured.path, '/admin/events/event-1');
      expect(captured.data, containsPair('endAt', null));
      expect(captured.data, containsPair('locationName', null));
      expect(captured.data, containsPair('lat', null));
      expect(captured.data, containsPair('lng', null));
      expect(captured.data, isNot(contains('municipalityIds')));
      expect(captured.data['startAt'], '2026-08-12T10:00:00.000Z');
    },
  );

  test('uses the public detail contract with municipality isolation', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: _response,
            ),
          );
        },
      ),
    );

    await EventRemoteDataSource(
      dio,
    ).getById(id: 'event-1', municipalityId: 'municipality-1');

    expect(captured.path, '/events/event-1');
    expect(captured.queryParameters['municipalityId'], 'municipality-1');
  });
}

final SaveEventInput _input = SaveEventInput(
  id: 'event-1',
  title: const EventLocalizedText(es: 'Feria'),
  description: const EventLocalizedText(es: 'En la plaza'),
  startAt: DateTime.utc(2026, 8, 12, 10),
  category: 'cultura',
  municipalityIds: const ['municipality-1'],
);

final Map<String, dynamic> _response = {
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
};
