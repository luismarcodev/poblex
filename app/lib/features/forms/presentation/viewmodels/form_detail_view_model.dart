import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/form.dart';
import '../../domain/usecases/form_usecases.dart';

final formDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<FormDetailViewModel, FormDetailUiState, String>(
      FormDetailViewModel.new,
    );

class FormDetailUiState extends Equatable {
  const FormDetailUiState({
    this.form,
    this.answers = const <String, String>{},
    this.submitting = false,
    this.submitted = false,
    this.failure,
  });

  final MunicipalForm? form;
  final Map<String, String> answers;
  final bool submitting;
  final bool submitted;
  final AppFailure? failure;

  bool get canSubmit {
    final MunicipalForm? current = form;
    if (current == null || !current.canSubmit || submitting) return false;
    for (final FormFieldDefinition field in current.fields) {
      if (field.required && (answers[field.id] ?? '').trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  FormDetailUiState copyWith({
    MunicipalForm? form,
    Map<String, String>? answers,
    bool? submitting,
    bool? submitted,
    AppFailure? failure,
    bool clearFailure = false,
  }) => FormDetailUiState(
    form: form ?? this.form,
    answers: answers ?? this.answers,
    submitting: submitting ?? this.submitting,
    submitted: submitted ?? this.submitted,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    form,
    answers,
    submitting,
    submitted,
    failure,
  ];
}

class FormDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<FormDetailUiState, String> {
  late final GetFormDetail _getDetail = getIt<GetFormDetail>();
  late final SubmitForm _submitForm = getIt<SubmitForm>();

  @override
  Future<FormDetailUiState> build(String arg) => _load(arg);

  Future<FormDetailUiState> _load(String id) async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const FormDetailUiState(failure: ValidationFailure());
    }
    final Result<MunicipalForm> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<MunicipalForm>(:final value) => FormDetailUiState(form: value),
      Failed<MunicipalForm>(:final failure) => FormDetailUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<FormDetailUiState>();
    state = AsyncData<FormDetailUiState>(await _load(arg));
  }

  void setAnswer(String fieldId, String value) {
    final FormDetailUiState current = state.requireValue;
    state = AsyncData<FormDetailUiState>(
      current.copyWith(
        answers: <String, String>{...current.answers, fieldId: value},
      ),
    );
  }

  Future<void> submit() async {
    final FormDetailUiState current = state.requireValue;
    if (!current.canSubmit) return;
    state = AsyncData<FormDetailUiState>(
      current.copyWith(submitting: true, clearFailure: true),
    );
    final Result<void> result = await _submitForm(
      formId: arg,
      answers: current.answers,
    );
    state = AsyncData<FormDetailUiState>(switch (result) {
      Success<void>() => current.copyWith(submitting: false, submitted: true),
      Failed<void>(:final failure) => current.copyWith(
        submitting: false,
        failure: failure,
      ),
    });
  }
}
