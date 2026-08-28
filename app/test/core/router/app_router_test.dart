import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex/core/router/app_router.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

void main() {
  testWidgets('a restored PDF URL without route extra shows a recovery view', (
    WidgetTester tester,
  ) async {
    final GoRouter router = AppRouter.create();
    addTearDown(router.dispose);
    router.go('/pdf');

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('es'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No podemos abrir este documento'), findsWidgets);
    expect(find.text('Volver a noticias'), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
