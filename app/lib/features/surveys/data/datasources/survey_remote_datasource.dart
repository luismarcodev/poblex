import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/survey_model.dart';

class SurveyRemoteDataSource {
  const SurveyRemoteDataSource(this._dio);
  final Dio _dio;

  Future<SurveyPageModel> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.surveys,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'includeClosed': includeClosed,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing survey page');
    return SurveyPageModel.fromJson(data);
  }

  Future<SurveyModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.surveyDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing survey');
    return SurveyModel.fromJson(data);
  }

  Future<void> vote({
    required String surveyId,
    required String optionId,
  }) async {
    await _dio
        .post<void>(
          ApiEndpoints.surveyVote(surveyId),
          data: <String, dynamic>{'optionId': optionId},
        )
        .timeout(ApiConfig.timeout);
  }
}
