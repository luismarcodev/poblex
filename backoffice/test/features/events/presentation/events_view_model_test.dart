import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/events/domain/entities/managed_event.dart';
import 'package:poblex_backoffice/features/events/domain/repositories/event_repository.dart';
import 'package:poblex_backoffice/features/events/domain/usecases/event_usecases.dart';
import 'package:poblex_backoffice/features/events/presentation/viewmodels/events_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'sollana',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class FakeMunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class FakeEventRepository implements EventRepository {
  FakeEventRepository(this.initialItems);

  final List<ManagedEvent> initialItems;
  final loadMoreResult = Completer<Result<ManagedEventsPage>>();
  final deleteResults = <String, Completer<Result<void>>>{};
  int loadMoreCalls = 0;

  @override
  Future<Result<ManagedEventsPage>> getManagedEvents({
    required String municipalityId,
    required bool includePast,
    String? cursor,
  }) async {
    if (cursor == null) {
      return Success(
        ManagedEventsPage(items: initialItems, nextCursor: 'next'),
      );
    }
    loadMoreCalls++;
    return loadMoreResult.future;
  }

  @override
  Future<Result<void>> delete(String id) =>
      deleteResults.putIfAbsent(id, Completer<Result<void>>.new).future;

  @override
  Future<Result<List<ManagedEvent>>> create(SaveEventInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<ManagedEvent>> getById({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();

  @override
  Future<Result<ManagedEvent>> update(SaveEventInput input) =>
      throw UnimplementedError();
}

void main() {
  late FakeEventRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = FakeEventRepository([_event('one'), _event('two')]);
    getIt.registerFactory(() => GetManagedEvents(repository));
    getIt.registerFactory(() => DeleteEvent(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(
          FakeMunicipalityViewModel.new,
        ),
      ],
    );
    await container.read(eventsViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('prevents duplicate pagination and keeps items on failure', () async {
    final viewModel = container.read(eventsViewModelProvider.notifier);
    final first = viewModel.loadMore();
    final duplicate = viewModel.loadMore();

    expect(repository.loadMoreCalls, 1);
    repository.loadMoreResult.complete(
      const Failure(NetworkFailure(message: 'offline')),
    );

    expect(await first, isA<NetworkFailure>());
    expect(await duplicate, isNull);
    final state = container.read(eventsViewModelProvider).value!;
    expect(state.items.map((event) => event.id), ['one', 'two']);
    expect(state.isLoadingMore, isFalse);
  });

  test('discards a stale pagination response after a refresh', () async {
    final viewModel = container.read(eventsViewModelProvider.notifier);
    final pagination = viewModel.loadMore();

    await viewModel.refresh();
    repository.loadMoreResult.complete(
      Success(ManagedEventsPage(items: [_event('stale')], nextCursor: null)),
    );

    expect(await pagination, isNull);
    expect(
      container
          .read(eventsViewModelProvider)
          .value!
          .items
          .map((item) => item.id),
      ['one', 'two'],
    );
  });

  test('keeps concurrent deletes independent', () async {
    final viewModel = container.read(eventsViewModelProvider.notifier);
    final first = viewModel.delete(repository.initialItems[0]);
    final second = viewModel.delete(repository.initialItems[1]);

    repository.deleteResults['two']!.complete(const Success(null));
    await second;
    expect(
      container
          .read(eventsViewModelProvider)
          .value!
          .items
          .map((item) => item.id),
      ['one'],
    );

    repository.deleteResults['one']!.complete(
      const Failure(NetworkFailure(message: 'offline')),
    );
    expect(await first, isA<NetworkFailure>());
    final state = container.read(eventsViewModelProvider).value!;
    expect(state.items.map((item) => item.id), ['one']);
    expect(state.busyIds, isEmpty);
  });
}

ManagedEvent _event(String id) => ManagedEvent(
  id: id,
  municipalityId: municipality.id,
  title: EventLocalizedText(es: 'Título $id', va: 'Títol $id'),
  description: EventLocalizedText(es: 'Contenido $id', va: 'Contingut $id'),
  startAt: DateTime.utc(2026, 8, 12, 10),
  category: 'cultura',
);
