import 'package:dio/dio.dart';

import '../../domain/entities/managed_form.dart';
import '../models/managed_form_model.dart';

class FormRemoteDataSource {
  const FormRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ManagedFormsPage> getForms({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/forms',
      queryParameters: {
        'municipalityId': municipalityId,
        'includeClosed': includeClosed,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    final rawItems = data?['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Missing forms page');
    }
    return ManagedFormsPage(
      items: rawItems
          .map((raw) {
            if (raw is! Map<String, dynamic>) {
              throw const FormatException('Invalid form item');
            }
            return ManagedFormModel.fromJson(raw).entity;
          })
          .toList(growable: false),
      nextCursor: data?['nextCursor'] as String?,
    );
  }

  Future<ManagedForm> getDetail({
    required String id,
    required String municipalityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/forms/$id',
      queryParameters: {'municipalityId': municipalityId},
    );
    return _entity(response.data);
  }

  Future<ManagedForm> create(CreateFormInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/forms',
      data: {
        'municipalityId': input.municipalityId,
        'title': input.title.toJson(),
        'description': input.description.toJson(),
        if (input.deadline != null)
          'deadline': input.deadline!.toUtc().toIso8601String(),
        'fields': input.fields.map((field) => field.toJson()).toList(),
      },
    );
    return _entity(response.data);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/forms/$id');

  Future<String> exportSubmissionsCsv(String id) async {
    final response = await _dio.get<String>(
      '/admin/forms/$id/submissions.csv',
      options: Options(responseType: ResponseType.plain),
    );
    final csv = response.data;
    if (csv == null) throw const FormatException('Missing submissions CSV');
    return csv;
  }

  ManagedForm _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing form');
    return ManagedFormModel.fromJson(data).entity;
  }
}
