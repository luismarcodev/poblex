import 'package:equatable/equatable.dart';

import '../../../../core/l10n/app_locales.dart';

class ResolvedLocalizedText extends Equatable {
  const ResolvedLocalizedText({
    required this.text,
    required this.sourceLocale,
    required this.isFallback,
  });

  final String text;
  final AppLocale sourceLocale;
  final bool isFallback;

  @override
  List<Object> get props => <Object>[text, sourceLocale, isFallback];
}

class LocalizedText extends Equatable {
  const LocalizedText({this.es, this.va});

  final String? es;
  final String? va;

  ResolvedLocalizedText resolve(AppLocale requested) {
    final String? requestedText = switch (requested) {
      AppLocale.es => _usable(es),
      AppLocale.va => _usable(va),
    };
    if (requestedText != null) {
      return ResolvedLocalizedText(
        text: requestedText,
        sourceLocale: requested,
        isFallback: false,
      );
    }

    final AppLocale fallbackLocale = requested == AppLocale.es
        ? AppLocale.va
        : AppLocale.es;
    final String fallback =
        switch (fallbackLocale) {
          AppLocale.es => _usable(es),
          AppLocale.va => _usable(va),
        } ??
        '';
    return ResolvedLocalizedText(
      text: fallback,
      sourceLocale: fallbackLocale,
      isFallback: true,
    );
  }

  static String? _usable(String? value) {
    final String? trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => <Object?>[es, va];
}
