import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/notifications/push_notification_service.dart';

void main() {
  test('builds the exact backend news topic for each language', () {
    const String municipalityId = 'e517f238-4f73-4ed9-806e-65a156aba257';

    expect(
      newsNotificationTopic(municipalityId, AppLocale.es),
      'm_${municipalityId}_news_es',
    );
    expect(
      newsNotificationTopic(municipalityId, AppLocale.va),
      'm_${municipalityId}_news_va',
    );
  });

  test('rejects a notification from a previously selected municipality', () {
    const PushMessage message = PushMessage(
      type: 'news',
      itemId: 'news-1',
      title: 'Noticia',
      body: 'Contenido',
      municipalityId: 'old-municipality',
    );

    expect(
      notificationBelongsToMunicipality(message, 'current-municipality'),
      isFalse,
    );
    expect(
      notificationBelongsToMunicipality(message, 'old-municipality'),
      isTrue,
    );
  });
}
