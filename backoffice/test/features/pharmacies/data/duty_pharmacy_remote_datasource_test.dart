import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/pharmacies/data/datasources/duty_pharmacy_remote_datasource.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';

void main() {
  test(
    'requests an exact monthly range without local timezone drift',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      late RequestOptions captured;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<List<dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: [_response],
              ),
            );
          },
        ),
      );

      final result = await DutyPharmacyRemoteDataSource(dio).getInRange(
        municipalityId: 'municipality-1',
        from: DateTime(2026, 8),
        days: 31,
      );

      expect(captured.path, '/pharmacies/duty');
      expect(captured.queryParameters, {
        'municipalityId': 'municipality-1',
        'from': '2026-08-01T00:00:00.000Z',
        'days': 31,
      });
      expect(result.single.id, 'pharmacy-1');
    },
  );

  test('uses the idempotent admin upsert contract', () async {
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

    await DutyPharmacyRemoteDataSource(dio).upsert(
      municipalityId: 'municipality-1',
      input: SaveDutyPharmacyInput(
        date: DateTime(2026, 8, 12),
        pharmacyName: 'Farmacia Ribera',
        address: 'Carrer Major, 12',
        phone: '961 234 567',
        schedule: '9:00 - 22:00',
        municipalityIds: const ['municipality-1'],
      ),
    );

    expect(captured.method, 'PUT');
    expect(captured.path, '/admin/pharmacies/duty');
    expect(captured.data['date'], '2026-08-12');
    expect(captured.data['municipalityId'], 'municipality-1');
  });
}

final Map<String, dynamic> _response = {
  'id': 'pharmacy-1',
  'municipalityId': 'municipality-1',
  'date': '2026-08-12',
  'pharmacyName': 'Farmacia Ribera',
  'address': 'Carrer Major, 12',
  'phone': '961 234 567',
  'schedule': '9:00 - 22:00',
};
