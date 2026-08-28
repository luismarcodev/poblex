import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/incidents/domain/entities/managed_incident.dart';
import 'package:poblex_backoffice/features/incidents/domain/repositories/incident_repository.dart';
import 'package:poblex_backoffice/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:poblex_backoffice/features/incidents/presentation/viewmodels/incidents_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeIncidentRepository implements IncidentRepository {
  final loadMoreResult = Completer<Result<ManagedIncidentsPage>>();
  final changeResults = <String, Completer<Result<ManagedIncident>>>{};
  int loadMoreCalls = 0;
  IncidentStatus? lastStatusFilter;
  String? lastCategoryFilter;

  @override
  Future<Result<ManagedIncidentsPage>> getManagedIncidents({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  }) async {
    lastStatusFilter = status;
    lastCategoryFilter = category;
    if (cursor != null) {
      loadMoreCalls++;
      return loadMoreResult.future;
    }
    return Success(
      ManagedIncidentsPage(
        items: [_incident('one'), _incident('two')],
        nextCursor: 'next',
      ),
    );
  }

  @override
  Future<Result<ManagedIncident>> changeStatus(
    ChangeIncidentStatusInput input,
  ) => changeResults
      .putIfAbsent(input.incident.id, Completer<Result<ManagedIncident>>.new)
      .future;
}

void main() {
  late FakeIncidentRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeIncidentRepository();
    getIt.registerFactory(() => GetManagedIncidents(repository));
    getIt.registerFactory(() => ChangeManagedIncidentStatus(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(incidentsViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'prevents duplicate pagination and preserves items on failure',
    () async {
      final viewModel = container.read(incidentsViewModelProvider.notifier);
      final first = viewModel.loadMore();
      final duplicate = viewModel.loadMore();

      expect(repository.loadMoreCalls, 1);
      repository.loadMoreResult.complete(
        const Failure(NetworkFailure(message: 'offline')),
      );

      expect(await first, isA<NetworkFailure>());
      expect(await duplicate, isNull);
      final state = container.read(incidentsViewModelProvider).value!;
      expect(state.items.map((item) => item.id), ['one', 'two']);
      expect(state.isLoadingMore, isFalse);
    },
  );

  test('discards a stale pagination response after a refresh', () async {
    final viewModel = container.read(incidentsViewModelProvider.notifier);
    final pagination = viewModel.loadMore();

    await viewModel.refresh();
    repository.loadMoreResult.complete(
      Success(
        ManagedIncidentsPage(items: [_incident('stale')], nextCursor: null),
      ),
    );
    await pagination;

    final state = container.read(incidentsViewModelProvider).value!;
    expect(state.items.map((item) => item.id), ['one', 'two']);
    expect(state.isLoadingMore, isFalse);
  });

  test('normalizes and applies filters through a fresh request', () async {
    await container
        .read(incidentsViewModelProvider.notifier)
        .applyFilters(
          status: IncidentStatus.received,
          category: '  Alumbrado  ',
        );

    expect(repository.lastStatusFilter, IncidentStatus.received);
    expect(repository.lastCategoryFilter, 'alumbrado');
    final state = container.read(incidentsViewModelProvider).value!;
    expect(state.statusFilter, IncidentStatus.received);
    expect(state.categoryFilter, 'alumbrado');
  });

  test(
    'removes an updated incident when it leaves the active filter',
    () async {
      await container
          .read(incidentsViewModelProvider.notifier)
          .applyFilters(status: IncidentStatus.received);
      final incident = container
          .read(incidentsViewModelProvider)
          .value!
          .items
          .first;
      final operation = container
          .read(incidentsViewModelProvider.notifier)
          .changeStatus(
            incident: incident,
            status: IncidentStatus.inProgress,
            note: 'En revisión',
          );
      repository.changeResults[incident.id]!.complete(
        Success(incident.copyWith(status: IncidentStatus.inProgress)),
      );

      expect(await operation, isNull);
      final state = container.read(incidentsViewModelProvider).value!;
      expect(state.items.any((item) => item.id == incident.id), isFalse);
      expect(state.busyIds, isEmpty);
    },
  );
}

ManagedIncident _incident(String id) => ManagedIncident(
  id: id,
  municipalityId: municipality.id,
  category: 'alumbrado',
  description: 'Farola apagada $id',
  status: IncidentStatus.received,
  createdAt: DateTime.utc(2026, 8, 10, 8),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
);
