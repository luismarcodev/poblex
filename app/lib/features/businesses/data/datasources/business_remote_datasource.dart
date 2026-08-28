import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/business_model.dart';

class BusinessRemoteDataSource {
  const BusinessRemoteDataSource(this._dio);
  final Dio _dio;

  Future<BusinessPageModel> list({
    required String municipalityId,
    String? category,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.businesses,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'category': ?category,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing business page');
    return BusinessPageModel.fromJson(data);
  }

  Future<List<String>> categories(String municipalityId) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.businessesCategories,
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final dynamic categories = response.data?['categories'];
    return categories is List<dynamic>
        ? categories.whereType<String>().toList(growable: false)
        : const <String>[];
  }

  Future<BusinessModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.businessDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing business');
    return BusinessModel.fromJson(data);
  }
}
