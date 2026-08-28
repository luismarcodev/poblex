import 'package:dio/dio.dart';

import '../../domain/entities/managed_event.dart';
import '../models/managed_event_model.dart';

class EventRemoteDataSource {
  const EventRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ManagedEvent> getById({
    required String id,
    required String municipalityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/events/$id',
      queryParameters: {'municipalityId': municipalityId},
    );
    return _entity(response.data);
  }

  Future<ManagedEventsPage> getManagedEvents({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/events',
      queryParameters: {
        'municipalityId': municipalityId,
        'includePast': includePast,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing events page');
    final rawItems = data['items'] as List<dynamic>?;
    if (rawItems == null) throw const FormatException('Missing event items');
    return ManagedEventsPage(
      items: rawItems
          .map(
            (raw) =>
                ManagedEventModel.fromJson(raw as Map<String, dynamic>).entity,
          )
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<List<ManagedEvent>> create(SaveEventInput input) async {
    final response = await _dio.post<List<dynamic>>(
      '/admin/events',
      data: _payload(input, includeMunicipalities: true),
    );
    return (response.data ?? const [])
        .map(
          (raw) =>
              ManagedEventModel.fromJson(raw as Map<String, dynamic>).entity,
        )
        .toList(growable: false);
  }

  Future<ManagedEvent> update(SaveEventInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/events/${input.id}',
      data: _payload(input, includeMunicipalities: false),
    );
    return _entity(response.data);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/events/$id');

  Map<String, dynamic> _payload(
    SaveEventInput input, {
    required bool includeMunicipalities,
  }) => {
    if (includeMunicipalities) 'municipalityIds': input.municipalityIds,
    'title': input.title.toJson(),
    'description': input.description.toJson(),
    'startAt': input.startAt.toUtc().toIso8601String(),
    'endAt': input.endAt?.toUtc().toIso8601String(),
    'locationName': input.locationName,
    'lat': input.latitude,
    'lng': input.longitude,
    'category': input.category,
  };

  ManagedEvent _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing event');
    return ManagedEventModel.fromJson(data).entity;
  }
}
