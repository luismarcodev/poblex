import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';
import 'package:poblex_backoffice/features/news/domain/repositories/news_repository.dart';
import 'package:poblex_backoffice/features/news/domain/usecases/news_usecases.dart';
import 'package:poblex_backoffice/features/news/presentation/viewmodels/news_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeNewsRepository implements NewsRepository {
  FakeNewsRepository(this.initialItems);

  final List<NewsItem> initialItems;
  final loadMoreResult = Completer<Result<ManagedNewsPage>>();
  final pinResults = <String, Completer<Result<NewsItem>>>{};
  int loadMoreCalls = 0;

  @override
  Future<Result<ManagedNewsPage>> getManagedNews({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  }) async {
    if (cursor == null) {
      return Success(ManagedNewsPage(items: initialItems, nextCursor: 'next'));
    }
    loadMoreCalls++;
    return loadMoreResult.future;
  }

  @override
  Future<Result<NewsItem>> setPinned(String id, bool pinned) {
    return pinResults.putIfAbsent(id, Completer<Result<NewsItem>>.new).future;
  }

  @override
  Future<Result<NewsItem>> setArchived(String id, bool archived) async {
    final item = initialItems.singleWhere((value) => value.id == id);
    return Success(_copy(item, archived: archived));
  }

  @override
  Future<Result<List<NewsItem>>> create(SaveNewsInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();

  @override
  Future<Result<NewsItem>> getById(String id) => throw UnimplementedError();

  @override
  Future<Result<NewsItem>> update(SaveNewsInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<NewsAttachment>> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  }) => throw UnimplementedError();

  @override
  Future<Result<NewsAttachmentUploadTarget>> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> uploadAttachmentBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) => throw UnimplementedError();
}

void main() {
  late FakeNewsRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeNewsRepository([_news('one'), _news('two')]);
    getIt.registerFactory(() => GetManagedNews(repository));
    getIt.registerFactory(() => SetNewsPinned(repository));
    getIt.registerFactory(() => SetNewsArchived(repository));
    getIt.registerFactory(() => DeleteNews(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(newsViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'prevents duplicate pagination requests and keeps data on failure',
    () async {
      final viewModel = container.read(newsViewModelProvider.notifier);

      final first = viewModel.loadMore();
      final duplicate = viewModel.loadMore();

      expect(repository.loadMoreCalls, 1);
      expect(
        container.read(newsViewModelProvider).value!.isLoadingMore,
        isTrue,
      );
      repository.loadMoreResult.complete(
        const Failure(NetworkFailure(message: 'offline')),
      );

      expect(await first, isA<NetworkFailure>());
      expect(await duplicate, isNull);
      final state = container.read(newsViewModelProvider).value!;
      expect(state.items.map((item) => item.id), ['one', 'two']);
      expect(state.isLoadingMore, isFalse);
    },
  );

  test('discards a stale pagination response after a refresh', () async {
    final viewModel = container.read(newsViewModelProvider.notifier);
    final pagination = viewModel.loadMore();

    await viewModel.refresh();
    repository.loadMoreResult.complete(
      Success(ManagedNewsPage(items: [_news('stale')], nextCursor: null)),
    );

    expect(await pagination, isNull);
    expect(
      container.read(newsViewModelProvider).value!.items.map((item) => item.id),
      ['one', 'two'],
    );
  });

  test('merges concurrent mutations without losing either response', () async {
    final viewModel = container.read(newsViewModelProvider.notifier);
    final one = repository.initialItems[0];
    final two = repository.initialItems[1];

    final first = viewModel.setPinned(one);
    final second = viewModel.setPinned(two);
    repository.pinResults['two']!.complete(Success(_copy(two, pinned: true)));
    await second;
    repository.pinResults['one']!.complete(Success(_copy(one, pinned: true)));
    await first;

    final items = container.read(newsViewModelProvider).value!.items;
    expect(items.every((item) => item.pinned), isTrue);
  });

  test('removes an archived item from the active-only list', () async {
    final viewModel = container.read(newsViewModelProvider.notifier);

    await viewModel.setArchived(repository.initialItems.first);

    expect(
      container.read(newsViewModelProvider).value!.items.map((item) => item.id),
      ['two'],
    );
  });
}

NewsItem _news(String id) => NewsItem(
  id: id,
  municipalityId: municipality.id,
  title: LocalizedText(es: 'Título $id', va: 'Títol $id'),
  body: LocalizedText(es: 'Contenido $id', va: 'Contingut $id'),
  category: 'general',
  pinned: false,
  publishedAt: DateTime.utc(2026, 8, 1),
  archived: false,
  attachments: const [],
);

NewsItem _copy(NewsItem item, {bool? pinned, bool? archived}) => NewsItem(
  id: item.id,
  municipalityId: item.municipalityId,
  title: item.title,
  body: item.body,
  category: item.category,
  pinned: pinned ?? item.pinned,
  publishedAt: item.publishedAt,
  archived: archived ?? item.archived,
  attachments: item.attachments,
  imageUrl: item.imageUrl,
);
