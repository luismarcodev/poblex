import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/errors/failure.dart';
import 'package:poblex/core/network/dio_error_mapper.dart';

void main() {
  test('maps response transformation timeouts to a timeout failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/v1/news'),
      type: DioExceptionType.transformTimeout,
    );

    expect(mapDioError(error), const NetworkFailure(timedOut: true));
  });
}
