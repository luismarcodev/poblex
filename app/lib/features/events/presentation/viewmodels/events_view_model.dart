import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/event_usecases.dart';

final eventsViewModelProvider =
    AsyncNotifierProvider<EventsViewModel, EventsUiState>(EventsViewModel.new);

class EventsUiState extends Equatable {
  const EventsUiState({
    this.items = const <MunicipalEvent>[],
    // Ephemeral and session-only: the list/detail endpoints don't expose
    // whether THIS device already has a reminder for an event, so this only
    // reflects reminders set or cancelled since the app was last launched —
    // never a source of truth restored from the backend.
    this.remindedEventIds = const <String>{},
    this.refreshing = false,
    this.loadingMore = false,
    this.failure,
    this.nextCursor,
  });

  final List<MunicipalEvent> items;
  final Set<String> remindedEventIds;
  final bool refreshing;
  final bool loadingMore;
  final AppFailure? failure;
  final String? nextCursor;

  bool get canLoadMore => nextCursor != null && !loadingMore;
  bool get isEmpty => items.isEmpty;

  EventsUiState copyWith({
    List<MunicipalEvent>? items,
    Set<String>? remindedEventIds,
    bool? refreshing,
    bool? loadingMore,
    AppFailure? failure,
    bool clearFailure = false,
    String? nextCursor,
    bool clearCursor = false,
  }) => EventsUiState(
    items: items ?? this.items,
    remindedEventIds: remindedEventIds ?? this.remindedEventIds,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: clearFailure ? null : failure ?? this.failure,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );

  @override
  List<Object?> get props => <Object?>[
    items,
    remindedEventIds,
    refreshing,
    loadingMore,
    failure,
    nextCursor,
  ];
}

class EventsViewModel extends AsyncNotifier<EventsUiState> {
  late final GetEvents _getEvents = getIt<GetEvents>();
  late final SetEventReminder _setReminder = getIt<SetEventReminder>();
  late final CancelEventReminder _cancelReminder = getIt<CancelEventReminder>();
  int _requestVersion = 0;

  @override
  Future<EventsUiState> build() async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const EventsUiState(failure: ValidationFailure());
    }
    return _load(municipalityId: municipalityId, base: const EventsUiState());
  }

  Future<EventsUiState> _load({
    required String municipalityId,
    required EventsUiState base,
  }) async {
    final Result<EventPage> result = await _getEvents(
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<EventPage>(:final value) => base.copyWith(
        items: value.items,
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        refreshing: false,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<EventPage>(:final failure) => base.copyWith(
        refreshing: false,
        loadingMore: false,
        failure: failure,
      ),
    };
  }

  Future<void> refresh() async {
    final EventsUiState current = state.value ?? const EventsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = current.items.isNotEmpty
        ? AsyncData<EventsUiState>(
            current.copyWith(refreshing: true, clearFailure: true),
          )
        : const AsyncLoading<EventsUiState>();
    final EventsUiState loaded = await _load(
      municipalityId: municipalityId,
      base: current,
    );
    if (requestVersion == _requestVersion) {
      state = AsyncData<EventsUiState>(loaded);
    }
  }

  Future<void> loadMore() async {
    final EventsUiState current = state.value ?? const EventsUiState();
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!current.canLoadMore || municipalityId == null) return;
    final int requestVersion = ++_requestVersion;
    state = AsyncData<EventsUiState>(current.copyWith(loadingMore: true));
    final Result<EventPage> result = await _getEvents(
      municipalityId: municipalityId,
      cursor: current.nextCursor,
    );
    if (requestVersion != _requestVersion) return;
    state = AsyncData<EventsUiState>(switch (result) {
      Success<EventPage>(:final value) => current.copyWith(
        items: <MunicipalEvent>[...current.items, ...value.items],
        nextCursor: value.nextCursor,
        clearCursor: value.nextCursor == null,
        loadingMore: false,
        clearFailure: true,
      ),
      Failed<EventPage>(:final failure) => current.copyWith(
        loadingMore: false,
        failure: failure,
      ),
    });
  }

  Future<Result<void>> setReminder(String eventId, DateTime remindAt) async {
    final Result<void> result = await _setReminder(
      eventId: eventId,
      remindAt: remindAt,
    );
    if (result.isSuccess) {
      final EventsUiState current = state.value ?? const EventsUiState();
      state = AsyncData<EventsUiState>(
        current.copyWith(
          remindedEventIds: <String>{...current.remindedEventIds, eventId},
        ),
      );
    }
    return result;
  }

  Future<Result<void>> cancelReminder(String eventId) async {
    final Result<void> result = await _cancelReminder(eventId);
    if (result.isSuccess) {
      final EventsUiState current = state.value ?? const EventsUiState();
      state = AsyncData<EventsUiState>(
        current.copyWith(
          remindedEventIds: current.remindedEventIds
              .where((String id) => id != eventId)
              .toSet(),
        ),
      );
    }
    return result;
  }
}
