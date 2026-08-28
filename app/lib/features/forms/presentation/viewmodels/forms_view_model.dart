import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/form.dart';
import '../../domain/usecases/form_usecases.dart';

final formsViewModelProvider =
    AsyncNotifierProvider<FormsViewModel, FormsUiState>(FormsViewModel.new);

class FormsUiState extends Equatable {
  const FormsUiState({
    this.items = const <MunicipalForm>[],
    this.includeClosed = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.nextCursor,
  });

  final List<MunicipalForm> items;
  final bool includeClosed;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  FormsUiState copyWith({
    List<MunicipalForm>? items,
    bool? includeClosed,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => FormsUiState(
    items: items ?? this.items,
    includeClosed: includeClosed ?? this.includeClosed,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    includeClosed,
    refreshing,
    loadingMore,
    failure,
    nextCursor,
  ];
}

class FormsViewModel extends AsyncNotifier<FormsUiState> {
  late final GetForms _getForms = getIt<GetForms>();
  int _requestVersion = 0;

  @override
  Future<FormsUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const FormsUiState(failure: ValidationFailure());
    }
    return _load(municipalityId: municipalityId, base: const FormsUiState());
  }

  Future<FormsUiState> _load({
    required String municipalityId,
    required FormsUiState base,
  }) async {
    final Result<FormPage> result = await _getForms(
      municipalityId: municipalityId,
      includeClosed: base.includeClosed,
    );
    return switch (result) {
      Success<FormPage>(:final value) => base.copyWith(
        items: value.items,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<FormPage>(:final failure) => base.copyWith(
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final FormsUiState current = state.value ?? const FormsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<FormsUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<FormsUiState>();
    final FormsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<FormsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final FormsUiState current = state.value ?? const FormsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<FormsUiState>(current.copyWith(loadingMore: true));
    final Result<FormPage> result = await _getForms(
      municipalityId: municipalityId,
      includeClosed: current.includeClosed,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<FormsUiState>(switch (result) {
      Success<FormPage>(:final value) => current.copyWith(
        items: <MunicipalForm>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<FormPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }

  Future<void> setIncludeClosed(bool includeClosed) async {
    final FormsUiState current = state.value ?? const FormsUiState();
    if (current.includeClosed == includeClosed) return;
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    final FormsUiState base = current.copyWith(includeClosed: includeClosed);
    state = const AsyncLoading<FormsUiState>();
    final FormsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: base,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<FormsUiState>(loaded);
    }
  }
}
