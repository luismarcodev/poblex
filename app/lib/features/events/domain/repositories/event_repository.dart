import '../../../../core/result/result.dart';
import '../entities/event.dart';

abstract interface class EventRepository {
  Future<Result<EventPage>> list({
    required String municipalityId,
    String? cursor,
  });

  Future<Result<MunicipalEvent>> detail({
    required String id,
    required String municipalityId,
  });

  /// UNIQUE (event_id, device_id) server-side: setting a new reminder for an
  /// event that already has one replaces it rather than duplicating it.
  Future<Result<void>> setReminder({
    required String eventId,
    required DateTime remindAt,
  });

  Future<Result<void>> cancelReminder(String eventId);
}
