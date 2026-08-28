import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/surveys/domain/entities/managed_survey.dart';
import 'package:poblex_backoffice/features/surveys/presentation/screens/surveys_screen.dart';
import 'package:poblex_backoffice/features/surveys/presentation/viewmodels/surveys_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeSurveysViewModel extends SurveysViewModel {
  FakeSurveysViewModel(this.loader);
  final Future<SurveysUiState> Function() loader;
  int refreshCalls = 0;

  @override
  Future<SurveysUiState> build() => loader();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<AppFailure?> loadDetail(ManagedSurvey survey) async {
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        details: {
          survey.id: survey.copyWith(
            options: survey.options
                .map((option) => option.copyWith(votes: option.position + 1))
                .toList(),
          ),
        },
      ),
    );
    return null;
  }
}

void main() {
  testWidgets('renders Valencian content and results at 320dp and 200% text', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 4000);
    await tester.pumpWidget(
      _app(
        locale: const Locale('ca'),
        override: surveysViewModelProvider.overrideWith(
          () => FakeSurveysViewModel(
            () async => SurveysUiState(
              municipalityId: 'municipality-1',
              items: [_survey],
              includeClosed: true,
              nextCursor: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quina activitat prefereixes?'), findsOneWidget);
    expect(find.text('Enquestes no vinculants'), findsWidgets);
    expect(tester.takeException(), isNull);

    final results = find.widgetWithText(TextButton, 'Veure els resultats');
    await tester.scrollUntilVisible(
      results,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(results);
    await tester.pumpAndSettle();
    expect(find.text('3 vots totals'), findsOneWidget);
    expect(find.text('Plaça'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps empty and network error states explicit', (tester) async {
    late FakeSurveysViewModel fake;
    await tester.pumpWidget(
      _app(
        override: surveysViewModelProvider.overrideWith(() {
          fake = FakeSurveysViewModel(
            () async => throw const NetworkFailure(message: 'offline'),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final retry = find.widgetWithText(FilledButton, 'Reintentar');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    expect(fake.refreshCalls, 1);

    await tester.pumpWidget(
      _app(
        override: surveysViewModelProvider.overrideWith(
          () => FakeSurveysViewModel(
            () async => const SurveysUiState(
              municipalityId: 'municipality-1',
              items: [],
              includeClosed: false,
              nextCursor: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No hay encuestas'), findsOneWidget);
  });
}

Widget _app({required Override override, Locale locale = const Locale('es')}) =>
    ProviderScope(
      key: UniqueKey(),
      overrides: [override],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        builder: AppTheme.textScalingBuilder,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SurveysScreen()),
      ),
    );

void _setCompactLargeText(WidgetTester tester, {double height = 1000}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

final _survey = ManagedSurvey(
  id: 'survey-1',
  municipalityId: 'municipality-1',
  question: const SurveyLocalizedText(
    es: '¿Qué actividad prefieres?',
    va: 'Quina activitat prefereixes?',
  ),
  closesAt: DateTime.utc(2026, 9, 1),
  isOpen: true,
  binding: false,
  options: const [
    ManagedSurveyOption(
      id: 'one',
      label: SurveyLocalizedText(es: 'Plaza', va: 'Plaça'),
      position: 0,
    ),
    ManagedSurveyOption(
      id: 'two',
      label: SurveyLocalizedText(es: 'Parque', va: 'Parc'),
      position: 1,
    ),
  ],
);
