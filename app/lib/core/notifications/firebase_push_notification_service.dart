import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locales.dart';
import 'push_notification_service.dart';

const String _lastNewsTopicKey = 'poblex_last_news_topic';

class FirebasePushNotificationService implements PushNotificationService {
  FirebasePushNotificationService(this._messaging, this._preferences);

  final FirebaseMessaging _messaging;
  final SharedPreferences _preferences;
  final StreamController<PushMessage> _foreground =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _opened =
      StreamController<PushMessage>.broadcast();

  PushMessage? _initialMessage;

  @override
  Stream<PushMessage> get foregroundMessages => _foreground.stream;

  @override
  Stream<PushMessage> get openedMessages => _opened.stream;

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Future<void> initialize() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      // Foreground messages use the accessible in-app banner. Enabling the
      // native alert too would duplicate every notification on iOS.
      alert: false,
      badge: true,
      sound: true,
    );

    _initialMessage = _toPushMessage(await _messaging.getInitialMessage());
    FirebaseMessaging.onMessage
        .map(_toPushMessage)
        .where((PushMessage? message) => message != null)
        .cast<PushMessage>()
        .listen(_foreground.add);
    FirebaseMessaging.onMessageOpenedApp
        .map(_toPushMessage)
        .where((PushMessage? message) => message != null)
        .cast<PushMessage>()
        .listen(_opened.add);
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Future<PushMessage?> takeInitialMessage() async {
    final PushMessage? message = _initialMessage;
    _initialMessage = null;
    return message;
  }

  @override
  Future<void> syncNewsTopic({
    required String municipalityId,
    required AppLocale locale,
  }) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final String nextTopic = newsNotificationTopic(municipalityId, locale);
    final String? previousTopic = _preferences.getString(_lastNewsTopicKey);
    if (previousTopic == nextTopic) return;

    if (previousTopic != null && previousTopic.isNotEmpty) {
      await _messaging.unsubscribeFromTopic(previousTopic);
    }
    await _messaging.subscribeToTopic(nextTopic);
    await _preferences.setString(_lastNewsTopicKey, nextTopic);
  }

  PushMessage? _toPushMessage(RemoteMessage? message) {
    if (message == null) return null;
    final String? type = message.data['type'];
    final String? itemId = message.data['id'];
    if (type == null || itemId == null) return null;
    return PushMessage(
      type: type,
      itemId: itemId,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      municipalityId: message.data['municipalityId'],
    );
  }
}

class DisabledPushNotificationService implements PushNotificationService {
  const DisabledPushNotificationService();

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
  Future<void> syncNewsTopic({
    required String municipalityId,
    required AppLocale locale,
  }) async {}

  @override
  Future<PushMessage?> takeInitialMessage() async => null;

  @override
  Future<String?> token() async => null;
}
