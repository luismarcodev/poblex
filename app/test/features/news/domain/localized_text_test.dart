import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';

void main() {
  group('LocalizedText', () {
    test('resolves the requested language when available', () {
      const LocalizedText text = LocalizedText(es: 'Noticia', va: 'Notícia');

      final ResolvedLocalizedText resolved = text.resolve(AppLocale.va);

      expect(resolved.text, 'Notícia');
      expect(resolved.sourceLocale, AppLocale.va);
      expect(resolved.isFallback, isFalse);
    });

    test('falls back to the available language without returning null', () {
      const LocalizedText text = LocalizedText(es: 'Solo castellano');

      final ResolvedLocalizedText resolved = text.resolve(AppLocale.va);

      expect(resolved.text, 'Solo castellano');
      expect(resolved.sourceLocale, AppLocale.es);
      expect(resolved.isFallback, isTrue);
    });
  });
}
