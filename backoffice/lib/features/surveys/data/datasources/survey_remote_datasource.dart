import 'package:dio/dio.dart';

import '../../domain/entities/managed_survey.dart';
import '../models/managed_survey_model.dart';

class SurveyRemoteDataSource {
  const SurveyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ManagedSurveysPage> getSurveys({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/surveys',
      queryParameters: {
        'municipalityId': municipalityId,
        'includeClosed': includeClosed,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing surveys page');
    final rawItems = data['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Missing survey items');
    }
    return ManagedSurveysPage(
      items: rawItems
          .map((raw) {
            if (raw is! Map<String, dynamic>) {
              throw const FormatException('Invalid survey item');
            }
            return ManagedSurveyModel.fromJson(raw).entity;
          })
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<ManagedSurvey> getDetail({
    required String id,
    required String municipalityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/surveys/$id',
      queryParameters: {'municipalityId': municipalityId},
    );
    return _entity(response.data);
  }

  Future<ManagedSurvey> create(CreateSurveyInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/surveys',
      data: {
        'municipalityId': input.municipalityId,
        'question': input.question.toJson(),
        'closesAt': input.closesAt.toUtc().toIso8601String(),
        'resultsVisible': input.resultsVisible,
        'options': input.options.map((option) => option.toJson()).toList(),
      },
    );
    return _entity(response.data);
  }

  Future<ManagedSurvey> close(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/surveys/$id/close',
    );
    return _entity(response.data);
  }

  Future<ManagedSurvey> setResultsVisibility(String id, bool visible) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/surveys/$id/results-visibility',
      data: {'visible': visible},
    );
    return _entity(response.data);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/surveys/$id');

  Future<String> exportResultsCsv(String id) async {
    final response = await _dio.get<String>(
      '/admin/surveys/$id/results.csv',
      options: Options(responseType: ResponseType.plain),
    );
    final csv = response.data;
    if (csv == null) throw const FormatException('Missing survey CSV');
    return csv;
  }

  ManagedSurvey _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing survey');
    return ManagedSurveyModel.fromJson(data).entity;
  }
}
