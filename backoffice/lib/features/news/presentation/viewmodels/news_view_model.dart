import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/news_usecases.dart';

class NewsUiState extends Equatable {
  const NewsUiState({
    required this.municipalityId,
    required this.items,
    required this.includeArchived,
    required this.nextCursor,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<NewsItem> items;
  final bool includeArchived;
  final String? nextCursor;
  final Set<String> busyIds;
  final bool isLoadingMore;

  NewsUiState copyWith({
    String? municipalityId,
    List<NewsItem>? items,
    bool? includeArchived,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => NewsUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
    includeArchived: includeArchived ?? this.includeArchived,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includeArchived,
    nextCursor,
    busyIds,
    isLoadingMore,
  ];
}

final newsViewModelProvider = AsyncNotifierProvider<NewsViewModel, NewsUiState>(
  NewsViewModel.new,
);

class NewsViewModel extends AsyncNotifier<NewsUiState> {
  bool _includeArchived = false;
  int _revision = 0;

  @override
  Future<NewsUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedNews>()(
      municipalityId: municipalityId,
      includeArchived: _includeArchived,
    );
    return switch (result) {
      Success(value: final page) => NewsUiState(
        municipalityId: municipalityId,
        items: page.items,
        includeArchived: _includeArchived,
        nextCursor: page.nextCursor,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setIncludeArchived(bool value) async {
    if (_includeArchived == value) return;
    _includeArchived = value;
    ref.invalidateSelf();
    await future;
  }

  Future<AppFailure?> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return null;
    }
    final requestedCursor = current.nextCursor!;
    final requestedRevision = _revision;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<GetManagedNews>()(
      municipalityId: current.municipalityId,
      includeArchived: current.includeArchived,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.municipalityId != current.municipalityId ||
        latest.includeArchived != current.includeArchived ||
        latest.nextCursor != requestedCursor) {
      return null;
    }
    if (result case Success(value: final page)) {
      final existingIds = latest.items.map((item) => item.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((item) => existingIds.add(item.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedNewsPage>).error;
  }

  Future<AppFailure?> setPinned(NewsItem item) =>
      _mutate(item.id, () => getIt<SetNewsPinned>()(item.id, !item.pinned));

  Future<AppFailure?> setArchived(NewsItem item) =>
      _mutate(item.id, () => getIt<SetNewsArchived>()(item.id, !item.archived));

  Future<AppFailure?> delete(NewsItem item) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(item.id)) return null;
    _setBusy(item.id, true);
    final result = await getIt<DeleteNews>()(item.id);
    final latest = state.valueOrNull;
    if (latest == null || !latest.items.any((value) => value.id == item.id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(item.id, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((value) => value.id != item.id).toList(),
        busyIds: {...latest.busyIds}..remove(item.id),
      ),
    );
    return null;
  }

  Future<AppFailure?> _mutate(
    String id,
    Future<Result<NewsItem>> Function() action,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(id)) return null;
    _setBusy(id, true);
    final result = await action();
    final latest = state.valueOrNull;
    if (latest == null || !latest.items.any((item) => item.id == id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(id, false);
      return error;
    }
    final updated = (result as Success<NewsItem>).value;
    final updatedItems = latest.items
        .map((item) => item.id == updated.id ? updated : item)
        .where((item) => latest.includeArchived || !item.archived)
        .toList();
    state = AsyncData(
      latest.copyWith(
        items: updatedItems,
        busyIds: {...latest.busyIds}..remove(id),
      ),
    );
    return null;
  }

  void _setBusy(String id, bool busy) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.busyIds};
    busy ? ids.add(id) : ids.remove(id);
    state = AsyncData(current.copyWith(busyIds: ids));
  }
}
