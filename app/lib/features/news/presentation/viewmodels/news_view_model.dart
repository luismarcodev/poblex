import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/news_usecases.dart';

final newsViewModelProvider = AsyncNotifierProvider<NewsViewModel, NewsUiState>(
  NewsViewModel.new,
);

class NewsUiState extends Equatable {
  const NewsUiState({
    this.pinned = const <NewsItem>[],
    this.items = const <NewsItem>[],
    this.categories = const <String>[],
    this.archived = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.category,
    this.nextCursor,
  });

  final List<NewsItem> pinned;
  final List<NewsItem> items;
  final List<String> categories;
  final bool archived;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? category;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;

  NewsUiState copyWith({
    List<NewsItem>? pinned,
    List<NewsItem>? items,
    List<String>? categories,
    bool? archived,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? category,
    bool clearCategory = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => NewsUiState(
    pinned: pinned ?? this.pinned,
    items: items ?? this.items,
    categories: categories ?? this.categories,
    archived: archived ?? this.archived,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    category: clearCategory ? null : category ?? this.category,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    pinned,
    items,
    categories,
    archived,
    refreshing,
    loadingMore,
    failure,
    category,
    nextCursor,
  ];
}

class NewsViewModel extends AsyncNotifier<NewsUiState> {
  late final GetNews _getNews = getIt<GetNews>();
  late final GetNewsCategories _getCategories = getIt<GetNewsCategories>();
  int _requestVersion = 0;

  @override
  Future<NewsUiState> build() async {
    // News payloads contain both languages, so changing only the interface
    // locale must repaint the cards but must not repeat both HTTP requests.
    // This dependency invalidates the provider only when the municipality
    // itself changes.
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const NewsUiState(failure: ValidationFailure());
    }
    return _load(municipalityId: municipalityId, base: const NewsUiState());
  }

  Future<NewsUiState> _load({
    required String municipalityId,
    required NewsUiState base,
  }) async {
    final Future<Result<NewsPage>> pageFuture = _getNews(
      municipalityId: municipalityId,
      archived: base.archived,
      category: base.category,
    );
    final Future<Result<List<String>>> categoriesFuture = _getCategories(
      municipalityId,
    );
    final (Result<NewsPage>, Result<List<String>>) results = await (
      pageFuture,
      categoriesFuture,
    ).wait;

    final Result<NewsPage> page = results.$1;
    final List<String> categories = switch (results.$2) {
      Success<List<String>>(:final value) => value,
      Failed<List<String>>() => base.categories,
    };
    return switch (page) {
      Success<NewsPage>(:final value) => base.copyWith(
        pinned: value.pinned,
        items: value.items,
        categories: categories,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<NewsPage>(:final failure) => base.copyWith(
        categories: categories,
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final NewsUiState current = state.value ?? const NewsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    final bool hasContent =
        current.items.isNotEmpty || current.pinned.isNotEmpty;
    state = hasContent
        ? AsyncData<NewsUiState>(
            current.copyWith(
              refreshing: true,
              loadingMore: false,
              clearFailure: true,
            ),
          )
        : const AsyncLoading<NewsUiState>();
    final NewsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<NewsUiState>(loaded);
    }
  }

  Future<void> setArchived(bool archived) async {
    final NewsUiState current = state.value ?? const NewsUiState();
    if (current.archived == archived) return;
    await _replaceSelection(
      NewsUiState(
        categories: current.categories,
        archived: archived,
        category: current.category,
      ),
    );
  }

  Future<void> setCategory(String? category) async {
    final NewsUiState current = state.value ?? const NewsUiState();
    if (current.category == category) return;
    await _replaceSelection(
      NewsUiState(
        categories: current.categories,
        archived: current.archived,
        category: category,
      ),
    );
  }

  Future<void> _replaceSelection(NewsUiState next) async {
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = const AsyncLoading<NewsUiState>();
    final NewsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: next,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<NewsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final NewsUiState current = state.value ?? const NewsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<NewsUiState>(current.copyWith(loadingMore: true));
    final Result<NewsPage> result = await _getNews(
      municipalityId: municipalityId,
      archived: current.archived,
      category: current.category,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<NewsUiState>(switch (result) {
      Success<NewsPage>(:final value) => current.copyWith(
        items: <NewsItem>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<NewsPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }
}
