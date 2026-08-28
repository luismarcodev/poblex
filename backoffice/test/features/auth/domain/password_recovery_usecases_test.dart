import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/domain/repositories/auth_repository.dart';
import 'package:poblex_backoffice/features/auth/domain/usecases/auth_usecases.dart';

void main() {
  test('ForgotManagerPassword delegates to the repository', () async {
    final repository = _FakeAuthRepository();

    final result = await ForgotManagerPassword(repository)('manager@test.es');

    expect(result, isA<Success<void>>());
    expect(repository.forgotEmail, 'manager@test.es');
  });

  test('ResetManagerPassword delegates token and password', () async {
    final repository = _FakeAuthRepository();

    final result = await ResetManagerPassword(repository)(
      'reset-token',
      'new-password',
    );

    expect(result, isA<Success<void>>());
    expect(repository.resetToken, 'reset-token');
    expect(repository.newPassword, 'new-password');
    expect(minimumManagerPasswordLength, 8);
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? forgotEmail;
  String? resetToken;
  String? newPassword;

  @override
  Future<Result<void>> forgotPassword(String email) async {
    forgotEmail = email;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    resetToken = token;
    this.newPassword = newPassword;
    return const Success<void>(null);
  }

  @override
  Future<Result<ManagerProfile>> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<Result<ManagerProfile>> restoreSession() => throw UnimplementedError();
}
