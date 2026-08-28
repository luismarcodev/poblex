import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_alert.dart';
import '../../domain/usecases/alert_usecases.dart';

class AlertEditorUiState extends Equatable {
  const AlertEditorUiState({this.item});

  final ManagedAlert? item;

  @override
  List<Object?> get props => [item];
}

final alertEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<AlertEditorViewModel, AlertEditorUiState>(
      AlertEditorViewModel.new,
    );

class AlertEditorViewModel
    extends AutoDisposeAsyncNotifier<AlertEditorUiState> {
  @override
  AlertEditorUiState build() => const AlertEditorUiState();

  Future<void> load({
    required String id,
    required String municipalityId,
    ManagedAlert? initial,
  }) async {
    if (initial != null && initial.municipalityId == municipalityId) {
      state = AsyncData(AlertEditorUiState(item: initial));
      return;
    }
    state = const AsyncLoading();
    final result = await getIt<GetManagedAlertDetail>()(
      id: id,
      municipalityId: municipalityId,
    );
    state = switch (result) {
      Success(value: final item) => AsyncData(AlertEditorUiState(item: item)),
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<AppFailure?> save(SaveManualAlertInput input) async {
    final previous = state.valueOrNull ?? const AlertEditorUiState();
    if (previous.item case final item? when !item.canManage) {
      return const ValidationFailure(message: 'alert_aemet_read_only');
    }

    state = const AsyncLoading();
    final result = await getIt<SaveManualAlert>()(input);
    return switch (result) {
      Success(value: final item) => _complete(item),
      Failure(error: final error) => _fail(previous, error),
    };
  }

  AppFailure? _complete(ManagedAlert item) {
    state = AsyncData(AlertEditorUiState(item: item));
    return null;
  }

  AppFailure _fail(AlertEditorUiState previous, AppFailure error) {
    state = AsyncData(previous);
    return error;
  }
}
