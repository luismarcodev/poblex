import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_form.dart';
import '../../domain/usecases/form_usecases.dart';

class FormEditorUiState extends Equatable {
  const FormEditorUiState();
  @override
  List<Object?> get props => const [];
}

final formEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<FormEditorViewModel, FormEditorUiState>(
      FormEditorViewModel.new,
    );

class FormEditorViewModel extends AutoDisposeAsyncNotifier<FormEditorUiState> {
  @override
  FormEditorUiState build() => const FormEditorUiState();

  Future<AppFailure?> create(CreateFormInput input) async {
    state = const AsyncLoading();
    final result = await getIt<CreateManagedForm>()(input);
    state = const AsyncData(FormEditorUiState());
    return switch (result) {
      Success() => null,
      Failure(error: final error) => error,
    };
  }
}
