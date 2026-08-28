import 'package:dio/dio.dart';

import '../../domain/entities/managed_alert.dart';
import '../models/managed_alert_model.dart';

class AlertRemoteDataSource {
  const AlertRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ManagedAlertsPage> getManagedAlerts({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/alerts',
      queryParameters: {
        'municipalityId': municipalityId,
        'includeExpired': includeExpired,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing alerts page');
    final items = data['items'];
    if (items is! List<dynamic>) {
      throw const FormatException('Missing alert items');
    }
    return ManagedAlertsPage(
      items: items
          .map(
            (raw) =>
                ManagedAlertModel.fromJson(raw as Map<String, dynamic>).entity,
          )
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<ManagedAlert> getById({
    required String id,
    required String municipalityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/alerts/$id',
      queryParameters: {'municipalityId': municipalityId},
    );
    return _entity(response.data);
  }

  Future<ManagedAlert> create(SaveManualAlertInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/alerts',
      data: _payload(input, includeMunicipality: true, includeNullEnd: false),
    );
    return _entity(response.data);
  }

  Future<ManagedAlert> update(SaveManualAlertInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/alerts/${input.id}',
      data: _payload(input, includeMunicipality: false, includeNullEnd: true),
    );
    return _entity(response.data);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/alerts/$id');

  Map<String, dynamic> _payload(
    SaveManualAlertInput input, {
    required bool includeMunicipality,
    required bool includeNullEnd,
  }) => {
    if (includeMunicipality) 'municipalityId': input.municipalityId,
    'severity': input.severity.apiValue,
    'phenomenonType': input.phenomenonType.apiValue,
    'phenomenon': input.phenomenon.trim(),
    'body': input.body.toJson(),
    'startAt': input.startAt.toUtc().toIso8601String(),
    if (includeNullEnd || input.endAt != null)
      'endAt': input.endAt?.toUtc().toIso8601String(),
  };

  ManagedAlert _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing alert');
    return ManagedAlertModel.fromJson(data).entity;
  }
}
