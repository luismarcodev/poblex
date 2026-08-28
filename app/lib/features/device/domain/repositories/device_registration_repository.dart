import '../../../../core/result/result.dart';

abstract interface class DeviceRegistrationRepository {
  Future<Result<void>> register({
    required String deviceId,
    required String municipalityId,
    required String locale,
    String? fcmToken,
  });

  Future<Result<void>> updatePush({
    required String deviceId,
    required String locale,
    String? fcmToken,
  });
}
