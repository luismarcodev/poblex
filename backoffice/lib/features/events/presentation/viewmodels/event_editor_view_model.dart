import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_event.dart';
import '../../domain/usecases/event_usecases.dart';

class EventEditorUiState extends Equatable {
  const EventEditorUiState({this.event});

  final ManagedEvent? event;

  @override
  List<Object?> get props => [event];
}

final eventEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<EventEditorViewModel, EventEditorUiState>(
      EventEditorViewModel.new,
    );

class EventEditorViewModel
    extends AutoDisposeAsyncNotifier<EventEditorUiState> {
  @override
  EventEditorUiState build() => const EventEditorUiState();

  Future<void> load({
    required String id,
    required String municipalityId,
    ManagedEvent? initial,
  }) async {
    if (initial != null && initial.municipalityId == municipalityId) {
      state = AsyncData(EventEditorUiState(event: initial));
      return;
    }
    state = const AsyncLoading();
    final result = await getIt<GetManagedEventDetail>()(
      id: id,
      municipalityId: municipalityId,
    );
    state = switch (result) {
      Success(value: final event) => AsyncData(
        EventEditorUiState(event: event),
      ),
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<AppFailure?> save(SaveEventInput input) async {
    final previous = state.valueOrNull ?? const EventEditorUiState();
    state = const AsyncLoading();
    final result = await getIt<SaveEvent>()(input);
    state = AsyncData(previous);
    return switch (result) {
      Success() => null,
      Failure(error: final error) => error,
    };
  }
}
