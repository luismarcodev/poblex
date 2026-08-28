import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/news_usecases.dart';

final newsDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<NewsDetailViewModel, NewsDetailUiState, String>(
      NewsDetailViewModel.new,
    );

class NewsDetailUiState extends Equatable {
  const NewsDetailUiState({this.item, this.failure});
  final NewsItem? item;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[item, failure];
}

class NewsDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<NewsDetailUiState, String> {
  late final GetNewsDetail _getDetail = getIt<GetNewsDetail>();

  @override
  Future<NewsDetailUiState> build(String arg) => _load(arg);

  Future<NewsDetailUiState> _load(String id) async {
    // The item is bilingual. A locale change only needs a widget rebuild, not
    // another detail request; a municipality change does require a refetch.
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const NewsDetailUiState(failure: ValidationFailure());
    }
    final Result<NewsItem> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<NewsItem>(:final value) => NewsDetailUiState(item: value),
      Failed<NewsItem>(:final failure) => NewsDetailUiState(failure: failure),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<NewsDetailUiState>();
    state = AsyncData<NewsDetailUiState>(await _load(arg));
  }
}
