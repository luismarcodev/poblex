import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

AppFailure mapApiError(Object error) {
  if (error is! DioException) return const UnknownFailure();
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.transformTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const NetworkFailure();
  }

  final status = error.response?.statusCode;
  final data = error.response?.data;
  final message = data is Map<String, dynamic> && data['message'] is String
      ? data['message'] as String
      : null;
  if (status == null) return UnknownFailure(message: message);
  return switch (status) {
    401 => UnauthorizedFailure(message: message),
    404 => NotFoundFailure(message: message),
    409 => ConflictFailure(message: message),
    >= 400 && < 500 => ValidationFailure(message: message),
    >= 500 => ServerFailure(message: message),
    _ => UnknownFailure(message: message),
  };
}
