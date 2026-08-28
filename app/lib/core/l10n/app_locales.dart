import 'package:flutter/widgets.dart';

/// The two language codes of this project, which are NOT the same thing.
///
/// The interface speaks `ca`: Dart's [Locale] does not accept the `valencia`
/// variant subtag, so `ca-ES-valencia` only exists in documentation.
/// The backend content speaks `va`: that is the key inside every bilingual
/// `{es, va}` object.
///
/// Resolving a `LocalizedText` with the interface code silently returns the
/// fallback language for every single field, which looks like "the backend has
/// no Valencian" instead of a client bug. Always go through [contentCode].
enum AppLocale {
  es(uiLocale: Locale('es'), contentCode: 'es'),
  va(uiLocale: Locale('ca'), contentCode: 'va');

  const AppLocale({required this.uiLocale, required this.contentCode});

  /// What goes into `MaterialApp.locale` and matches the ARB files.
  final Locale uiLocale;

  /// What indexes the `{es, va}` objects the API returns, and what is sent as
  /// `devices.locale` so targeted pushes arrive in the right language.
  final String contentCode;

  static const List<Locale> supportedUiLocales = <Locale>[
    Locale('es'),
    Locale('ca'),
  ];

  /// Resolves the device language. Anything Catalan-ish (including the
  /// `ca-ES-valencia` a device might report) maps to Valencian; everything
  /// else falls back to Spanish.
  static AppLocale fromDeviceLocale(Locale locale) {
    return locale.languageCode.toLowerCase() == 'ca'
        ? AppLocale.va
        : AppLocale.es;
  }

  static AppLocale fromContentCode(String? code) {
    return code?.toLowerCase() == 'va' ? AppLocale.va : AppLocale.es;
  }
}
