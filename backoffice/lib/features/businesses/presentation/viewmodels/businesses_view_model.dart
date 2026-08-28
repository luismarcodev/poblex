import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_business.dart';
import '../../domain/usecases/business_usecases.dart';

class BusinessesUiState extends Equatable {
  const BusinessesUiState({
    required this.municipalityId,
    required this.items,
    required this.includeInactive,
    required this.nextCursor,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedBusiness> items;
  final bool includeInactive;
  final String? nextCursor;
  final Set<String> busyIds;
  final bool isLoadingMore;

  BusinessesUiState copyWith({
    String? municipalityId,
    List<ManagedBusiness>? items,
    bool? includeInactive,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => BusinessesUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
    includeInactive: includeInactive ?? this.includeInactive,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includeInactive,
    nextCursor,
    busyIds,
    isLoadingMore,
  ];
}

final businessesViewModelProvider =
    AsyncNotifierProvider<BusinessesViewModel, BusinessesUiState>(
      BusinessesViewModel.new,
    );

class BusinessesViewModel extends AsyncNotifier<BusinessesUiState> {
  bool _includeInactive = false;
  int _revision = 0;

  @override
  Future<BusinessesUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedBusinesses>()(
      municipalityId: municipalityId,
      includeInactive: _includeInactive,
    );
    return switch (result) {
      Success(value: final page) => BusinessesUiState(
        municipalityId: municipalityId,
        items: page.items,
        includeInactive: _includeInactive,
        nextCursor: page.nextCursor,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setIncludeInactive(bool value) async {
    if (_includeInactive == value) return;
    _includeInactive = value;
    ref.invalidateSelf();
    await future;
  }

  Future<AppFailure?> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return null;
    }
    final requestedCursor = current.nextCursor!;
    final requestedRevision = _revision;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<GetManagedBusinesses>()(
      municipalityId: current.municipalityId,
      includeInactive: current.includeInactive,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.municipalityId != current.municipalityId ||
        latest.includeInactive != current.includeInactive ||
        latest.nextCursor != requestedCursor) {
      return null;
    }
    if (result case Success(value: final page)) {
      final existingIds = latest.items.map((item) => item.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((item) => existingIds.add(item.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedBusinessPage>).error;
  }

  Future<AppFailure?> setActive(ManagedBusiness business) => _mutate(
    business.id,
    () => getIt<SetBusinessActive>()(business.id, !business.active),
  );

  Future<AppFailure?> delete(ManagedBusiness business) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(business.id)) return null;
    _setBusy(business.id, true);
    final result = await getIt<DeleteBusiness>()(business.id);
    final latest = state.valueOrNull;
    if (latest == null ||
        !latest.items.any((value) => value.id == business.id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(business.id, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((value) => value.id != business.id).toList(),
        busyIds: {...latest.busyIds}..remove(business.id),
      ),
    );
    return null;
  }

  Future<AppFailure?> _mutate(
    String id,
    Future<Result<ManagedBusiness>> Function() action,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(id)) return null;
    _setBusy(id, true);
    final result = await action();
    final latest = state.valueOrNull;
    if (latest == null || !latest.items.any((item) => item.id == id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(id, false);
      return error;
    }
    final updated = (result as Success<ManagedBusiness>).value;
    final updatedItems = latest.items
        .map((item) => item.id == updated.id ? updated : item)
        .where((item) => latest.includeInactive || item.active)
        .toList();
    state = AsyncData(
      latest.copyWith(
        items: updatedItems,
        busyIds: {...latest.busyIds}..remove(id),
      ),
    );
    return null;
  }

  void _setBusy(String id, bool busy) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.busyIds};
    busy ? ids.add(id) : ids.remove(id);
    state = AsyncData(current.copyWith(busyIds: ids));
  }
}
