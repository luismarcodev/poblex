import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/alert.dart';
import '../../domain/usecases/alert_usecases.dart';

final alertDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<AlertDetailViewModel, AlertDetailUiState, String>(
      AlertDetailViewModel.new,
    );

class AlertDetailUiState extends Equatable {
  const AlertDetailUiState({this.alert, this.failure});

  final MunicipalAlert? alert;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[alert, failure];
}

class AlertDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<AlertDetailUiState, String> {
  late final GetAlertDetail _getDetail = getIt<GetAlertDetail>();

  @override
  Future<AlertDetailUiState> build(String arg) => _load(arg);

  Future<AlertDetailUiState> _load(String id) async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const AlertDetailUiState(failure: ValidationFailure());
    }
    final Result<MunicipalAlert> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<MunicipalAlert>(:final value) => AlertDetailUiState(alert: value),
      Failed<MunicipalAlert>(:final failure) => AlertDetailUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<AlertDetailUiState>();
    state = AsyncData<AlertDetailUiState>(await _load(arg));
  }
}
