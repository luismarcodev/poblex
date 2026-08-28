import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_survey.dart';
import '../../domain/usecases/survey_usecases.dart';

class SurveyEditorUiState extends Equatable {
  const SurveyEditorUiState();

  @override
  List<Object?> get props => const [];
}

final surveyEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      SurveyEditorViewModel,
      SurveyEditorUiState
    >(SurveyEditorViewModel.new);

class SurveyEditorViewModel
    extends AutoDisposeAsyncNotifier<SurveyEditorUiState> {
  @override
  SurveyEditorUiState build() => const SurveyEditorUiState();

  Future<AppFailure?> create(CreateSurveyInput input) async {
    state = const AsyncLoading();
    final result = await getIt<CreateSurvey>()(input);
    state = const AsyncData(SurveyEditorUiState());
    return switch (result) {
      Success() => null,
      Failure(error: final error) => error,
    };
  }
}
