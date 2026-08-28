import 'app_locales.dart';

/// The single point where the active language changes.
///
/// Dio reads this holder lazily for `Accept-Language`. The presentation's
/// SessionViewModel owns persistence and FCM topic changes; infrastructure only
/// needs a synchronous view of the locale while a request is being created.
class LocaleController {
  LocaleController({AppLocale initial = AppLocale.es}) : _current = initial;

  AppLocale _current;

  AppLocale get current => _current;

  void set(AppLocale locale) {
    if (_current == locale) return;
    _current = locale;
  }
}
