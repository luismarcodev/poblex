import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/features/news/domain/entities/news_item.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';
import 'package:poblex/features/news/presentation/widgets/news_card.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

// Longer than the Spanish title on purpose: Valencian tends to run 10-20%
// longer, and that's exactly the case the layout has to survive at 200%
// text scale (design-system.md §3, "regla de prueba").
final NewsItem _pinnedItem = NewsItem(
  id: 'news-1',
  municipalityId: 'municipality-1',
  title: const LocalizedText(
    es: 'Corte de agua programado en el Carrer Major',
    va: "Tall d'aigua programat al Carrer Major i carrers adjacents",
  ),
  body: const LocalizedText(es: 'Contenido', va: 'Contingut'),
  category: 'servicios',
  pinned: true,
  publishedAt: DateTime.utc(2026, 8, 9),
  archived: false,
  attachments: const <NewsAttachment>[],
);

Widget _harness({
  required NewsItem item,
  required AppLocale locale,
  required double textScale,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    locale: locale.uiLocale,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    // Matches production: NewsScreen always places cards inside a scrolling
    // list, which gives each one unbounded height to grow into. A bare
    // Scaffold body gives a bounded viewport height instead and reports a
    // RenderFlex overflow that could never happen where this widget actually
    // lives — that would be testing the harness, not the card.
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: NewsCard(item: item, locale: locale, onTap: onTap ?? () {}),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders a readable, tappable localized news card', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _harness(
        item: _pinnedItem,
        locale: AppLocale.es,
        textScale: 2,
        onTap: () => tapped = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Corte de agua'), findsOneWidget);
    expect(find.text('Servicios'), findsOneWidget);
    expect(find.text('Destacada'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(NewsCard));
    expect(tapped, isTrue);
  });

  // §4.3: the automated checks that catch cheap regressions — they don't
  // replace the manual TalkBack/VoiceOver walkthrough, but a card that fails
  // these never should have shipped in the first place.
  testWidgets('meets the WCAG contrast and tap-target guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _harness(item: _pinnedItem, locale: AppLocale.es, textScale: 1),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  // A-13/A-14: the layout survives the Valencian title at every committed
  // scale, not just the default. RenderFlex overflow throws during layout,
  // so `takeException()` catching nothing is the assertion.
  for (final double scale in <double>[1.0, 1.5, 2.0]) {
    testWidgets('does not overflow in Valencian at textScaler $scale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(item: _pinnedItem, locale: AppLocale.va, textScale: scale),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
