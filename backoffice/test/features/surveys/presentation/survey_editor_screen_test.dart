import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/surveys/domain/entities/managed_survey.dart';
import 'package:poblex_backoffice/features/surveys/presentation/screens/survey_editor_screen.dart';
import 'package:poblex_backoffice/features/surveys/presentation/viewmodels/survey_editor_view_model.dart';
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

class FakeSurveyEditorViewModel extends SurveyEditorViewModel {
  CreateSurveyInput? createdInput;

  @override
  SurveyEditorUiState build() => const SurveyEditorUiState();

  @override
  Future<AppFailure?> create(CreateSurveyInput input) async {
    createdInput = input;
    return null;
  }
}

void main() {
  testWidgets('validates and creates a survey at 320dp and 200% text', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 6500);
    late FakeSurveyEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => const Scaffold(body: SurveyEditorScreen()),
        ),
        GoRoute(
          path: '/encuestas',
          builder: (_, _) => const Scaffold(body: Text('Listado de encuestas')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedMunicipalityProvider.overrideWith(
            FakeMunicipalityViewModel.new,
          ),
          surveyEditorViewModelProvider.overrideWith(() {
            fake = FakeSurveyEditorViewModel();
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

    final publish = find.byKey(const Key('publish-survey'));
    await tester.ensureVisible(publish);
    await tester.tap(publish);
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(3));
    expect(fake.createdInput, isNull);

    await tester.enterText(
      find.byKey(const Key('survey-question-es')),
      '¿Qué actividad prefieres?',
    );
    await tester.enterText(find.byKey(const Key('survey-option-es-0')), 'Cine');
    await tester.enterText(
      find.byKey(const Key('survey-option-es-1')),
      'Teatro',
    );
    await tester.tap(publish);
    await tester.pumpAndSettle();

    expect(fake.createdInput?.municipalityId, municipality.id);
    expect(fake.createdInput?.options.length, 2);
    expect(fake.createdInput?.question.es, '¿Qué actividad prefieres?');
    expect(find.text('Listado de encuestas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setCompactLargeText(WidgetTester tester, {double height = 1000}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
