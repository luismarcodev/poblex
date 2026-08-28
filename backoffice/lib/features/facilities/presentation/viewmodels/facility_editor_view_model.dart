import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_facility.dart';
import '../../domain/usecases/facility_usecases.dart';

class FacilityEditorUiState extends Equatable {
  const FacilityEditorUiState({this.facility});
  final ManagedFacility? facility;

  @override
  List<Object?> get props => [facility];
}

final facilityEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      FacilityEditorViewModel,
      FacilityEditorUiState
    >(FacilityEditorViewModel.new);

class FacilityEditorViewModel
    extends AutoDisposeAsyncNotifier<FacilityEditorUiState> {
  @override
  FacilityEditorUiState build() => const FacilityEditorUiState();

  void hydrate(ManagedFacility facility) {
    state = AsyncData(FacilityEditorUiState(facility: facility));
  }

  Future<AppFailure?> save(SaveFacilityInput input) async {
    state = const AsyncLoading();
    final result = await getIt<SaveFacility>()(input);
    return switch (result) {
      Success(value: final facility) => _complete(facility),
      Failure(error: final error) => _fail(error),
    };
  }

  AppFailure? _complete(ManagedFacility facility) {
    state = AsyncData(FacilityEditorUiState(facility: facility));
    return null;
  }

  AppFailure _fail(AppFailure error) {
    state = AsyncData(state.valueOrNull ?? const FacilityEditorUiState());
    return error;
  }
}
