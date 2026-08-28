import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_backoffice/shared/presentation/backoffice_shell.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeAuthViewModel extends AuthViewModel {
  FakeAuthViewModel(this.profile);
  final ManagerProfile profile;

  @override
  Future<ManagerProfile?> build() async => profile;
}

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

void main() {
  testWidgets('switches between compact and wide navigation without overflow', (
    tester,
  ) async {
    _setViewport(tester, const Size(500, 800), textScale: 2);
    await tester.pumpWidget(_app(_profile([municipality])));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows an actionable empty assignment state on a short viewport',
    (tester) async {
      _setViewport(tester, const Size(320, 360), textScale: 2);
      await tester.pumpWidget(_app(_profile(const [])));
      await tester.pumpAndSettle();

      expect(
        find.text('Esta cuenta no tiene municipios asignados.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Cerrar sesión'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(ManagerProfile profile) => ProviderScope(
  overrides: [
    authViewModelProvider.overrideWith(() => FakeAuthViewModel(profile)),
    selectedMunicipalityProvider.overrideWith(FakeMunicipalityViewModel.new),
  ],
  child: MaterialApp(
    locale: const Locale('es'),
    theme: AppTheme.light(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const BackofficeShell(child: ColoredBox(color: Colors.transparent)),
  ),
);

ManagerProfile _profile(List<ManagedMunicipality> municipalities) =>
    ManagerProfile(
      id: 'manager',
      email: 'gestor@sollana.es',
      displayName: 'Gestor municipal',
      municipalities: municipalities,
    );

void _setViewport(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
