import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';
import 'package:poblex_backoffice/features/news/presentation/screens/news_screen.dart';
import 'package:poblex_backoffice/features/news/presentation/viewmodels/news_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeNewsViewModel extends NewsViewModel {
  FakeNewsViewModel(this.loader);

  final Future<NewsUiState> Function() loader;
  int refreshCalls = 0;
  int filterCalls = 0;
  int pinCalls = 0;

  @override
  Future<NewsUiState> build() => loader();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<void> setIncludeArchived(bool value) async {
    filterCalls++;
  }

  @override
  Future<AppFailure?> setPinned(NewsItem item) async {
    pinCalls++;
    return null;
  }
}

void main() {
  testWidgets(
    'renders Valencian content and actions without compact overflow',
    (tester) async {
      _configureCompactLargeText(tester);
      final state = NewsUiState(
        municipalityId: 'sollana',
        items: [_news()],
        includeArchived: false,
        nextCursor: null,
      );
      late FakeNewsViewModel fake;

      await tester.pumpWidget(
        _app(
          locale: const Locale('ca'),
          override: newsViewModelProvider.overrideWith(() {
            fake = FakeNewsViewModel(() async => state);
            return fake;
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Títol valencià'), findsOneWidget);
      expect(find.text('Contingut valencià'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final pinButton = find.widgetWithText(TextButton, 'Destacar');
      await tester.ensureVisible(pinButton);
      await tester.pumpAndSettle();
      await tester.tap(pinButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Destacar'));
      await tester.pump();
      expect(fake.pinCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows an empty state when the municipality has no news', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        override: newsViewModelProvider.overrideWith(
          () => FakeNewsViewModel(
            () async => const NewsUiState(
              municipalityId: 'sollana',
              items: [],
              includeArchived: false,
              nextCursor: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay noticias'), findsOneWidget);
    expect(
      find.text('Publica la primera noticia para este municipio.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps the network error actionable on a short viewport', (
    tester,
  ) async {
    _configureCompactLargeText(tester, height: 360);
    late FakeNewsViewModel fake;
    await tester.pumpWidget(
      _app(
        override: newsViewModelProvider.overrideWith(() {
          fake = FakeNewsViewModel(
            () async => throw const NetworkFailure(message: 'offline'),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('No se puede conectar con el servidor.'), findsOneWidget);
    final retry = find.widgetWithText(FilledButton, 'Reintentar');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pump();
    expect(fake.refreshCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces loading while the first page is pending', (
    tester,
  ) async {
    final pending = Completer<NewsUiState>();
    await tester.pumpWidget(
      _app(
        override: newsViewModelProvider.overrideWith(
          () => FakeNewsViewModel(() => pending.future),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
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
        home: const Scaffold(body: NewsScreen()),
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

NewsItem _news() => NewsItem(
  id: 'news-1',
  municipalityId: 'sollana',
  title: const LocalizedText(es: 'Título castellano', va: 'Títol valencià'),
  body: const LocalizedText(
    es: 'Contenido castellano',
    va: 'Contingut valencià',
  ),
  category: 'general',
  pinned: false,
  publishedAt: DateTime.utc(2026, 8, 1),
  archived: false,
  attachments: const [],
);
