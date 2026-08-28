import 'package:equatable/equatable.dart';

import '../l10n/app_locales.dart';

/// What the app knows about "who is using it" — which is deliberately very
/// little: a municipality, a language and a forgeable device identifier. No
/// account, no personal data.
class SessionState extends Equatable {
  const SessionState({
    this.deviceId,
    this.municipalityId,
    this.municipalityName,
    this.municipalitySlug,
    this.municipalityPrimaryColor,
    this.localeOverride,
    required this.deviceLocale,
  });

  const SessionState.initial()
    : deviceId = null,
      municipalityId = null,
      municipalityName = null,
      municipalitySlug = null,
      municipalityPrimaryColor = null,
      localeOverride = null,
      deviceLocale = AppLocale.es;

  final String? deviceId;

  final String? municipalityId;
  final String? municipalityName;
  final String? municipalitySlug;

  /// Brand seed as sent by the backend (`#RRGGBB`). Null means the town has
  /// not customised it and the default Poblex palette applies.
  final String? municipalityPrimaryColor;

  /// Explicit choice from Settings. Null means "follow the device".
  final AppLocale? localeOverride;

  final AppLocale deviceLocale;

  /// The language actually in use. Everything — interface, content resolution
  /// and the `Accept-Language` header — reads this and nothing else.
  AppLocale get locale => localeOverride ?? deviceLocale;

  /// Onboarding is done when there is a municipality. Without one the device
  /// cannot even be registered, so no write is possible.
  bool get hasMunicipality => municipalityId != null;

  SessionState copyWith({
    String? deviceId,
    String? municipalityId,
    String? municipalityName,
    String? municipalitySlug,
    String? municipalityPrimaryColor,
    bool clearMunicipalityPrimaryColor = false,
    AppLocale? localeOverride,
    bool clearLocaleOverride = false,
    AppLocale? deviceLocale,
  }) {
    return SessionState(
      deviceId: deviceId ?? this.deviceId,
      municipalityId: municipalityId ?? this.municipalityId,
      municipalityName: municipalityName ?? this.municipalityName,
      municipalitySlug: municipalitySlug ?? this.municipalitySlug,
      municipalityPrimaryColor: clearMunicipalityPrimaryColor
          ? null
          : municipalityPrimaryColor ?? this.municipalityPrimaryColor,
      localeOverride: clearLocaleOverride
          ? null
          : localeOverride ?? this.localeOverride,
      deviceLocale: deviceLocale ?? this.deviceLocale,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    deviceId,
    municipalityId,
    municipalityName,
    municipalitySlug,
    municipalityPrimaryColor,
    localeOverride,
    deviceLocale,
  ];
}
