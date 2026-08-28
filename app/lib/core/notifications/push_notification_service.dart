import '../l10n/app_locales.dart';

class PushMessage {
  const PushMessage({
    required this.type,
    required this.itemId,
    required this.title,
    required this.body,
    this.municipalityId,
  });

  final String type;
  final String itemId;
  final String title;
  final String body;
  final String? municipalityId;
}

abstract interface class PushNotificationService {
  Stream<PushMessage> get foregroundMessages;
  Stream<PushMessage> get openedMessages;
  Stream<String> get tokenRefreshes;

  Future<void> initialize();
  Future<String?> token();
  Future<PushMessage?> takeInitialMessage();

  Future<void> syncNewsTopic({
    required String municipalityId,
    required AppLocale locale,
  });
}

String newsNotificationTopic(String municipalityId, AppLocale locale) =>
    'm_${municipalityId}_news_${locale.contentCode}';

bool notificationBelongsToMunicipality(
  PushMessage message,
  String? activeMunicipalityId,
) =>
    message.municipalityId == null ||
    message.municipalityId == activeMunicipalityId;
