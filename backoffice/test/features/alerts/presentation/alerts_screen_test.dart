import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';
import 'package:poblex_backoffice/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:poblex_backoffice/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeAlertsViewModel extends AlertsViewModel {
  FakeAlertsViewModel(this.loader);

  final Future<AlertsUiState> Function() loader;
  int deleteCalls = 0;

  @override
  Future<AlertsUiState> build() => loader();

  @override
  Future<AppFailure?> delete(ManagedAlert alert) async {
    deleteCalls++;
    return null;
  }
}

void main() {
  testWidgets(
    'renders Valencian alert content and actions at 320dp and 200% text',
    (tester) async {
      _configureCompactLargeText(tester, height: 2400);
      late FakeAlertsViewModel fake;
      await tester.pumpWidget(
        _app(
          locale: const Locale('ca'),
          override: alertsViewModelProvider.overrideWith(() {
            fake = FakeAlertsViewModel(
              () async => AlertsUiState(
                municipalityId: 'municipality-1',
                items: [_alert()],
                includeExpired: true,
                nextCursor: null,
              ),
            );
            return fake;
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Avís roig · Nivell 3'), findsOneWidget);
      expect(find.text('Evita la zona inundable'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final delete = find.widgetWithText(TextButton, 'Esborrar');
      await tester.ensureVisible(delete);
      await tester.pumpAndSettle();
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.text('Vols esborrar esta alerta?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sí, esborrar'));
      await tester.pumpAndSettle();
      expect(fake.deleteCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps the empty state explicit', (tester) async {
    await tester.pumpWidget(
      _app(
        override: alertsViewModelProvider.overrideWith(
          () => FakeAlertsViewModel(
            () async => const AlertsUiState(
              municipalityId: 'municipality-1',
              items: [],
              includeExpired: false,
              nextCursor: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay alertas'), findsOneWidget);
    expect(find.text('No hay alertas para este municipio.'), findsOneWidget);
  });
}

Widget _app({required Override override, Locale locale = const Locale('es')}) =>
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        builder: AppTheme.textScalingBuilder,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: AlertsScreen()),
      ),
    );

void _configureCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

ManagedAlert _alert() => ManagedAlert(
  id: 'alert-1',
  municipalityId: 'municipality-1',
  source: ManagedAlertSource.manual,
  severity: ManagedAlertSeverity.red,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Inundació',
  body: const AlertLocalizedText(
    es: 'Evita la zona inundable',
    va: 'Evita la zona inundable',
  ),
  startAt: DateTime.now().subtract(const Duration(hours: 1)),
  forcesNotification: true,
);
