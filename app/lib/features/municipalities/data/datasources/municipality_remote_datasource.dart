import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/municipality_model.dart';

class MunicipalityRemoteDataSource {
  const MunicipalityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MunicipalityModel>> listActive() async {
    final Response<List<dynamic>> response = await _dio
        .get<List<dynamic>>(ApiEndpoints.municipalities)
        .timeout(ApiConfig.timeout);
    return (response.data ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(MunicipalityModel.fromJson)
        .toList(growable: false);
  }
}
