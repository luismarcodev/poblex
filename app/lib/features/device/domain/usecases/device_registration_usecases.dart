import '../../../../core/device/device_id_store.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/result/result.dart';
import '../repositories/device_registration_repository.dart';

class RegisterDevice {
  const RegisterDevice(this._repository, this._deviceIdStore);

  final DeviceRegistrationRepository _repository;
  final DeviceIdStore _deviceIdStore;

  Future<Result<String>> call({
    required String municipalityId,
    required AppLocale locale,
    String? fcmToken,
  }) async {
    final String deviceId = await _deviceIdStore.getOrCreate();
    final Result<void> result = await _repository.register(
      deviceId: deviceId,
      municipalityId: municipalityId,
      locale: locale.contentCode,
      fcmToken: fcmToken,
    );
    return switch (result) {
      Success<void>() => Success<String>(deviceId),
      Failed<void>(:final failure) => Failed<String>(failure),
    };
  }
}

class UpdateDevicePush {
  const UpdateDevicePush(this._repository);

  final DeviceRegistrationRepository _repository;

  Future<Result<void>> call({
    required String deviceId,
    required AppLocale locale,
    String? fcmToken,
  }) => _repository.updatePush(
    deviceId: deviceId,
    locale: locale.contentCode,
    fcmToken: fcmToken,
  );
}
