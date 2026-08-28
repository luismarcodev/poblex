import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._remote);

  final EventRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedEvent>> getById({
    required String id,
    required String municipalityId,
  }) => _capture(() => _remote.getById(id: id, municipalityId: municipalityId));

  @override
  Future<Result<ManagedEventsPage>> getManagedEvents({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedEvents(
      municipalityId: municipalityId,
      includePast: includePast,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<List<ManagedEvent>>> create(SaveEventInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<ManagedEvent>> update(SaveEventInput input) =>
      _capture(() => _remote.update(input));

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));
}
