import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';
import 'package:poblex_backoffice/features/events/domain/repositories/event_repository.dart';
import 'package:poblex_backoffice/features/events/domain/usecases/event_usecases.dart';
import 'package:poblex_backoffice/features/events/domain/value_objects/event_category.dart';

class FakeEventRepository implements EventRepository {
  int createCalls = 0;

  @override
  Future<Result<List<ManagedEvent>>> create(SaveEventInput input) async {
    createCalls++;
    return const Success([]);
  }

  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();

  @override
  Future<Result<ManagedEvent>> getById({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedEventsPage>> getManagedEvents({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedEvent>> update(SaveEventInput input) =>
      throw UnimplementedError();
}

void main() {
  test('rejects an end before the start without writing', () async {
    final repository = FakeEventRepository();
    final result = await SaveEvent(repository)(
      _input(endAt: DateTime.utc(2026, 8, 12, 9)),
    );

    expect(result, isA<Failure<List<ManagedEvent>>>());
    expect(repository.createCalls, 0);
  });

  test('rejects an incomplete coordinate pair without writing', () async {
    final repository = FakeEventRepository();
    final result = await SaveEvent(repository)(_input(latitude: 39.278));

    expect(result, isA<Failure<List<ManagedEvent>>>());
    expect(repository.createCalls, 0);
  });

  test('accepts normalized category slugs only', () {
    expect(isValidEventCategory('cultura-local'), isTrue);
    expect(isValidEventCategory('Cultura local'), isFalse);
  });
}

SaveEventInput _input({DateTime? endAt, double? latitude}) => SaveEventInput(
  title: const EventLocalizedText(es: 'Feria'),
  description: const EventLocalizedText(es: 'En la plaza'),
  startAt: DateTime.utc(2026, 8, 12, 10),
  endAt: endAt,
  latitude: latitude,
  category: 'cultura',
  municipalityIds: const ['municipality-1'],
);
