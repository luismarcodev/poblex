import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/event_usecases.dart';

final eventDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<EventDetailViewModel, EventDetailUiState, String>(
      EventDetailViewModel.new,
    );

class EventDetailUiState extends Equatable {
  const EventDetailUiState({
    this.event,
    this.hasReminder = false,
    this.failure,
  });

  final MunicipalEvent? event;
  final bool hasReminder;
  final AppFailure? failure;

  @override
  List<Object?> get props => <Object?>[event, hasReminder, failure];
}

class EventDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<EventDetailUiState, String> {
  late final GetEventDetail _getDetail = getIt<GetEventDetail>();
  late final SetEventReminder _setReminder = getIt<SetEventReminder>();
  late final CancelEventReminder _cancelReminder = getIt<CancelEventReminder>();

  @override
  Future<EventDetailUiState> build(String arg) => _load(arg);

  Future<EventDetailUiState> _load(String id) async {
    final String? municipalityId = await ref.watch(
      sessionViewModelProvider.selectAsync(
        (SessionState session) => session.municipalityId,
      ),
    );
    if (municipalityId == null) {
      return const EventDetailUiState(failure: ValidationFailure());
    }
    final Result<MunicipalEvent> result = await _getDetail(
      id: id,
      municipalityId: municipalityId,
    );
    return switch (result) {
      Success<MunicipalEvent>(:final value) => EventDetailUiState(event: value),
      Failed<MunicipalEvent>(:final failure) => EventDetailUiState(
        failure: failure,
      ),
    };
  }

  Future<void> retry() async {
    state = const AsyncLoading<EventDetailUiState>();
    state = AsyncData<EventDetailUiState>(await _load(arg));
  }

  Future<Result<void>> setReminder(DateTime remindAt) async {
    final Result<void> result = await _setReminder(
      eventId: arg,
      remindAt: remindAt,
    );
    if (result.isSuccess) {
      final EventDetailUiState current = state.requireValue;
      state = AsyncData<EventDetailUiState>(
        EventDetailUiState(event: current.event, hasReminder: true),
      );
    }
    return result;
  }

  Future<Result<void>> cancelReminder() async {
    final Result<void> result = await _cancelReminder(arg);
    if (result.isSuccess) {
      final EventDetailUiState current = state.requireValue;
      state = AsyncData<EventDetailUiState>(
        EventDetailUiState(event: current.event),
      );
    }
    return result;
  }
}
