import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex/shared/presentation/coming_soon_screen.dart';
import 'package:poblex/shared/presentation/home_screen.dart';
import 'package:poblex/shared/presentation/settings_screen.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const SessionState _session = SessionState(
  deviceId: 'device-1',
  municipalityId: 'municipality-1',
  municipalityName: 'Sollana',
  municipalitySlug: 'sollana',
  deviceLocale: AppLocale.va,
  localeOverride: AppLocale.va,
);

class _FakeSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => _session;

  @override
  Future<void> setLocaleOverride(AppLocale? locale) async {
    final SessionState current = state.requireValue;
    state = AsyncData<SessionState>(
      current.copyWith(
        localeOverride: locale,
        clearLocaleOverride: locale == null,
      ),
    );
  }
}

Widget _harness(Widget child) => ProviderScope(
  overrides: <Override>[
    sessionViewModelProvider.overrideWith(_FakeSessionViewModel.new),
  ],
  child: MaterialApp(
    locale: const Locale('ca'),
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: child,
  ),
);

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> useSmallPhone(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  testWidgets('home fits a small phone in Valencian at 200 percent', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(_harness(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sollana'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Seccions'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Seccions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coming-soon content scrolls on a short scaled viewport', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    tester.view.physicalSize = const Size(320, 320);
    await tester.pumpWidget(
      _harness(const ComingSoonScreen(section: 'pharmacies')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings changes only the selected language state', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(_harness(const SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Castellà'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Castellà'));
    await tester.pump();

    final FilterChip spanishChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Castellà'),
    );
    expect(spanishChip.selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
