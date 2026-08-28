import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/usecases/survey_usecases.dart';

final surveyDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<SurveyDetailViewModel, SurveyDetailUiState, String>(
      SurveyDetailViewModel.new,
    );

class SurveyDetailUiState extends Equatable {
  const SurveyDetailUiState({this.survey, this.voting = false, this.failure});

  final Survey? survey;
  final bool voting;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[survey, voting, failure];
}

class SurveyDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<SurveyDetailUiState, String> {
  late final GetSurveyDetail _getDetail = getIt<GetSurveyDetail>();
  late final VoteSurvey _voteSurvey = getIt<VoteSurvey>();

  @override
  Future<SurveyDetailUiState> build(String arg) => _load(arg);

  Future<SurveyDetailUiState> _load(String id) async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const SurveyDetailUiState(failure: ValidationFailure());
    }
    final Result<Survey> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<Survey>(:final value) => SurveyDetailUiState(survey: value),
      Failed<Survey>(:final failure) => SurveyDetailUiState(failure: failure),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<SurveyDetailUiState>();
    state = AsyncData<SurveyDetailUiState>(await _load(arg));
  }

  Future<Result<void>> vote(String optionId) async {
    final SurveyDetailUiState current = state.requireValue;
    state = AsyncData<SurveyDetailUiState>(
      SurveyDetailUiState(survey: current.survey, voting: true),
    );
    final Result<void> result = await _voteSurvey(
      surveyId: arg,
      optionId: optionId,
    );
    if (result.isSuccess) {
      // The list endpoint never resolves per-device tallies, so the only
      // reliable way to show the just-cast vote and updated counts is to
      // reload the detail rather than optimistically guessing them.
      state = AsyncData<SurveyDetailUiState>(await _load(arg));
    } else {
      state = AsyncData<SurveyDetailUiState>(
        SurveyDetailUiState(
          survey: current.survey,
          failure: (result as Failed<void>).failure,
        ),
      );
    }
    return result;
  }
}
