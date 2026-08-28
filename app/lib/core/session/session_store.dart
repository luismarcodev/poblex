import '../l10n/app_locales.dart';

/// Persistence of the chosen municipality and the language override.
///
/// Not the device identifier: that one lives in secure storage. These are
/// preferences, not secrets, and mixing them would clutter the secure store
/// for nothing.
abstract interface class SessionStore {
  Future<StoredSession> read();

  Future<void> saveMunicipality({
    required String id,
    required String name,
    required String slug,
    String? primaryColor,
  });

  Future<void> saveLocaleOverride(AppLocale? locale);
}

class StoredSession {
  const StoredSession({
    this.municipalityId,
    this.municipalityName,
    this.municipalitySlug,
    this.municipalityPrimaryColor,
    this.localeOverride,
  });

  final String? municipalityId;
  final String? municipalityName;
  final String? municipalitySlug;
  final String? municipalityPrimaryColor;
  final AppLocale? localeOverride;
}
