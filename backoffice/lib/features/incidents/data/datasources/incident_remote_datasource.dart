import 'package:dio/dio.dart';

import '../../domain/entities/managed_incident.dart';
import '../models/managed_incident_model.dart';

class IncidentRemoteDataSource {
  const IncidentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ManagedIncidentsPage> getManagedIncidents({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/incidents',
      queryParameters: {
        'municipalityId': municipalityId,
        'limit': 20,
        'status': ?status?.apiValue,
        'category': ?category,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing incidents page');
    final rawItems = data['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Missing incident items');
    }
    return ManagedIncidentsPage(
      items: rawItems
          .map(
            (raw) => ManagedIncidentModel.fromJson(
              raw as Map<String, dynamic>,
            ).entity,
          )
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<ManagedIncident> changeStatus(ChangeIncidentStatusInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/incidents/${input.incident.id}/status',
      data: {
        'status': input.status.apiValue,
        if (input.note != null) 'note': input.note,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing incident');
    return ManagedIncidentModel.fromJson(data).entity;
  }

  Future<List<String>> getCategories(String municipalityId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/incidents/categories',
      queryParameters: {'municipalityId': municipalityId},
    );
    final data = response.data;
    final categories = data?['categories'];
    if (categories is! List<dynamic>) {
      throw const FormatException('Missing incident categories');
    }
    return categories.cast<String>();
  }

  Future<List<IncidentStatusChange>> getHistory(String incidentId) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/incidents/$incidentId/history',
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing incident history');
    return data
        .map(
          (raw) => IncidentStatusChangeModel.fromJson(
            raw as Map<String, dynamic>,
          ).entity,
        )
        .toList(growable: false);
  }
}
