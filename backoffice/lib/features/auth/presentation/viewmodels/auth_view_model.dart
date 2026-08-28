import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/manager_profile.dart';
import '../../domain/usecases/auth_usecases.dart';

final authViewModelProvider =
    AsyncNotifierProvider<AuthViewModel, ManagerProfile?>(AuthViewModel.new);

class AuthViewModel extends AsyncNotifier<ManagerProfile?> {
  @override
  Future<ManagerProfile?> build() async {
    final result = await getIt<RestoreManagerSession>()();
    return switch (result) {
      Success(value: final profile) => profile,
      Failure() => null,
    };
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await getIt<LoginManager>()(email, password);
    state = switch (result) {
      Success(value: final profile) => AsyncData(profile),
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<void> logout() async {
    await getIt<LogoutManager>()();
    state = const AsyncData(null);
  }
}
