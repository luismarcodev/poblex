import 'package:dio/dio.dart';

import '../../domain/entities/duty_pharmacy.dart';
import '../models/duty_pharmacy_model.dart';

class DutyPharmacyRemoteDataSource {
  const DutyPharmacyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<DutyPharmacy>> getInRange({
    required String municipalityId,
    required DateTime from,
    required int days,
  }) async {
    final day = formatDutyPharmacyDate(from);
    final response = await _dio.get<List<dynamic>>(
      '/pharmacies/duty',
      queryParameters: {
        'municipalityId': municipalityId,
        'from': '${day}T00:00:00.000Z',
        'days': days,
      },
    );
    return (response.data ?? const [])
        .map(
          (item) =>
              DutyPharmacyModel.fromJson(item as Map<String, dynamic>).entity,
        )
        .toList(growable: false);
  }

  Future<DutyPharmacy> upsert({
    required String municipalityId,
    required SaveDutyPharmacyInput input,
  }) async {
    final entity = DutyPharmacy(
      id: '',
      municipalityId: municipalityId,
      date: input.date,
      pharmacyName: input.pharmacyName,
      address: input.address,
      phone: input.phone,
      schedule: input.schedule,
    );
    final response = await _dio.put<Map<String, dynamic>>(
      '/admin/pharmacies/duty',
      data: DutyPharmacyModel(entity).toJson(municipalityId: municipalityId),
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing duty pharmacy');
    return DutyPharmacyModel.fromJson(data).entity;
  }
}
