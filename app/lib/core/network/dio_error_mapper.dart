import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// The single place in the app where a transport exception dies.
///
/// Outside `data/` there is no `try/catch` around infrastructure: repositories
/// call this and return a typed [AppFailure], so nothing above the data layer
/// ever sees a [DioException].
AppFailure mapDioError(Object error) {
  if (error is TimeoutException) {
    return const NetworkFailure(timedOut: true);
  }

  if (error is! DioException) {
    return const UnknownFailure();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkFailure(timedOut: true);

    case DioExceptionType.connectionError:
      return const NetworkFailure();

    case DioExceptionType.cancel:
      return const CancelledFailure();

    case DioExceptionType.badCertificate:
      return const NetworkFailure();

    case DioExceptionType.badResponse:
      return _mapResponse(error.response);

    case DioExceptionType.unknown:
      // A dropped socket surfaces here rather than as connectionError.
      return error.error is SocketException
          ? const NetworkFailure()
          : const UnknownFailure();
  }
}

/// The backend's `DomainExceptionFilter` answers `{statusCode, code, message}`,
/// so the domain `code` is the primary signal and the HTTP status is only the
/// fallback.
AppFailure _mapResponse(Response<dynamic>? response) {
  final int? status = response?.statusCode;
  final dynamic body = response?.data;

  String? code;
  String? message;
  if (body is Map<String, dynamic>) {
    final dynamic rawCode = body['code'];
    final dynamic rawMessage = body['message'];
    code = rawCode is String ? rawCode : null;
    message = rawMessage is String ? rawMessage : null;
  }

  switch (code) {
    case 'NOT_FOUND':
      return const NotFoundFailure();
    case 'VALIDATION_ERROR':
      return ValidationFailure(serverMessage: message);
    case 'FORBIDDEN':
      return const ForbiddenFailure();
    case 'UNAUTHORIZED':
      return const UnauthorizedFailure();
    case 'CONFLICT':
      return const ConflictFailure();
  }

  // 429 comes from the throttler guard, not from the domain filter, so it
  // never carries a `code`. It needs its own case: told "server error", the
  // user retries in a loop and makes the block worse.
  if (status == HttpStatus.tooManyRequests) {
    return const TooManyRequestsFailure();
  }
  if (status == HttpStatus.notFound) return const NotFoundFailure();
  if (status == HttpStatus.unauthorized) return const UnauthorizedFailure();
  if (status == HttpStatus.forbidden) return const ForbiddenFailure();
  if (status == HttpStatus.conflict) return const ConflictFailure();
  if (status != null && status >= 500) return ServerFailure(statusCode: status);
  if (status != null && status >= 400) {
    return ValidationFailure(serverMessage: message);
  }

  return const UnknownFailure();
}
