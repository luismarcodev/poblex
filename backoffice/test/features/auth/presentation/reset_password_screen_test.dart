import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/password_recovery_view_models.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

void main() {
  testWidgets('rejects empty, short and mismatching passwords', (tester) async {
    late _FakeResetPasswordViewModel fake;
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          resetPasswordViewModelProvider.overrideWith(() {
            fake = _FakeResetPasswordViewModel();
            return fake;
          }),
        ],
        child: const ResetPasswordScreen(token: 'valid-token'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar contraseña'));
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'short');
    await tester.enterText(find.byType(TextFormField).last, 'different');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar contraseña'));
    await tester.pump();
    expect(
      find.text('La contraseña debe tener al menos 8 caracteres'),
      findsOneWidget,
    );
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(fake.submittedPassword, isNull);
  });

  testWidgets('submits a valid password and renders completion', (
    tester,
  ) async {
    late _FakeResetPasswordViewModel fake;
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          resetPasswordViewModelProvider.overrideWith(() {
            fake = _FakeResetPasswordViewModel();
            return fake;
          }),
        ],
        child: const ResetPasswordScreen(token: 'valid-token'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'new-password');
    await tester.enterText(find.byType(TextFormField).last, 'new-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar contraseña'));
    await tester.pump();

    expect(fake.builtToken, 'valid-token');
    expect(fake.submittedPassword, 'new-password');
    expect(find.text('Contraseña actualizada'), findsOneWidget);
  });

  testWidgets('shows a safe error when the reset token is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        overrides: [],
        child: ResetPasswordScreen(token: '   '),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('El enlace de recuperación no es válido o ha caducado.'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNothing);
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
          resetPasswordViewModelProvider.overrideWith(
            _FakeResetPasswordViewModel.new,
          ),
        ],
        child: const ResetPasswordScreen(token: 'valid-token'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Crear una contraseña nueva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeResetPasswordViewModel extends ResetPasswordViewModel {
  String? builtToken;
  String? submittedPassword;

  @override
  PasswordRecoveryUiState build(String arg) {
    builtToken = arg;
    return const PasswordRecoveryUiState();
  }

  @override
  Future<void> submit(String newPassword) async {
    submittedPassword = newPassword;
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
