import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/screens/login_screen.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeAuthViewModel extends AuthViewModel {
  bool loginCalled = false;

  @override
  Future<ManagerProfile?> build() async => null;

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
  }
}

void main() {
  testWidgets('validates credentials before asking the ViewModel to log in', (
    tester,
  ) async {
    late FakeAuthViewModel fake;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() {
            fake = FakeAuthViewModel();
            return fake;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Este campo es obligatorio'), findsNWidgets(2));
    expect(fake.loginCalled, isFalse);

    await tester.enterText(find.byType(TextFormField).first, 'correo-invalido');
    await tester.enterText(find.byType(TextFormField).last, 'secret-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Introduce un correo electrónico válido'), findsOneWidget);
    expect(fake.loginCalled, isFalse);

    await tester.enterText(
      find.byType(TextFormField).first,
      'gestor@sollana.es',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(fake.loginCalled, isTrue);
  });

  testWidgets(
    'supports compact width, 200% text and an accessible password toggle',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(FakeAuthViewModel.new),
          ],
          child: MaterialApp(
            locale: const Locale('es'),
            theme: AppTheme.light(),
            builder: AppTheme.textScalingBuilder,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final showPassword = find.byTooltip('Mostrar contraseña');
      await tester.ensureVisible(showPassword);
      expect(showPassword, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(showPassword);
      await tester.pump();
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
