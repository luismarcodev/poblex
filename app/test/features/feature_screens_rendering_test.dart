import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/alerts/domain/entities/alert.dart';
import 'package:poblex/features/alerts/presentation/screens/alert_detail_screen.dart';
import 'package:poblex/features/alerts/presentation/viewmodels/alert_detail_view_model.dart';
import 'package:poblex/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:poblex/features/municipalities/domain/entities/municipality.dart';
import 'package:poblex/features/municipalities/presentation/screens/municipality_onboarding_screen.dart';
import 'package:poblex/features/municipalities/presentation/viewmodels/municipalities_view_model.dart';
import 'package:poblex/features/news/domain/entities/news_item.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';
import 'package:poblex/shared/presentation/home_screen.dart';
import 'package:poblex/features/news/presentation/screens/news_detail_screen.dart';
import 'package:poblex/features/news/presentation/screens/news_screen.dart';
import 'package:poblex/features/news/presentation/viewmodels/news_detail_view_model.dart';
import 'package:poblex/features/news/presentation/viewmodels/news_view_model.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const SessionState _session = SessionState(
  deviceId: 'device-1',
  municipalityId: 'municipality-1',
  municipalityName: 'Sollana',
  municipalitySlug: 'sollana',
  deviceLocale: AppLocale.va,
  localeOverride: AppLocale.va,
);

final NewsItem _news = NewsItem(
  id: 'news-1',
  municipalityId: 'municipality-1',
  title: const LocalizedText(
    es: 'Corte de agua en el centro',
    va: "Tall d'aigua programat al centre de Sollana i carrers adjacents",
  ),
  body: const LocalizedText(
    es: 'Contenido de la noticia.',
    va: 'El subministrament quedarà interromput durant els treballs de manteniment programats per l’ajuntament.',
  ),
  category: 'servicios',
  pinned: true,
  publishedAt: DateTime.utc(2026, 8, 10),
  archived: false,
  attachments: const <NewsAttachment>[
    NewsAttachment(
      id: 'attachment-1',
      name: 'Informació completa del tall programat.pdf',
      url: 'https://example.com/notice.pdf',
      mimeType: 'application/pdf',
    ),
  ],
);

class _FakeSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => _session;
}

class _FakeMunicipalitiesViewModel extends MunicipalitiesViewModel {
  @override
  Future<MunicipalitiesUiState> build() async => const MunicipalitiesUiState(
    items: <Municipality>[
      Municipality(
        id: 'municipality-1',
        slug: 'sollana',
        name: 'Sollana',
        province: 'València',
        languages: <String>['es', 'va'],
      ),
    ],
  );
}

class _FakeNewsViewModel extends NewsViewModel {
  @override
  Future<NewsUiState> build() async => NewsUiState(
    pinned: <NewsItem>[_news],
    categories: const <String>['general', 'servicios', 'cultural'],
    nextCursor: 'next-page',
  );
}

class _FakeNewsDetailViewModel extends NewsDetailViewModel {
  @override
  Future<NewsDetailUiState> build(String arg) async =>
      NewsDetailUiState(item: _news);
}

class _FakeRedAlertsViewModel extends AlertsViewModel {
  @override
  Future<AlertsUiState> build() async => AlertsUiState(
    items: <MunicipalAlert>[
      MunicipalAlert(
        id: 'red-alert',
        municipalityId: 'municipality-1',
        source: AlertSource.manual,
        severity: AlertSeverityLevel.red,
        phenomenonType: AlertPhenomenonType.meteorologico,
        phenomenon: 'Pluges intenses',
        body: const LocalizedText(es: 'Precaución', va: 'Precaució'),
        startAt: DateTime.utc(2026, 11, 1),
        endAt: null,
        forcesNotification: true,
      ),
    ],
  );
}

class _FakeAlertDetailViewModel extends AlertDetailViewModel {
  @override
  Future<AlertDetailUiState> build(String arg) async => AlertDetailUiState(
    alert: MunicipalAlert(
      id: arg,
      municipalityId: 'municipality-1',
      source: AlertSource.manual,
      severity: AlertSeverityLevel.orange,
      phenomenonType: AlertPhenomenonType.meteorologico,
      phenomenon: 'Pluges intenses a Sollana',
      body: const LocalizedText(
        es: 'Evita desplazamientos innecesarios.',
        va: 'Evita desplaçaments innecessaris durant les pluges intenses.',
      ),
      startAt: DateTime.utc(2026, 11, 1),
      endAt: DateTime.utc(2026, 11, 5),
      forcesNotification: false,
    ),
  );
}

Widget _harness(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
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
  Future<void> useSmallPhone(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  testWidgets('municipality onboarding fits the smallest supported layout', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(
      _harness(const MunicipalityOnboardingScreen(), <Override>[
        municipalitiesViewModelProvider.overrideWith(
          _FakeMunicipalitiesViewModel.new,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sollana'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sollana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'news list fits filters and a long Valencian title at 200 percent',
    (WidgetTester tester) async {
      await useSmallPhone(tester);
      await tester.pumpWidget(
        _harness(const NewsScreen(), <Override>[
          sessionViewModelProvider.overrideWith(_FakeSessionViewModel.new),
          newsViewModelProvider.overrideWith(_FakeNewsViewModel.new),
        ]),
      );
      await tester.pumpAndSettle();

      // The featured hero card (a new, larger element) now sits above the
      // tabs, matching the Stitch reference layout order — at 200% text
      // scale on a 320dp phone that's enough to push them off the first
      // screenful, same as the onboarding list below.
      await tester.scrollUntilVisible(
        find.text('Actualitat'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Actualitat'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('news detail and attachment fit at 200 percent', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(
      _harness(const NewsDetailScreen(newsId: 'news-1'), <Override>[
        sessionViewModelProvider.overrideWith(_FakeSessionViewModel.new),
        newsDetailViewModelProvider.overrideWith(_FakeNewsDetailViewModel.new),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Adjunts'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Adjunts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home shows the severity level for an active red alert', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(
      _harness(const HomeScreen(), <Override>[
        sessionViewModelProvider.overrideWith(_FakeSessionViewModel.new),
        newsViewModelProvider.overrideWith(_FakeNewsViewModel.new),
        alertsViewModelProvider.overrideWith(_FakeRedAlertsViewModel.new),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Avís roig · Nivell 3'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Avís roig · Nivell 3'), findsOneWidget);
    expect(find.text('Pluges intenses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alert detail renders and scrolls at 200 percent', (
    WidgetTester tester,
  ) async {
    await useSmallPhone(tester);
    await tester.pumpWidget(
      _harness(const AlertDetailScreen(alertId: 'alert-1'), <Override>[
        sessionViewModelProvider.overrideWith(_FakeSessionViewModel.new),
        alertDetailViewModelProvider.overrideWith(
          _FakeAlertDetailViewModel.new,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    final severity = find.textContaining('Nivell 2');
    expect(severity, findsOneWidget);
    expect(tester.getSize(severity).height, greaterThan(40));
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Evita desplaçaments innecessaris durant les pluges intenses.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pluges intenses a Sollana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
