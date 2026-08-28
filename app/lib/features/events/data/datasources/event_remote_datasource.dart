import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/event_model.dart';

class EventRemoteDataSource {
  const EventRemoteDataSource(this._dio);
  final Dio _dio;

  Future<EventPageModel> list({
    required String municipalityId,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.events,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing event page');
    return EventPageModel.fromJson(data);
  }

  Future<EventModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.eventDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing event');
    return EventModel.fromJson(data);
  }

  Future<void> setReminder({
    required String eventId,
    required DateTime remindAt,
  }) async {
    await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.eventReminder(eventId),
          data: <String, dynamic>{'remindAt': remindAt.toIso8601String()},
        )
        .timeout(ApiConfig.timeout);
  }

  Future<void> cancelReminder(String eventId) async {
    await _dio
        .delete<void>(ApiEndpoints.eventReminder(eventId))
        .timeout(ApiConfig.timeout);
  }
}
