import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';

void main() {
  test('uses the public paginated list contract', () async {
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
              data: {
                'items': [_response],
                'nextCursor': 'next',
              },
            ),
          );
        },
      ),
    );

    final page = await AlertRemoteDataSource(dio).getManagedAlerts(
      municipalityId: 'municipality-1',
      includeExpired: true,
      cursor: 'cursor',
    );

    expect(captured.path, '/alerts');
    expect(captured.queryParameters, {
      'municipalityId': 'municipality-1',
      'includeExpired': true,
      'limit': 20,
      'cursor': 'cursor',
    });
    expect(page.items.single.id, 'alert-1');
    expect(page.nextCursor, 'next');
  });

  test('creates one manual alert for the selected municipality', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: _response,
            ),
          );
        },
      ),
    );

    await AlertRemoteDataSource(dio).create(_input());

    expect(captured.path, '/admin/alerts');
    expect(captured.data, containsPair('municipalityId', 'municipality-1'));
    expect(captured.data, containsPair('severity', 'rojo'));
    expect(captured.data, isNot(contains('endAt')));
  });

  test('sends an explicit null when removing the end date', () async {
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

    await AlertRemoteDataSource(dio).update(_input(id: 'alert-1'));

    expect(captured.path, '/admin/alerts/alert-1');
    expect(captured.data, containsPair('endAt', null));
    expect(captured.data, isNot(contains('municipalityId')));
  });
}

SaveManualAlertInput _input({String? id}) => SaveManualAlertInput(
  id: id,
  municipalityId: 'municipality-1',
  severity: ManagedAlertSeverity.red,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Inundación',
  body: const AlertLocalizedText(es: 'Evita la zona'),
  startAt: DateTime.utc(2026, 8, 10, 10),
);

final Map<String, dynamic> _response = {
  'id': 'alert-1',
  'municipalityId': 'municipality-1',
  'source': 'manual',
  'severity': 'rojo',
  'phenomenonType': 'meteorologico',
  'phenomenon': 'Inundación',
  'body': {'es': 'Evita la zona'},
  'startAt': '2026-08-10T10:00:00.000Z',
  'endAt': null,
  'forcesNotification': true,
};
