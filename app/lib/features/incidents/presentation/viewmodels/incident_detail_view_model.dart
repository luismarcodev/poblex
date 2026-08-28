import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/incident_usecases.dart';

final incidentDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<IncidentDetailViewModel, IncidentDetailUiState, String>(
      IncidentDetailViewModel.new,
    );

class IncidentDetailUiState extends Equatable {
  const IncidentDetailUiState({this.detail, this.failure});

  final IncidentDetail? detail;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[detail, failure];
}

class IncidentDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<IncidentDetailUiState, String> {
  late final GetMyIncidentDetail _getDetail = getIt<GetMyIncidentDetail>();

  @override
  Future<IncidentDetailUiState> build(String arg) => _load(arg);

  Future<IncidentDetailUiState> _load(String id) async {
    final Result<IncidentDetail> result = await _getDetail(id);
    return switch (result) {
      Success<IncidentDetail>(:final value) => IncidentDetailUiState(
        detail: value,
      ),
      Failed<IncidentDetail>(:final failure) => IncidentDetailUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<IncidentDetailUiState>();
    state = AsyncData<IncidentDetailUiState>(await _load(arg));
  }
}
