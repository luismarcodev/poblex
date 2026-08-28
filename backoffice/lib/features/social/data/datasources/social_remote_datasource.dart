import 'package:dio/dio.dart';

import '../models/social_account_model.dart';

class SocialRemoteDataSource {
  SocialRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<SocialAccountModel>> listAccounts(String municipalityId) async {
    // El backend devuelve el array directamente, no envuelto en un objeto.
    final response = await _dio.get<List<dynamic>>(
      '/admin/social-accounts',
      queryParameters: {'municipalityId': municipalityId},
    );
    final raw = response.data ?? const [];
    return raw
        .map(
          (item) => SocialAccountModel.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<String> startOAuth({
    required String municipalityId,
    required String platform,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/social-accounts/$platform/connect',
      data: {'municipalityId': municipalityId},
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing authorizeUrl');
    return data['authorizeUrl'] as String;
  }

  Future<void> disconnect(String id) =>
      _dio.delete<void>('/admin/social-accounts/$id');
}
