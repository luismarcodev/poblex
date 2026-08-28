import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/business.dart';
import '../../domain/usecases/business_usecases.dart';

final businessesViewModelProvider =
    AsyncNotifierProvider<BusinessesViewModel, BusinessesUiState>(
      BusinessesViewModel.new,
    );

class BusinessesUiState extends Equatable {
  const BusinessesUiState({
    this.items = const <MunicipalBusiness>[],
    this.categories = const <String>[],
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.category,
    this.nextCursor,
  });

  final List<MunicipalBusiness> items;
  final List<String> categories;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? category;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  BusinessesUiState copyWith({
    List<MunicipalBusiness>? items,
    List<String>? categories,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? category,
    bool clearCategory = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => BusinessesUiState(
    items: items ?? this.items,
    categories: categories ?? this.categories,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    category: clearCategory ? null : category ?? this.category,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    categories,
    refreshing,
    loadingMore,
    failure,
    category,
    nextCursor,
  ];
}

class BusinessesViewModel extends AsyncNotifier<BusinessesUiState> {
  late final GetBusinesses _getBusinesses = getIt<GetBusinesses>();
  late final GetBusinessCategories _getCategories =
      getIt<GetBusinessCategories>();
  int _requestVersion = 0;

  @override
  Future<BusinessesUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const BusinessesUiState(failure: ValidationFailure());
    }
    return _load(
      municipalityId: municipalityId,
      base: const BusinessesUiState(),
    );
  }

  Future<BusinessesUiState> _load({
    required String municipalityId,
    required BusinessesUiState base,
  }) async {
    final Future<Result<BusinessPage>> pageFuture = _getBusinesses(
      municipalityId: municipalityId,
      category: base.category,
    );
    final Future<Result<List<String>>> categoriesFuture = _getCategories(
      municipalityId,
    );
    final (Result<BusinessPage>, Result<List<String>>) results = await (
      pageFuture,
      categoriesFuture,
    ).wait;

    final Result<BusinessPage> page = results.$1;
    final List<String> categories = switch (results.$2) {
      Success<List<String>>(:final value) => value,
      Failed<List<String>>() => base.categories,
    };
    return switch (page) {
      Success<BusinessPage>(:final value) => base.copyWith(
        items: value.items,
        categories: categories,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<BusinessPage>(:final failure) => base.copyWith(
        categories: categories,
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final BusinessesUiState current = state.value ?? const BusinessesUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<BusinessesUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<BusinessesUiState>();
    final BusinessesUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<BusinessesUiState>(loaded);
    }
  }

  Future<void> setCategory(String? category) async {
    final BusinessesUiState current = state.value ?? const BusinessesUiState();
    if (current.category == category) return;
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = const AsyncLoading<BusinessesUiState>();
    final BusinessesUiState loaded = await _load(
      municipalityId: municipalityId,
      base: BusinessesUiState(
        categories: current.categories,
        category: category,
      ),
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<BusinessesUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final BusinessesUiState current = state.value ?? const BusinessesUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<BusinessesUiState>(current.copyWith(loadingMore: true));
    final Result<BusinessPage> result = await _getBusinesses(
      municipalityId: municipalityId,
      category: current.category,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<BusinessesUiState>(switch (result) {
      Success<BusinessPage>(:final value) => current.copyWith(
        items: <MunicipalBusiness>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<BusinessPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }
}
