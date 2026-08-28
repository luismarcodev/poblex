import '../../../../core/result/result.dart';
import '../entities/managed_event.dart';

abstract interface class EventRepository {
  Future<Result<ManagedEvent>> getById({
    required String id,
    required String municipalityId,
  });

  Future<Result<ManagedEventsPage>> getManagedEvents({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  });

  Future<Result<List<ManagedEvent>>> create(SaveEventInput input);
  Future<Result<ManagedEvent>> update(SaveEventInput input);
  Future<Result<void>> delete(String id);
}
