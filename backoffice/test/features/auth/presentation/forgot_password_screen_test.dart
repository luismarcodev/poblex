import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/password_recovery_view_models.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

void main() {
  testWidgets('validates email and renders the privacy-safe success state', (
    tester,
  ) async {
    late _FakeForgotPasswordViewModel fake;
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          forgotPasswordViewModelProvider.overrideWith(() {
            fake = _FakeForgotPasswordViewModel();
            return fake;
          }),
        ],
        child: const ForgotPasswordScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Enviar enlace'));
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsOneWidget);
    expect(fake.submittedEmail, isNull);

    await tester.enterText(find.byType(TextFormField), 'correo-invalido');
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar enlace'));
    await tester.pump();
    expect(find.text('Introduce un correo electrónico válido'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'gestor@sollana.es');
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar enlace'));
    await tester.pump();

    expect(fake.submittedEmail, 'gestor@sollana.es');
    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(find.textContaining('gestor@sollana.es'), findsNothing);
  });

  testWidgets('fits at 320 dp with text scaled to 200%', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _TestApp(
        overrides: [
          forgotPasswordViewModelProvider.overrideWith(
            _FakeForgotPasswordViewModel.new,
          ),
        ],
        child: const ForgotPasswordScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeForgotPasswordViewModel extends ForgotPasswordViewModel {
  String? submittedEmail;

  @override
  PasswordRecoveryUiState build() => const PasswordRecoveryUiState();

  @override
  Future<void> submit(String email) async {
    submittedEmail = email;
    state = const AsyncData(PasswordRecoveryUiState(completed: true));
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.overrides, required this.child});

  final List<Override> overrides;
  final Widget child;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('es'),
      theme: AppTheme.light(),
      builder: AppTheme.textScalingBuilder,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
