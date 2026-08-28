import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/l10n/app_localizations.dart';
import 'package:poblex/shared/presentation/widgets/photo_gallery.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

// CachedNetworkImage would otherwise hit the real network in a test run.
// This makes every request fail fast and deterministically, which is all the
// gallery needs: its own errorWidget takes over from there.
class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FailFastClient();
}

class _FailFastClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future<HttpClientRequest>.error(
    const SocketException('no network in tests'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _harness(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FailFastHttpOverrides();
  });

  testWidgets('renders nothing for an empty photo list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(const PhotoGallery(photoUrls: <String>[])),
    );
    await tester.pump();

    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides navigation controls for a single photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const PhotoGallery(photoUrls: <String>['https://cdn.example/a.jpg']),
      ),
    );
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows pulsable arrows and dots for several photos, and paging with the arrow updates the announced photo',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          const PhotoGallery(
            photoUrls: <String>[
              'https://cdn.example/a.jpg',
              'https://cdn.example/b.jpg',
              'https://cdn.example/c.jpg',
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.bySemanticsLabel('Foto 1 de 3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Foto 2 de 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
