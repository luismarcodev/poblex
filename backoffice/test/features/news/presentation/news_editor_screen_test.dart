import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';
import 'package:poblex_backoffice/features/news/presentation/screens/news_editor_screen.dart';
import 'package:poblex_backoffice/features/news/presentation/platform/news_attachment_picker.dart';
import 'package:poblex_backoffice/features/news/presentation/viewmodels/news_editor_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

const profile = ManagerProfile(
  id: 'manager',
  email: 'gestor@sollana.es',
  displayName: 'Gestor municipal',
  municipalities: [municipality],
);

class FakeAuthViewModel extends AuthViewModel {
  @override
  Future<ManagerProfile?> build() async => profile;
}

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeEditorViewModel extends NewsEditorViewModel {
  SaveNewsInput? savedInput;
  NewsAttachmentUploadFile? uploadedFile;
  int loadCalls = 0;
  bool failLoad = false;

  @override
  NewsEditorUiState build() => const NewsEditorUiState();

  @override
  Future<AppFailure?> save(SaveNewsInput input) async {
    savedInput = input;
    return null;
  }

  @override
  Future<AppFailure?> uploadAttachment(NewsAttachmentUploadFile file) async {
    uploadedFile = file;
    final current = state.requireValue;
    final item = current.item!;
    state = AsyncData(
      current.copyWith(
        item: item.copyWith(
          attachments: [
            ...item.attachments,
            const NewsAttachment(
              id: 'attachment-1',
              name: 'bando.pdf',
              url: 'https://cdn.test/bando.pdf',
              mimeType: 'application/pdf',
            ),
          ],
        ),
      ),
    );
    return null;
  }

  @override
  Future<void> load(String id, {NewsItem? initial}) async {
    loadCalls++;
    if (failLoad) {
      state = const AsyncError(
        NetworkFailure(message: 'offline'),
        StackTrace.empty,
      );
      return;
    }
    await super.load(id, initial: initial);
  }
}

void main() {
  testWidgets('validates and publishes a news item on compact 200% text', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 4000);
    late FakeEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => const Scaffold(body: NewsEditorScreen()),
        ),
        GoRoute(
          path: '/noticias',
          builder: (_, _) => const Scaffold(body: Text('Listado')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _app(
        router,
        newsEditorViewModelProvider.overrideWith(() {
          fake = FakeEditorViewModel();
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final publish = find.widgetWithText(FilledButton, 'Publicar noticia');
    await tester.ensureVisible(publish);
    await tester.pump();
    await tester.tap(publish);
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(3));
    expect(fake.savedInput, isNull);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Aviso de fiestas');
    await tester.enterText(fields.at(1), 'Contenido municipal');
    await tester.enterText(fields.at(4), 'general');
    await tester.ensureVisible(publish);
    await tester.pump();
    await tester.tap(publish);
    await tester.pumpAndSettle();

    expect(fake.savedInput?.municipalityIds, [municipality.id]);
    expect(fake.savedInput?.title.es, 'Aviso de fiestas');
    expect(find.text('Listado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the network error and allows retrying a direct edit', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 420);
    late FakeEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) =>
              const Scaffold(body: NewsEditorScreen(newsId: 'news-1')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _app(
        router,
        newsEditorViewModelProvider.overrideWith(() {
          fake = FakeEditorViewModel()..failLoad = true;
          return fake;
        }),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(fake.loadCalls, 1);
    expect(find.text('No se puede conectar con el servidor.'), findsOneWidget);
    final retry = find.widgetWithText(FilledButton, 'Reintentar');
    await tester.ensureVisible(retry);
    await tester.pump();
    await tester.tap(retry);
    await tester.pump();
    expect(fake.loadCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects, uploads and lists an attachment at 200% text', (
    tester,
  ) async {
    _setCompactLargeText(tester, height: 4000);
    late FakeEditorViewModel fake;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => Scaffold(
            body: NewsEditorScreen(
              newsId: 'news-1',
              initialNews: _news,
              attachmentPicker: () async => PickedNewsAttachment(
                name: 'bando.pdf',
                bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _app(
        router,
        newsEditorViewModelProvider.overrideWith(() {
          fake = FakeEditorViewModel();
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    final addAttachment = find.widgetWithText(OutlinedButton, 'Añadir adjunto');
    await tester.ensureVisible(addAttachment);
    await tester.tap(addAttachment);
    await tester.pumpAndSettle();

    expect(fake.uploadedFile?.name, 'bando.pdf');
    expect(find.text('bando.pdf'), findsOneWidget);
    expect(find.text('application/pdf'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _news = NewsItem(
  id: 'news-1',
  municipalityId: municipality.id,
  title: const LocalizedText(es: 'Bando municipal'),
  body: const LocalizedText(es: 'Información importante'),
  category: 'general',
  pinned: false,
  publishedAt: DateTime.utc(2026, 8, 10),
  archived: false,
  attachments: const [],
);

Widget _app(GoRouter router, Override editorOverride) => ProviderScope(
  overrides: [
    authViewModelProvider.overrideWith(FakeAuthViewModel.new),
    selectedMunicipalityProvider.overrideWith(FakeMunicipalityViewModel.new),
    editorOverride,
  ],
  child: MaterialApp.router(
    locale: const Locale('es'),
    theme: AppTheme.light(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ),
);

void _setCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
