import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/domain/repositories/auth_repository.dart';
import 'package:poblex_backoffice/features/auth/domain/usecases/auth_usecases.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/password_recovery_view_models.dart';

void main() {
  late _FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _FakeAuthRepository();
    getIt.registerFactory(() => ForgotManagerPassword(repository));
    getIt.registerFactory(() => ResetManagerPassword(repository));
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'forgot password exposes completion and prevents duplicate requests',
    () async {
      await container.read(forgotPasswordViewModelProvider.future);
      final notifier = container.read(forgotPasswordViewModelProvider.notifier);

      final first = notifier.submit('manager@test.es');
      final duplicate = notifier.submit('manager@test.es');

      expect(repository.forgotCalls, 1);
      repository.forgotResult.complete(const Success<void>(null));
      await Future.wait([first, duplicate]);

      expect(
        container.read(forgotPasswordViewModelProvider).value!.completed,
        isTrue,
      );
    },
  );

  test('reset password exposes typed repository failures', () async {
    const token = 'invalid-token';
    await container.read(resetPasswordViewModelProvider(token).future);
    repository.resetResponse = const Failure<void>(ValidationFailure());

    await container
        .read(resetPasswordViewModelProvider(token).notifier)
        .submit('new-password');

    expect(
      container.read(resetPasswordViewModelProvider(token)).error,
      isA<ValidationFailure>(),
    );
    expect(repository.resetToken, token);
  });
}

class _FakeAuthRepository implements AuthRepository {
  final forgotResult = Completer<Result<void>>();
  Result<void> resetResponse = const Success<void>(null);
  int forgotCalls = 0;
  String? resetToken;

  @override
  Future<Result<void>> forgotPassword(String email) {
    forgotCalls++;
    return forgotResult.future;
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    resetToken = token;
    return resetResponse;
  }

  @override
  Future<Result<ManagerProfile>> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<Result<ManagerProfile>> restoreSession() => throw UnimplementedError();
}
