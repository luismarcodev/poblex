import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/errors/failure.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex/shared/presentation/failure_view.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

Widget _harness({required Widget child, Locale locale = const Locale('es')}) {
  return MaterialApp(
    locale: locale,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows a specific network error and exposes retry', (
    WidgetTester tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      _harness(
        child: InlineFailureView(
          failure: const NetworkFailure(),
          sectionName: 'Noticias',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('No hay conexión'), findsOneWidget);
    expect(
      find.text('Comprueba que tienes datos o wifi y vuelve a intentarlo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Reintentar'));
    expect(retried, isTrue);
  });

  // §4.3 + A-38: the full-screen error is what a vecino actually sees when a
  // section fails to load, so it's the one that has to clear the guidelines.
  testWidgets('the full-screen failure meets contrast and tap-target rules', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _harness(
        child: FailureView(
          failure: const ServerFailure(statusCode: 503),
          sectionName: 'Noticias',
          onRetry: () {},
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  for (final double scale in <double>[1.0, 1.5, 2.0]) {
    testWidgets('does not overflow in Valencian at textScaler $scale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: _harness(
            locale: const Locale('ca'),
            child: FailureView(
              failure: const TooManyRequestsFailure(),
              sectionName: 'Notícies',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
