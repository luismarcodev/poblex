import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';
import 'package:poblex_backoffice/features/pharmacies/presentation/screens/duty_pharmacy_editor_screen.dart';
import 'package:poblex_backoffice/features/pharmacies/presentation/viewmodels/duty_pharmacy_editor_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const sollana = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);
const sueca = ManagedMunicipality(
  id: 'sueca',
  name: 'Sueca',
  province: 'València',
  languages: ['es', 'va'],
);
const profile = ManagerProfile(
  id: 'manager',
  email: 'manager@example.test',
  displayName: 'Gestor municipal',
  municipalities: [sollana, sueca],
);

class FakeAuthViewModel extends AuthViewModel {
  @override
  Future<ManagerProfile?> build() async => profile;
}

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => sollana;
}

class FakeEditorViewModel extends DutyPharmacyEditorViewModel {
  SaveDutyPharmacyInput? savedInput;

  @override
  DutyPharmacyEditorUiState build() => const DutyPharmacyEditorUiState();

  @override
  Future<AppFailure?> save(SaveDutyPharmacyInput input) async {
    savedInput = input;
    return null;
  }
}

void main() {
  testWidgets('validates and publishes to multiple municipalities at 200%', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 4200);
    late FakeEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => const Scaffold(body: DutyPharmacyEditorScreen()),
        ),
        GoRoute(
          path: '/farmacias',
          builder: (_, _) => const Scaffold(body: Text('Listado farmacias')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(FakeAuthViewModel.new),
          selectedMunicipalityProvider.overrideWith(
            FakeMunicipalityViewModel.new,
          ),
          dutyPharmacyEditorViewModelProvider.overrideWith(() {
            fake = FakeEditorViewModel();
            return fake;
          }),
        ],
        child: MaterialApp.router(
          locale: const Locale('es'),
          theme: AppTheme.light(),
          builder: AppTheme.textScalingBuilder,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final save = find.widgetWithText(FilledButton, 'Guardar guardia');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(4));
    expect(fake.savedInput, isNull);

    await tester.enterText(
      find.byKey(const Key('duty-pharmacy-name')),
      'Farmacia Ribera',
    );
    await tester.enterText(
      find.byKey(const Key('duty-pharmacy-address')),
      'Carrer Major, 12',
    );
    await tester.enterText(
      find.byKey(const Key('duty-pharmacy-phone')),
      '961 234 567',
    );
    await tester.enterText(
      find.byKey(const Key('duty-pharmacy-schedule')),
      '9:00 - 22:00',
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Sueca'));
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(fake.savedInput?.municipalityIds.toSet(), {'sollana', 'sueca'});
    expect(fake.savedInput?.replaceExisting, isFalse);
    expect(find.text('Listado farmacias'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
