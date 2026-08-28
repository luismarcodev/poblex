import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';
import 'package:poblex_backoffice/features/alerts/presentation/screens/alert_editor_screen.dart';
import 'package:poblex_backoffice/features/alerts/presentation/viewmodels/alert_editor_view_model.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeAlertEditorViewModel extends AlertEditorViewModel {
  SaveManualAlertInput? savedInput;

  @override
  AlertEditorUiState build() => const AlertEditorUiState();

  @override
  Future<AppFailure?> save(SaveManualAlertInput input) async {
    savedInput = input;
    return null;
  }
}

void main() {
  testWidgets('creates a red alert without overflow at 320dp and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1400);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    late FakeAlertEditorViewModel fake;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedMunicipalityProvider.overrideWith(
            FakeMunicipalityViewModel.new,
          ),
          alertEditorViewModelProvider.overrideWith(() {
            fake = FakeAlertEditorViewModel();
            return fake;
          }),
        ],
        child: _routerApp(),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Inundación');
    await tester.enterText(fields.at(1), 'Evita la zona inundable');
    final redChoice = find.byIcon(Icons.emergency_rounded);
    await tester.ensureVisible(redChoice);
    await tester.tap(redChoice);
    await tester.pump();
    expect(
      find.text(
        'Las alertas rojas enviarán una notificación obligatoria a los vecinos del municipio.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    final publish = find.widgetWithText(FilledButton, 'Publicar alerta');
    await tester.scrollUntilVisible(
      publish,
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(publish);
    await tester.pumpAndSettle();

    expect(fake.savedInput?.municipalityId, municipality.id);
    expect(fake.savedInput?.severity, ManagedAlertSeverity.red);
    expect(find.text('alerts destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _routerApp() {
  final router = GoRouter(
    initialLocation: '/editor',
    routes: [
      GoRoute(
        path: '/editor',
        builder: (_, _) => const Scaffold(body: AlertEditorScreen()),
      ),
      GoRoute(
        path: '/alertas',
        builder: (_, _) => const Scaffold(body: Text('alerts destination')),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('es'),
    theme: AppTheme.light(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
