import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/repositories/device_registration_repository.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRegistrationRepositoryImpl implements DeviceRegistrationRepository {
  const DeviceRegistrationRepositoryImpl(this._remote);

  final DeviceRemoteDataSource _remote;

  @override
  Future<Result<void>> register({
    required String deviceId,
    required String municipalityId,
    required String locale,
    String? fcmToken,
  }) async {
    try {
      await _remote.register(
        deviceId: deviceId,
        municipalityId: municipalityId,
        locale: locale,
        fcmToken: fcmToken,
      );
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> updatePush({
    required String deviceId,
    required String locale,
    String? fcmToken,
  }) async {
    try {
      await _remote.updatePush(
        deviceId: deviceId,
        locale: locale,
        fcmToken: fcmToken,
      );
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }
}
