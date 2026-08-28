import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../domain/usecases/auth_usecases.dart';

class PasswordRecoveryUiState extends Equatable {
  const PasswordRecoveryUiState({this.completed = false});

  final bool completed;

  @override
  List<Object?> get props => [completed];
}

final forgotPasswordViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      ForgotPasswordViewModel,
      PasswordRecoveryUiState
    >(ForgotPasswordViewModel.new);

class ForgotPasswordViewModel
    extends AutoDisposeAsyncNotifier<PasswordRecoveryUiState> {
  bool _isSubmitting = false;

  @override
  PasswordRecoveryUiState build() => const PasswordRecoveryUiState();

  Future<void> submit(String email) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    state = const AsyncLoading();

    final result = await getIt<ForgotManagerPassword>()(email);
    state = switch (result) {
      Success<void>() => const AsyncData(
        PasswordRecoveryUiState(completed: true),
      ),
      Failure<void>(error: final error) => AsyncError(
        error,
        StackTrace.current,
      ),
    };
    _isSubmitting = false;
  }
}

final resetPasswordViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ResetPasswordViewModel, PasswordRecoveryUiState, String>(
      ResetPasswordViewModel.new,
    );

class ResetPasswordViewModel
    extends AutoDisposeFamilyAsyncNotifier<PasswordRecoveryUiState, String> {
  bool _isSubmitting = false;

  @override
  PasswordRecoveryUiState build(String arg) => const PasswordRecoveryUiState();

  Future<void> submit(String newPassword) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    state = const AsyncLoading();

    final result = await getIt<ResetManagerPassword>()(arg, newPassword);
    state = switch (result) {
      Success<void>() => const AsyncData(
        PasswordRecoveryUiState(completed: true),
      ),
      Failure<void>(error: final error) => AsyncError(
        error,
        StackTrace.current,
      ),
    };
    _isSubmitting = false;
  }
}
