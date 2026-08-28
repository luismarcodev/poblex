import 'package:dio/dio.dart';

import '../models/manager_profile_model.dart';
import '../models/password_reset_request_models.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<String> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/auth/login',
      data: {'email': email.trim(), 'password': password},
    );
    return _readToken(response.data);
  }

  Future<String> refresh() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/auth/refresh',
    );
    return _readToken(response.data);
  }

  Future<ManagerProfileModel> profile() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/me');
    final data = response.data;
    if (data == null) throw const FormatException('Missing manager profile');
    return ManagerProfileModel.fromJson(data);
  }

  Future<void> logout() => _dio.post<void>('/admin/auth/logout');

  Future<void> forgotPassword(ForgotPasswordRequestModel request) =>
      _dio.post<void>('/admin/auth/forgot-password', data: request.toJson());

  Future<void> resetPassword(ResetPasswordRequestModel request) =>
      _dio.post<void>('/admin/auth/reset-password', data: request.toJson());

  String _readToken(Map<String, dynamic>? data) {
    final token = data?['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Missing access token');
    }
    return token;
  }
}
