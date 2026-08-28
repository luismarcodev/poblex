import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../mappers/event_mapper.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._remote);
  final EventRemoteDataSource _remote;

  @override
  Future<Result<EventPage>> list({
    required String municipalityId,
    String? cursor,
  }) async {
    try {
      final EventPageModel page = await _remote.list(
        municipalityId: municipalityId,
        cursor: cursor,
      );
      return Success<EventPage>(
        EventPage(
          items: page.items.map(EventMapper.toDomain).toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<EventPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<MunicipalEvent>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<MunicipalEvent>(
        EventMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<MunicipalEvent>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> setReminder({
    required String eventId,
    required DateTime remindAt,
  }) async {
    try {
      await _remote.setReminder(eventId: eventId, remindAt: remindAt);
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> cancelReminder(String eventId) async {
    try {
      await _remote.cancelReminder(eventId);
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }
}
