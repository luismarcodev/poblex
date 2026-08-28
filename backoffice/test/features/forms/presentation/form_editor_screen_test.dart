import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';
import 'package:poblex_backoffice/features/forms/presentation/screens/form_editor_screen.dart';
import 'package:poblex_backoffice/features/forms/presentation/viewmodels/form_editor_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class _MunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class _EditorViewModel extends FormEditorViewModel {
  CreateFormInput? createdInput;

  @override
  FormEditorUiState build() => const FormEditorUiState();

  @override
  Future<AppFailure?> create(CreateFormInput input) async {
    createdInput = input;
    return null;
  }
}

void main() {
  testWidgets('validates and creates at 320dp with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 5000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    late _EditorViewModel fake;
    var created = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedMunicipalityProvider.overrideWith(_MunicipalityViewModel.new),
          formEditorViewModelProvider.overrideWith(() {
            fake = _EditorViewModel();
            return fake;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          theme: AppTheme.light(),
          builder: AppTheme.textScalingBuilder,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FormEditorScreen(
              onCancel: () {},
              onCreated: () => created = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final save = find.byKey(const Key('save-form'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byKey(const Key('form-title-es')),
      'Inscripción paellas',
    );
    await tester.enterText(
      find.byKey(const Key('form-description-es')),
      'Datos para apuntarse',
    );
    await tester.enterText(
      find.byKey(const Key('form-field-key-1')),
      'nombre_completo',
    );
    await tester.enterText(
      find.byKey(const Key('form-field-label-es-1')),
      'Nombre completo',
    );
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(fake.createdInput?.municipalityId, municipality.id);
    expect(fake.createdInput?.fields.single.key, 'nombre_completo');
    expect(created, isTrue);
    expect(tester.takeException(), isNull);
  });
}
