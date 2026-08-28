import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locales.dart';
import 'session_store.dart';

const String _keyMunicipalityId = 'poblex_municipality_id';
const String _keyMunicipalityName = 'poblex_municipality_name';
const String _keyMunicipalitySlug = 'poblex_municipality_slug';
const String _keyMunicipalityColor = 'poblex_municipality_color';
const String _keyLocaleOverride = 'poblex_locale_override';

class PrefsSessionStore implements SessionStore {
  PrefsSessionStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<StoredSession> read() async {
    final String? override = _prefs.getString(_keyLocaleOverride);

    return StoredSession(
      municipalityId: _prefs.getString(_keyMunicipalityId),
      municipalityName: _prefs.getString(_keyMunicipalityName),
      municipalitySlug: _prefs.getString(_keyMunicipalitySlug),
      municipalityPrimaryColor: _prefs.getString(_keyMunicipalityColor),
      localeOverride: override == null
          ? null
          : AppLocale.fromContentCode(override),
    );
  }

  @override
  Future<void> saveMunicipality({
    required String id,
    required String name,
    required String slug,
    String? primaryColor,
  }) async {
    await _prefs.setString(_keyMunicipalityId, id);
    await _prefs.setString(_keyMunicipalityName, name);
    await _prefs.setString(_keyMunicipalitySlug, slug);
    if (primaryColor == null) {
      await _prefs.remove(_keyMunicipalityColor);
    } else {
      await _prefs.setString(_keyMunicipalityColor, primaryColor);
    }
  }

  @override
  Future<void> saveLocaleOverride(AppLocale? locale) async {
    if (locale == null) {
      await _prefs.remove(_keyLocaleOverride);
      return;
    }
    // The content code is stored, not the interface one: it is the stable
    // identifier of the two and what the backend understands.
    await _prefs.setString(_keyLocaleOverride, locale.contentCode);
  }
}
