import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_facility.dart';
import '../../domain/usecases/facility_usecases.dart';

class FacilitiesUiState extends Equatable {
  const FacilitiesUiState({required this.municipalityId, required this.items});

  final String municipalityId;
  final List<ManagedFacility> items;

  FacilitiesUiState copyWith({
    String? municipalityId,
    List<ManagedFacility>? items,
  }) => FacilitiesUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
  );

  @override
  List<Object?> get props => [municipalityId, items];
}

final facilitiesViewModelProvider =
    AsyncNotifierProvider<FacilitiesViewModel, FacilitiesUiState>(
      FacilitiesViewModel.new,
    );

class FacilitiesViewModel extends AsyncNotifier<FacilitiesUiState> {
  @override
  Future<FacilitiesUiState> build() async {
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedFacilities>()(
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success(value: final page) => FacilitiesUiState(
        municipalityId: municipalityId,
        items: page.items,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
