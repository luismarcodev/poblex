import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/incident_model.dart';

class IncidentRemoteDataSource {
  const IncidentRemoteDataSource(this._dio);
  final Dio _dio;

  Future<IncidentModel> report({
    required String municipalityId,
    required String category,
    required String description,
    double? lat,
    double? lng,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.incidents,
          data: <String, dynamic>{
            'municipalityId': municipalityId,
            'category': category,
            'description': description,
            'lat': ?lat,
            'lng': ?lng,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing incident');
    return IncidentModel.fromJson(data);
  }

  Future<IncidentModel> uploadPhoto({
    required String incidentId,
    required List<int> bytes,
    required String filename,
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.incidentPhoto(incidentId),
          data: form,
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing incident');
    return IncidentModel.fromJson(data);
  }

  Future<IncidentPageModel> listMine({String? cursor}) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.incidents,
          queryParameters: <String, dynamic>{'cursor': ?cursor, 'limit': 20},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing incident page');
    return IncidentPageModel.fromJson(data);
  }

  Future<IncidentDetailModel> detail(String id) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.incidentDetail(id))
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing incident');
    return IncidentDetailModel.fromJson(data);
  }
}
