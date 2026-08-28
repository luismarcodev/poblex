import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/facility.dart';
import '../../domain/usecases/facility_usecases.dart';

final facilitiesViewModelProvider =
    AsyncNotifierProvider<FacilitiesViewModel, FacilitiesUiState>(
      FacilitiesViewModel.new,
    );

class FacilitiesUiState extends Equatable {
  const FacilitiesUiState({
    this.allItems = const <Facility>[],
    this.refreshing = false,
    this.failure,
    this.category,
  });

  final List<Facility> allItems;
  final bool refreshing;
  final AppFailure? failure;
  final String? category;

  /// Un municipio tiene pocas instalaciones (padel, tenis, barbacoa...), así
  /// que el filtro de categoría se resuelve en cliente sobre la lista ya
  /// cargada — no hace falta un viaje de red extra por cada chip tocado.
  List<Facility> get items => category == null
      ? allItems
      : allItems
            .where((Facility facility) => facility.category == category)
            .toList(growable: false);

  bool get isEmpty => items.isEmpty;

  List<String> get availableCategories =>
      allItems.map((Facility facility) => facility.category).toSet().toList()
        ..sort();

  FacilitiesUiState copyWith({
    List<Facility>? allItems,
    bool? refreshing,
    AppFailure? failure,
    bool clearFailure = false,
    String? category,
    bool clearCategory = false,
  }) => FacilitiesUiState(
    allItems: allItems ?? this.allItems,
    refreshing: refreshing ?? this.refreshing,
    failure: clearFailure ? null : failure ?? this.failure,
    category: clearCategory ? null : category ?? this.category,
  );

  @override
  List<Object?> get props => <Object?>[
    allItems,
    refreshing,
    failure,
    category,
  ];
}

class FacilitiesViewModel extends AsyncNotifier<FacilitiesUiState> {
  late final GetFacilities _getFacilities = getIt<GetFacilities>();
  int _requestVersion = 0;

  @override
  Future<FacilitiesUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const FacilitiesUiState(failure: ValidationFailure());
    }
    return _load(
      municipalityId: municipalityId,
      base: const FacilitiesUiState(),
    );
  }

  Future<FacilitiesUiState> _load({
    required String municipalityId,
    required FacilitiesUiState base,
  }) async {
    final Result<List<Facility>> result = await _getFacilities(
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<List<Facility>>(:final value) => base.copyWith(
        allItems: value,
        refreshing: false,
        clearFailure: true,
      ),
      Failed<List<Facility>>(:final failure) => base.copyWith(
        refreshing: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final FacilitiesUiState current = state.value ?? const FacilitiesUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.allItems.isNotEmpty
        ? AsyncData<FacilitiesUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<FacilitiesUiState>();
    final FacilitiesUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<FacilitiesUiState>(loaded);
    }
  }

  void setCategory(String? category) {
    final FacilitiesUiState current = state.value ?? const FacilitiesUiState();
    if (current.category == category) return;
    state = AsyncData<FacilitiesUiState>(
      current.copyWith(category: category, clearCategory: category == null),
    );
  }
}
