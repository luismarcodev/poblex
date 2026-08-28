import '../../../../core/l10n/app_locales.dart';
import '../../../../core/notifications/push_notification_service.dart';
import 'device_registration_usecases.dart';

/// Subscribes the device to its municipality's news topic in [locale] and
/// pushes whatever FCM token results to the backend, together with the
/// locale itself.
///
/// This is the single place that owns the "push is best-effort" policy:
/// denying the OS notification permission, or Firebase being unreachable,
/// must never block choosing a municipality, reading content, or switching
/// language. Every failure here — topic sync, token retrieval, or the
/// backend update itself — is swallowed. The device already carries a
/// locale from its last successful registration or sync, and
/// `SessionViewModel.build()` retries the whole thing on next launch, so a
/// dropped connection here is never user-visible as an error.
class SyncDevicePush {
  const SyncDevicePush(this._push, this._updateDevicePush);

  final PushNotificationService _push;
  final UpdateDevicePush _updateDevicePush;

  Future<void> call({
    required String deviceId,
    required String municipalityId,
    required AppLocale locale,
  }) async {
    try {
      String? fcmToken;
      try {
        await _push.syncNewsTopic(
          municipalityId: municipalityId,
          locale: locale,
        );
        fcmToken = await _push.token();
      } on Object {
        // Firebase unreachable, permission denied, etc. A null token below
        // is omitted from the request body, leaving any previously stored
        // token untouched server-side rather than clearing it.
      }
      await _updateDevicePush(
        deviceId: deviceId,
        locale: locale,
        fcmToken: fcmToken,
      );
    } on Object {
      // The backend update itself failed too (e.g. no connectivity right as
      // the user tapped). Still best-effort — never let a push hiccup
      // surface as an app error.
    }
  }
}
