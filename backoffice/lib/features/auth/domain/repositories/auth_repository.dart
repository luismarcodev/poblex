import '../../../../core/result/result.dart';
import '../entities/manager_profile.dart';

abstract interface class AuthRepository {
  Future<Result<ManagerProfile>> restoreSession();
  Future<Result<ManagerProfile>> login(String email, String password);
  Future<Result<void>> forgotPassword(String email);
  Future<Result<void>> resetPassword(String token, String newPassword);
  Future<void> logout();
}
