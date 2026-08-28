import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_event.dart';
import '../../domain/usecases/event_usecases.dart';

class EventsUiState extends Equatable {
  const EventsUiState({
    required this.municipalityId,
    required this.items,
    required this.includePast,
    required this.nextCursor,
    this.busyIds = const {},
    this.isLoadingMore = false,
  });

  final String municipalityId;
  final List<ManagedEvent> items;
  final bool includePast;
  final String? nextCursor;
  final Set<String> busyIds;
  final bool isLoadingMore;

  EventsUiState copyWith({
    String? municipalityId,
    List<ManagedEvent>? items,
    bool? includePast,
    String? nextCursor,
    bool clearCursor = false,
    Set<String>? busyIds,
    bool? isLoadingMore,
  }) => EventsUiState(
    municipalityId: municipalityId ?? this.municipalityId,
    items: items ?? this.items,
    includePast: includePast ?? this.includePast,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    busyIds: busyIds ?? this.busyIds,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [
    municipalityId,
    items,
    includePast,
    nextCursor,
    busyIds,
    isLoadingMore,
  ];
}

final eventsViewModelProvider =
    AsyncNotifierProvider<EventsViewModel, EventsUiState>(EventsViewModel.new);

class EventsViewModel extends AsyncNotifier<EventsUiState> {
  bool _includePast = false;
  int _revision = 0;

  @override
  Future<EventsUiState> build() async {
    _revision++;
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<GetManagedEvents>()(
      municipalityId: municipalityId,
      includePast: _includePast,
    );
    return switch (result) {
      Success(value: final page) => EventsUiState(
        municipalityId: municipalityId,
        items: page.items,
        includePast: _includePast,
        nextCursor: page.nextCursor,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setIncludePast(bool value) async {
    if (_includePast == value) return;
    _includePast = value;
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
    final result = await getIt<GetManagedEvents>()(
      municipalityId: current.municipalityId,
      includePast: current.includePast,
      cursor: requestedCursor,
    );
    final latest = state.valueOrNull;
    if (latest == null ||
        requestedRevision != _revision ||
        latest.municipalityId != current.municipalityId ||
        latest.includePast != current.includePast ||
        latest.nextCursor != requestedCursor) {
      return null;
    }
    if (result case Success(value: final page)) {
      final existingIds = latest.items.map((event) => event.id).toSet();
      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...page.items.where((event) => existingIds.add(event.id)),
          ],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
      return null;
    }
    state = AsyncData(latest.copyWith(isLoadingMore: false));
    return (result as Failure<ManagedEventsPage>).error;
  }

  Future<AppFailure?> delete(ManagedEvent event) async {
    final current = state.valueOrNull;
    if (current == null) return const UnknownFailure();
    if (current.busyIds.contains(event.id)) return null;
    _setBusy(event.id, true);

    final result = await getIt<DeleteEvent>()(event.id);
    final latest = state.valueOrNull;
    if (latest == null || !latest.items.any((value) => value.id == event.id)) {
      return null;
    }
    if (result case Failure(error: final error)) {
      _setBusy(event.id, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        items: latest.items.where((value) => value.id != event.id).toList(),
        busyIds: {...latest.busyIds}..remove(event.id),
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
