import '../../../../core/result/result.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEvents {
  const GetEvents(this._repository);
  final EventRepository _repository;

  Future<Result<EventPage>> call({
    required String municipalityId,
    String? cursor,
  }) => _repository.list(municipalityId: municipalityId, cursor: cursor);
}

class GetEventDetail {
  const GetEventDetail(this._repository);
  final EventRepository _repository;

  Future<Result<MunicipalEvent>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}

class SetEventReminder {
  const SetEventReminder(this._repository);
  final EventRepository _repository;

  Future<Result<void>> call({
    required String eventId,
    required DateTime remindAt,
  }) => _repository.setReminder(eventId: eventId, remindAt: remindAt);
}

class CancelEventReminder {
  const CancelEventReminder(this._repository);
  final EventRepository _repository;

  Future<Result<void>> call(String eventId) =>
      _repository.cancelReminder(eventId);
}
