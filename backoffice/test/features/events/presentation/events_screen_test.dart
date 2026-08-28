import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';
import 'package:poblex_backoffice/features/events/presentation/screens/events_screen.dart';
import 'package:poblex_backoffice/features/events/presentation/viewmodels/events_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeEventsViewModel extends EventsViewModel {
  FakeEventsViewModel(this.loader);

  final Future<EventsUiState> Function() loader;
  int refreshCalls = 0;
  int deleteCalls = 0;

  @override
  Future<EventsUiState> build() => loader();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<AppFailure?> delete(ManagedEvent event) async {
    deleteCalls++;
    return null;
  }
}

void main() {
  testWidgets(
    'renders Valencian event content and actions at 320dp and 200% text',
    (tester) async {
      _configureCompactLargeText(tester, height: 1200);
      late FakeEventsViewModel fake;
      await tester.pumpWidget(
        _app(
          locale: const Locale('ca'),
          override: eventsViewModelProvider.overrideWith(() {
            fake = FakeEventsViewModel(
              () async => EventsUiState(
                municipalityId: 'sollana',
                items: [_event()],
                includePast: true,
                nextCursor: null,
              ),
            );
            return fake;
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fira de Sollana'), findsOneWidget);
      expect(find.text('Activitat a la plaça'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final delete = find.widgetWithText(TextButton, 'Esborrar');
      await tester.scrollUntilVisible(
        delete,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.text('Vols esborrar este esdeveniment?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sí, esborrar'));
      await tester.pumpAndSettle();
      expect(fake.deleteCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps the empty state explicit', (tester) async {
    await tester.pumpWidget(
      _app(
        override: eventsViewModelProvider.overrideWith(
          () => FakeEventsViewModel(
            () async => const EventsUiState(
              municipalityId: 'sollana',
              items: [],
              includePast: false,
              nextCursor: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay eventos'), findsOneWidget);
    expect(
      find.text('Publica el primer evento para este municipio.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a network error with a retry action', (tester) async {
    _configureCompactLargeText(tester, height: 500);
    late FakeEventsViewModel fake;
    await tester.pumpWidget(
      _app(
        override: eventsViewModelProvider.overrideWith(() {
          fake = FakeEventsViewModel(
            () async => throw const NetworkFailure(message: 'offline'),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    final retry = find.widgetWithText(FilledButton, 'Reintentar');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    expect(fake.refreshCalls, 1);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({required Override override, Locale locale = const Locale('es')}) =>
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        builder: AppTheme.textScalingBuilder,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: EventsScreen()),
      ),
    );

void _configureCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

ManagedEvent _event() => ManagedEvent(
  id: 'event-1',
  municipalityId: 'sollana',
  title: const EventLocalizedText(
    es: 'Feria de Sollana',
    va: 'Fira de Sollana',
  ),
  description: const EventLocalizedText(
    es: 'Actividad en la plaza',
    va: 'Activitat a la plaça',
  ),
  startAt: DateTime.now().add(const Duration(days: 2)),
  locationName: 'Plaça Major',
  category: 'cultura',
);
