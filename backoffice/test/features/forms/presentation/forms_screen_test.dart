import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';
import 'package:poblex_backoffice/features/forms/presentation/screens/forms_screen.dart';
import 'package:poblex_backoffice/features/forms/presentation/viewmodels/forms_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class _FormsViewModel extends FormsViewModel {
  @override
  Future<FormsUiState> build() async => FormsUiState(
    municipalityId: 'municipality-1',
    items: [_form],
    includeClosed: false,
    nextCursor: null,
  );
}

void main() {
  testWidgets('renders the form list at 320dp with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    var createRequested = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [formsViewModelProvider.overrideWith(_FormsViewModel.new)],
        child: MaterialApp(
          locale: const Locale('es'),
          theme: AppTheme.light(),
          builder: AppTheme.textScalingBuilder,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FormsScreen(onCreate: () => createRequested = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inscripción paellas'), findsOneWidget);
    expect(find.text('Exportar respuestas CSV'), findsOneWidget);
    await tester.tap(find.byKey(const Key('create-form')));
    expect(createRequested, isTrue);
    expect(tester.takeException(), isNull);
  });
}

final _form = ManagedForm(
  id: 'form-1',
  municipalityId: 'municipality-1',
  title: const FormLocalizedText(es: 'Inscripción paellas'),
  description: const FormLocalizedText(es: 'Datos para apuntarse'),
  deadline: DateTime.utc(2026, 9, 1),
  isOpen: true,
  fields: const [
    ManagedFormField(
      id: 'field-1',
      key: 'name',
      label: FormLocalizedText(es: 'Nombre'),
      type: ManagedFormFieldType.text,
      required: true,
      options: [],
      position: 0,
    ),
  ],
);
