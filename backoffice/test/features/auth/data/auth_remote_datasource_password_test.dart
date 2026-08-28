import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/session/auth_session.dart';
import 'package:poblex_backoffice/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:poblex_backoffice/features/auth/data/models/password_reset_request_models.dart';
import 'package:poblex_backoffice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';

void main() {
  test('sends the forgot-password request with a trimmed email', () async {
    final requests = <RequestOptions>[];
    final dataSource = AuthRemoteDataSource(_dioCapturing(requests));

    await dataSource.forgotPassword(
      const ForgotPasswordRequestModel(email: '  gestor@sollana.es  '),
    );

    expect(requests.single.path, '/admin/auth/forgot-password');
    expect(requests.single.data, {'email': 'gestor@sollana.es'});
  });

  test(
    'sends the reset token and password using the backend contract',
    () async {
      final requests = <RequestOptions>[];
      final dataSource = AuthRemoteDataSource(_dioCapturing(requests));

      await dataSource.resetPassword(
        const ResetPasswordRequestModel(
          token: '  reset-token  ',
          newPassword: 'new-password',
        ),
      );

      expect(requests.single.path, '/admin/auth/reset-password');
      expect(requests.single.data, {
        'token': 'reset-token',
        'newPassword': 'new-password',
      });
    },
  );

  test('clears the local session after a successful password reset', () async {
    final session = AuthSession();
    addTearDown(session.dispose);
    session.authenticate(
      'access-token',
      const ManagerProfile(
        id: 'manager-1',
        email: 'gestor@sollana.es',
        displayName: 'Gestor',
        municipalities: [],
      ),
    );
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(_dioCapturing([])),
      session,
    );

    final result = await repository.resetPassword(
      'reset-token',
      'new-password',
    );

    expect(result.isSuccess, isTrue);
    expect(session.status, AuthStatus.unauthenticated);
    expect(session.accessToken, isNull);
  });
}

Dio _dioCapturing(List<RequestOptions> requests) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response<void>(requestOptions: options, statusCode: 200),
        );
      },
    ),
  );
  return dio;
}
