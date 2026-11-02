import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/incidents/domain/entities/managed_incident.dart';
import 'package:poblex_backoffice/features/incidents/domain/repositories/incident_repository.dart';
import 'package:poblex_backoffice/features/incidents/domain/usecases/incident_usecases.dart';

class FakeIncidentRepository implements IncidentRepository {
  ChangeIncidentStatusInput? changed;
  String? listedCategory;

  @override
  Future<Result<ManagedIncident>> changeStatus(
    ChangeIncidentStatusInput input,
  ) async {
    changed = input;
    return Success(input.incident.copyWith(status: input.status));
  }

  @override
  Future<Result<ManagedIncidentsPage>> getManagedIncidents({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  }) async {
    listedCategory = category;
    return const Success(ManagedIncidentsPage(items: [], nextCursor: null));
  }

  @override
  Future<Result<List<IncidentStatusChange>>> getHistory(
    String incidentId,
  ) async => const Success([]);

  @override
  Future<Result<List<String>>> getCategories(String municipalityId) async =>
      const Success([]);
}

void main() {
  test('normalizes an incident category before querying', () async {
    final repository = FakeIncidentRepository();

    await GetManagedIncidents(repository)(
      municipalityId: 'municipality-1',
      category: '  Alumbrado  ',
    );

    expect(repository.listedCategory, 'alumbrado');
  });

  test('rejects reopening a resolved incident without writing', () async {
    final repository = FakeIncidentRepository();
    final result = await ChangeManagedIncidentStatus(repository)(
      ChangeIncidentStatusInput(
        incident: _incident(status: IncidentStatus.resolved),
        status: IncidentStatus.inProgress,
      ),
    );

    expect(result, isA<Failure<ManagedIncident>>());
    expect(
      (result as Failure<ManagedIncident>).error,
      isA<ValidationFailure>(),
    );
    expect(repository.changed, isNull);
  });

  test('trims an optional note before writing', () async {
    final repository = FakeIncidentRepository();
    final result = await ChangeManagedIncidentStatus(repository)(
      ChangeIncidentStatusInput(
        incident: _incident(),
        status: IncidentStatus.inProgress,
        note: '  Revisada por obras  ',
      ),
    );

    expect(result, isA<Success<ManagedIncident>>());
    expect(repository.changed?.note, 'Revisada por obras');
  });

  test('rejects a note longer than the backend contract', () async {
    final repository = FakeIncidentRepository();
    final result = await ChangeManagedIncidentStatus(repository)(
      ChangeIncidentStatusInput(
        incident: _incident(),
        status: IncidentStatus.inProgress,
        note: List.filled(maxIncidentNoteLength + 1, 'a').join(),
      ),
    );

    expect(result, isA<Failure<ManagedIncident>>());
    expect(repository.changed, isNull);
  });
}

ManagedIncident _incident({IncidentStatus status = IncidentStatus.received}) =>
    ManagedIncident(
      id: 'incident-1',
      municipalityId: 'municipality-1',
      category: 'alumbrado',
      description: 'Farola apagada.',
      status: status,
      createdAt: DateTime.utc(2026, 8, 10, 8),
      updatedAt: DateTime.utc(2026, 8, 10, 8),
    );
