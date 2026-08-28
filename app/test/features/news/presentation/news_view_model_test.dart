import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/errors/failure.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/news/domain/entities/news_item.dart';
import 'package:poblex/features/news/domain/repositories/news_repository.dart';
import 'package:poblex/features/news/domain/usecases/news_usecases.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';
import 'package:poblex/features/news/presentation/viewmodels/news_detail_view_model.dart';
import 'package:poblex/features/news/presentation/viewmodels/news_view_model.dart';

class _ControlledSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => const SessionState(
    deviceId: 'device-1',
    municipalityId: 'municipality-1',
    municipalityName: 'Sollana',
    municipalitySlug: 'sollana',
    deviceLocale: AppLocale.es,
  );

  void changeLocale(AppLocale locale) {
    state = AsyncData<SessionState>(
      state.requireValue.copyWith(localeOverride: locale),
    );
  }

  void changeMunicipality(String municipalityId) {
    state = AsyncData<SessionState>(
      state.requireValue.copyWith(municipalityId: municipalityId),
    );
  }
}

class _CountingNewsRepository implements NewsRepository {
  int listCalls = 0;
  int detailCalls = 0;
  AppFailure? nextListFailure;
  List<NewsItem> items = const <NewsItem>[];

  @override
  Future<Result<List<String>>> categories(String municipalityId) async =>
      const Success<List<String>>(<String>['general']);

  @override
  Future<Result<NewsItem>> detail({
    required String id,
    required String municipalityId,
  }) async {
    detailCalls++;
    // The dependency behaviour is what this test exercises. A typed failure
    // avoids constructing irrelevant article content.
    return const Failed<NewsItem>(UnknownFailure());
  }

  @override
  Future<Result<NewsPage>> list({
    required String municipalityId,
    required bool archived,
    String? category,
    String? cursor,
  }) async {
    listCalls++;
    final AppFailure? failure = nextListFailure;
    nextListFailure = null;
    if (failure != null) return Failed<NewsPage>(failure);
    return Success<NewsPage>(
      NewsPage(pinned: const <NewsItem>[], items: items),
    );
  }
}

final NewsItem _currentNews = NewsItem(
  id: 'news-1',
  municipalityId: 'municipality-1',
  title: const LocalizedText(es: 'Noticia actual', va: 'Notícia actual'),
  body: const LocalizedText(es: 'Contenido', va: 'Contingut'),
  category: 'general',
  pinned: false,
  publishedAt: DateTime.utc(2026, 8, 10),
  archived: false,
  attachments: const <NewsAttachment>[],
);

void main() {
  late _CountingNewsRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _CountingNewsRepository();
    getIt
      ..registerSingleton<GetNews>(GetNews(repository))
      ..registerSingleton<GetNewsCategories>(GetNewsCategories(repository))
      ..registerSingleton<GetNewsDetail>(GetNewsDetail(repository));
    container = ProviderContainer(
      overrides: <Override>[
        sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'locale changes repaint content without refetching the news APIs',
    () async {
      await container.read(newsViewModelProvider.future);
      await container.read(newsDetailViewModelProvider('news-1').future);
      expect(repository.listCalls, 1);
      expect(repository.detailCalls, 1);

      (container.read(sessionViewModelProvider.notifier)
              as _ControlledSessionViewModel)
          .changeLocale(AppLocale.va);
      await Future<void>.delayed(Duration.zero);

      expect(repository.listCalls, 1);
      expect(repository.detailCalls, 1);
    },
  );

  test('municipality changes invalidate list and detail providers', () async {
    await container.read(newsViewModelProvider.future);
    await container.read(newsDetailViewModelProvider('news-1').future);

    (container.read(sessionViewModelProvider.notifier)
            as _ControlledSessionViewModel)
        .changeMunicipality('municipality-2');
    await container.read(newsViewModelProvider.future);
    await container.read(newsDetailViewModelProvider('news-1').future);

    expect(repository.listCalls, 2);
    expect(repository.detailCalls, 2);
  });

  test('a failed tab change never shows items from the previous tab', () async {
    repository.items = <NewsItem>[_currentNews];
    final NewsUiState initial = await container.read(
      newsViewModelProvider.future,
    );
    expect(initial.items, <NewsItem>[_currentNews]);

    repository.nextListFailure = const NetworkFailure();
    await container.read(newsViewModelProvider.notifier).setArchived(true);
    final NewsUiState failed = container
        .read(newsViewModelProvider)
        .requireValue;

    expect(failed.archived, isTrue);
    expect(failed.items, isEmpty);
    expect(failed.failure, const NetworkFailure());
  });
}
