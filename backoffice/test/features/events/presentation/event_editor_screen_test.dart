import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';
import 'package:poblex_backoffice/features/events/presentation/screens/event_editor_screen.dart';
import 'package:poblex_backoffice/features/events/presentation/viewmodels/event_editor_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

const profile = ManagerProfile(
  id: 'manager',
  email: 'gestor@sollana.es',
  displayName: 'Gestor municipal',
  municipalities: [municipality],
);

class FakeAuthViewModel extends AuthViewModel {
  @override
  Future<ManagerProfile?> build() async => profile;
}

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeEditorViewModel extends EventEditorViewModel {
  SaveEventInput? savedInput;

  @override
  EventEditorUiState build() => const EventEditorUiState();

  @override
  Future<AppFailure?> save(SaveEventInput input) async {
    savedInput = input;
    return null;
  }
}

void main() {
  testWidgets('validates and publishes an event at 320dp and 200% text', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 5200);
    late FakeEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => const Scaffold(body: EventEditorScreen()),
        ),
        GoRoute(
          path: '/eventos',
          builder: (_, _) => const Scaffold(body: Text('Listado de eventos')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _app(
        router,
        eventEditorViewModelProvider.overrideWith(() {
          fake = FakeEditorViewModel();
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final publish = find.widgetWithText(FilledButton, 'Publicar evento');
    await tester.ensureVisible(publish);
    await tester.tap(publish);
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(3));
    expect(fake.savedInput, isNull);

    await tester.enterText(find.byKey(const Key('event-title-es')), 'Feria');
    await tester.enterText(
      find.byKey(const Key('event-description-es')),
      'Actividad en la plaza',
    );
    await tester.enterText(find.byKey(const Key('event-category')), 'cultura');
    await tester.tap(publish);
    await tester.pumpAndSettle();

    expect(fake.savedInput?.municipalityIds, [municipality.id]);
    expect(fake.savedInput?.title.es, 'Feria');
    expect(find.text('Listado de eventos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(GoRouter router, Override editorOverride) => ProviderScope(
  overrides: [
    authViewModelProvider.overrideWith(FakeAuthViewModel.new),
    selectedMunicipalityProvider.overrideWith(FakeMunicipalityViewModel.new),
    editorOverride,
  ],
  child: MaterialApp.router(
    locale: const Locale('es'),
    theme: AppTheme.light(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ),
);

void _setCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
