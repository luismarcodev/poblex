import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/news_item_model.dart';

class NewsRemoteDataSource {
  const NewsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<NewsPageModel> list({
    required String municipalityId,
    required bool archived,
    String? category,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          archived ? ApiEndpoints.newsArchive : ApiEndpoints.news,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'category': ?category,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        // Dio's own connect/receive timeouts don't bound the TOTAL request
        // time if the server trickles bytes slowly. This is the hard A-39
        // ceiling: no screen may spin forever.
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing news page');
    return NewsPageModel.fromJson(data);
  }

  Future<List<String>> categories(String municipalityId) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.newsCategories,
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final dynamic raw = response.data?['categories'];
    return raw is List<dynamic>
        ? raw.whereType<String>().toList(growable: false)
        : const <String>[];
  }

  Future<NewsItemModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.newsDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing news item');
    return NewsItemModel.fromJson(data);
  }
}
