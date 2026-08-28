import '../../../../core/result/result.dart';
import '../entities/manager_profile.dart';
import '../repositories/auth_repository.dart';

const minimumManagerPasswordLength = 8;

class RestoreManagerSession {
  const RestoreManagerSession(this._repository);
  final AuthRepository _repository;
  Future<Result<ManagerProfile>> call() => _repository.restoreSession();
}

class LoginManager {
  const LoginManager(this._repository);
  final AuthRepository _repository;
  Future<Result<ManagerProfile>> call(String email, String password) =>
      _repository.login(email, password);
}

class LogoutManager {
  const LogoutManager(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.logout();
}

class ForgotManagerPassword {
  const ForgotManagerPassword(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) => _repository.forgotPassword(email);
}

class ResetManagerPassword {
  const ResetManagerPassword(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String token, String newPassword) =>
      _repository.resetPassword(token, newPassword);
}
