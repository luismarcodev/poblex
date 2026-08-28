import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/notifications/push_notification_service.dart';
import 'package:poblex/features/device/domain/repositories/device_registration_repository.dart';
import 'package:poblex/features/device/domain/usecases/device_registration_usecases.dart';
import 'package:poblex/features/device/domain/usecases/sync_device_push.dart';
import 'package:poblex/core/result/result.dart';

class _FakePushService implements PushNotificationService {
  _FakePushService({this.syncError, this.tokenError, this.tokenValue});

  final Object? syncError;
  final Object? tokenError;
  final String? tokenValue;

  String? lastSyncedMunicipality;
  AppLocale? lastSyncedLocale;

  @override
  Future<void> syncNewsTopic({
    required String municipalityId,
    required AppLocale locale,
  }) async {
    if (syncError != null) throw syncError!;
    lastSyncedMunicipality = municipalityId;
    lastSyncedLocale = locale;
  }

  @override
  Future<String?> token() async {
    if (tokenError != null) throw tokenError!;
    return tokenValue;
  }

  @override
  Stream<PushMessage> get foregroundMessages =>
      const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get openedMessages => const Stream<PushMessage>.empty();

  @override
  Stream<String> get tokenRefreshes => const Stream<String>.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<PushMessage?> takeInitialMessage() async => null;
}

class _RecordingDeviceRegistrationRepository
    implements DeviceRegistrationRepository {
  ({String deviceId, String locale, String? fcmToken})? lastUpdate;
  Object? updateError;

  @override
  Future<Result<void>> register({
    required String deviceId,
    required String municipalityId,
    required String locale,
    String? fcmToken,
  }) async => const Success<void>(null);

  @override
  Future<Result<void>> updatePush({
    required String deviceId,
    required String locale,
    String? fcmToken,
  }) async {
    if (updateError != null) throw updateError!;
    lastUpdate = (deviceId: deviceId, locale: locale, fcmToken: fcmToken);
    return const Success<void>(null);
  }
}

void main() {
  late _RecordingDeviceRegistrationRepository repository;

  setUp(() {
    repository = _RecordingDeviceRegistrationRepository();
  });

  test('subscribes the topic and forwards the resulting token', () async {
    final _FakePushService push = _FakePushService(tokenValue: 'token-1');
    final SyncDevicePush syncDevicePush = SyncDevicePush(
      push,
      UpdateDevicePush(repository),
    );

    await syncDevicePush(
      deviceId: 'device-1',
      municipalityId: 'municipality-1',
      locale: AppLocale.va,
    );

    expect(push.lastSyncedMunicipality, 'municipality-1');
    expect(push.lastSyncedLocale, AppLocale.va);
    expect(repository.lastUpdate?.deviceId, 'device-1');
    expect(repository.lastUpdate?.locale, 'va');
    expect(repository.lastUpdate?.fcmToken, 'token-1');
  });

  // The device's locale is what routes future targeted pushes and resolves
  // the {es, va} fallback — it must still reach the backend even when
  // Firebase itself is unreachable.
  test('still sends the locale update when the topic sync fails', () async {
    final _FakePushService push = _FakePushService(
      syncError: Exception('Firebase unavailable'),
    );
    final SyncDevicePush syncDevicePush = SyncDevicePush(
      push,
      UpdateDevicePush(repository),
    );

    await syncDevicePush(
      deviceId: 'device-1',
      municipalityId: 'municipality-1',
      locale: AppLocale.es,
    );

    expect(repository.lastUpdate?.deviceId, 'device-1');
    expect(repository.lastUpdate?.locale, 'es');
    // Omitted, not null-and-sent: the backend leaves a previously stored
    // token untouched instead of clearing it.
    expect(repository.lastUpdate?.fcmToken, isNull);
  });

  test('still sends the locale update when fetching the token fails', () async {
    final _FakePushService push = _FakePushService(
      tokenError: Exception('No token yet'),
    );
    final SyncDevicePush syncDevicePush = SyncDevicePush(
      push,
      UpdateDevicePush(repository),
    );

    await syncDevicePush(
      deviceId: 'device-1',
      municipalityId: 'municipality-1',
      locale: AppLocale.es,
    );

    expect(repository.lastUpdate?.locale, 'es');
    expect(repository.lastUpdate?.fcmToken, isNull);
  });

  // The whole point of this use case: none of push's failure modes may ever
  // surface as an app error. Registration/locale changes must never crash
  // because a background push sync hiccuped.
  test('never throws, even when the backend update itself fails', () async {
    final _FakePushService push = _FakePushService();
    repository.updateError = Exception('network drop');
    final SyncDevicePush syncDevicePush = SyncDevicePush(
      push,
      UpdateDevicePush(repository),
    );

    await syncDevicePush(
      deviceId: 'device-1',
      municipalityId: 'municipality-1',
      locale: AppLocale.es,
    );
    // No exception reached the test — that is the assertion.
  });
}
