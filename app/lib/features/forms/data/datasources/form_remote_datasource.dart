import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/form_model.dart';

class FormRemoteDataSource {
  const FormRemoteDataSource(this._dio);
  final Dio _dio;

  Future<FormPageModel> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.forms,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'includeClosed': includeClosed,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing form page');
    return FormPageModel.fromJson(data);
  }

  Future<FormModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.formDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing form');
    return FormModel.fromJson(data);
  }

  Future<void> submit({
    required String formId,
    required Map<String, String> answers,
  }) async {
    await _dio
        .post<void>(
          ApiEndpoints.formSubmissions(formId),
          data: <String, dynamic>{
            'answers': <Map<String, String>>[
              for (final MapEntry<String, String> answer in answers.entries)
                <String, String>{'fieldId': answer.key, 'value': answer.value},
            ],
          },
        )
        .timeout(ApiConfig.timeout);
  }
}
