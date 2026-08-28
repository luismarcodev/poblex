import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/auth_session.dart';
import '../../domain/entities/manager_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/password_reset_request_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._session);

  final AuthRemoteDataSource _remote;
  final AuthSession _session;

  @override
  Future<Result<ManagerProfile>> restoreSession() async {
    try {
      final token = await _remote.refresh();
      _session.updateAccessToken(token);
      final profile = (await _remote.profile()).profile;
      _session.authenticate(token, profile);
      return Success(profile);
    } catch (error) {
      _session.clear();
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagerProfile>> login(String email, String password) async {
    try {
      final token = await _remote.login(email, password);
      _session.updateAccessToken(token);
      final profile = (await _remote.profile()).profile;
      _session.authenticate(token, profile);
      return Success(profile);
    } catch (error) {
      _session.clear();
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      _session.clear();
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) => _capture(
    () => _remote.forgotPassword(ForgotPasswordRequestModel(email: email)),
  );

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    final result = await _capture(
      () => _remote.resetPassword(
        ResetPasswordRequestModel(token: token, newPassword: newPassword),
      ),
    );
    if (result is Success<void>) _session.clear();
    return result;
  }

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }
}
