import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/managed_event.dart';
import '../repositories/event_repository.dart';

class GetManagedEvents {
  const GetManagedEvents(this._repository);

  final EventRepository _repository;

  Future<Result<ManagedEventsPage>> call({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  }) => _repository.getManagedEvents(
    municipalityId: municipalityId,
    includePast: includePast,
    cursor: cursor,
  );
}

class GetManagedEventDetail {
  const GetManagedEventDetail(this._repository);

  final EventRepository _repository;

  Future<Result<ManagedEvent>> call({
    required String id,
    required String municipalityId,
  }) => _repository.getById(id: id, municipalityId: municipalityId);
}

class SaveEvent {
  const SaveEvent(this._repository);

  final EventRepository _repository;

  Future<Result<List<ManagedEvent>>> call(SaveEventInput input) async {
    if (input.endAt != null && input.endAt!.isBefore(input.startAt)) {
      return const Failure(
        ValidationFailure(message: 'event_end_before_start'),
      );
    }
    if ((input.latitude == null) != (input.longitude == null)) {
      return const Failure(
        ValidationFailure(message: 'event_coordinate_pair_required'),
      );
    }
    if (!input.isEditing) return _repository.create(input);
    final result = await _repository.update(input);
    return switch (result) {
      Success(value: final event) => Success([event]),
      Failure(error: final error) => Failure(error),
    };
  }
}

class DeleteEvent {
  const DeleteEvent(this._repository);

  final EventRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
