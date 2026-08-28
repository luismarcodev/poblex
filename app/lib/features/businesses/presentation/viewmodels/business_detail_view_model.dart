import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/business.dart';
import '../../domain/usecases/business_usecases.dart';

final businessDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<BusinessDetailViewModel, BusinessDetailUiState, String>(
      BusinessDetailViewModel.new,
    );

class BusinessDetailUiState extends Equatable {
  const BusinessDetailUiState({this.business, this.failure});

  final MunicipalBusiness? business;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[business, failure];
}

class BusinessDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<BusinessDetailUiState, String> {
  late final GetBusinessDetail _getDetail = getIt<GetBusinessDetail>();

  @override
  Future<BusinessDetailUiState> build(String arg) => _load(arg);

  Future<BusinessDetailUiState> _load(String id) async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const BusinessDetailUiState(failure: ValidationFailure());
    }
    final Result<MunicipalBusiness> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<MunicipalBusiness>(:final value) => BusinessDetailUiState(
        business: value,
      ),
      Failed<MunicipalBusiness>(:final failure) => BusinessDetailUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<BusinessDetailUiState>();
    state = AsyncData<BusinessDetailUiState>(await _load(arg));
  }
}
