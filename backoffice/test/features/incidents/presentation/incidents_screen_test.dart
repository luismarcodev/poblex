import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/incidents/domain/entities/managed_incident.dart';
import 'package:poblex_backoffice/features/incidents/presentation/screens/incidents_screen.dart';
import 'package:poblex_backoffice/features/incidents/presentation/viewmodels/incidents_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeIncidentsViewModel extends IncidentsViewModel {
  FakeIncidentsViewModel(this.loader);

  final Future<IncidentsUiState> Function() loader;
  int refreshCalls = 0;
  int statusChanges = 0;
  IncidentStatus? lastStatus;
  String? lastNote;

  @override
  Future<IncidentsUiState> build() => loader();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<AppFailure?> changeStatus({
    required ManagedIncident incident,
    required IncidentStatus status,
    String? note,
  }) async {
    statusChanges++;
    lastStatus = status;
    lastNote = note;
    return null;
  }
}

void main() {
  testWidgets(
    'renders the list and detail without overflow at 320dp and 200% text',
    (tester) async {
      _configureCompactLargeText(tester, height: 1400);
      await tester.pumpWidget(
        _app(
          override: incidentsViewModelProvider.overrideWith(
            () => FakeIncidentsViewModel(
              () async => IncidentsUiState(
                municipalityId: 'municipality-1',
                items: [_incident()],
                nextCursor: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Farola apagada en la plaza.'), findsOneWidget);
      final details = find.byKey(const Key('incident-details-incident-1'));
      await _dragUntilBuilt(tester, details, find.byType(CustomScrollView));
      tester.widget<TextButton>(details).onPressed!();
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Detalle de incidencia'), findsOneWidget);
      final history = find.text('Historial de cambios');
      await _dragUntilBuilt(tester, history, find.byType(ListView).last);
      expect(
        find.text(
          'El historial detallado todavía no está disponible en este panel.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changes status with an optional manager note', (tester) async {
    _configureCompactLargeText(tester, height: 1500);
    late FakeIncidentsViewModel fake;
    await tester.pumpWidget(
      _app(
        override: incidentsViewModelProvider.overrideWith(() {
          fake = FakeIncidentsViewModel(
            () async => IncidentsUiState(
              municipalityId: 'municipality-1',
              items: [_incident()],
              nextCursor: null,
            ),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final details = find.byKey(const Key('incident-details-incident-1'));
    await _dragUntilBuilt(tester, details, find.byType(CustomScrollView));
    tester.widget<TextButton>(details).onPressed!();
    await tester.pumpAndSettle();
    final change = find.text('Cambiar estado');
    await _dragUntilBuilt(tester, change, find.byType(ListView).last);
    await tester.tap(change);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('incident-status-note')),
      'Revisada por obras',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar estado'));
    await tester.pumpAndSettle();

    expect(fake.statusChanges, 1);
    expect(fake.lastStatus, IncidentStatus.inProgress);
    expect(fake.lastNote, 'Revisada por obras');
    expect(find.text('Estado actualizado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps empty and network error states actionable', (
    tester,
  ) async {
    _configureCompactLargeText(tester, height: 900);
    late FakeIncidentsViewModel fake;
    await tester.pumpWidget(
      _app(
        override: incidentsViewModelProvider.overrideWith(() {
          fake = FakeIncidentsViewModel(
            () async => throw const NetworkFailure(message: 'offline'),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final retry = find.text('Reintentar');
    await _dragUntilBuilt(tester, retry, find.byType(CustomScrollView));
    await tester.tap(retry);
    expect(fake.refreshCalls, 1);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({required Override override}) => ProviderScope(
  overrides: [override],
  child: MaterialApp(
    locale: const Locale('es'),
    theme: AppTheme.light(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: IncidentsScreen()),
  ),
);

void _configureCompactLargeText(WidgetTester tester, {required double height}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _dragUntilBuilt(
  WidgetTester tester,
  Finder target,
  Finder scrollable,
) async {
  for (var attempt = 0; attempt < 12 && target.evaluate().isEmpty; attempt++) {
    await tester.drag(scrollable, const Offset(0, -240));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

ManagedIncident _incident() => ManagedIncident(
  id: 'incident-1',
  municipalityId: 'municipality-1',
  category: 'alumbrado',
  description: 'Farola apagada en la plaza.',
  latitude: 39.278,
  longitude: -0.382,
  status: IncidentStatus.received,
  createdAt: DateTime.utc(2026, 8, 10, 8),
  updatedAt: DateTime.utc(2026, 8, 10, 9),
);
