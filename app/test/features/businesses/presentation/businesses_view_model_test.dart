import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/businesses/domain/entities/business.dart';
import 'package:poblex/features/businesses/domain/repositories/business_repository.dart';
import 'package:poblex/features/businesses/domain/usecases/business_usecases.dart';
import 'package:poblex/features/businesses/presentation/viewmodels/businesses_view_model.dart';

class _ControlledSessionViewModel extends SessionViewModel {
  @override
  Future<SessionState> build() async => const SessionState(
    deviceId: 'device-1',
    municipalityId: 'municipality-1',
    municipalityName: 'Sollana',
    municipalitySlug: 'sollana',
    deviceLocale: AppLocale.es,
  );
}

MunicipalBusiness _business(String id, String category) => MunicipalBusiness(
  id: id,
  municipalityId: 'municipality-1',
  name: 'Comercio $id',
  category: category,
  description: null,
  address: null,
  phone: null,
  email: null,
  website: null,
  schedule: null,
  photoUrls: const <String>[],
);

class _RecordingBusinessRepository implements BusinessRepository {
  int listCalls = 0;
  String? lastCategory;

  @override
  Future<Result<BusinessPage>> list({
    required String municipalityId,
    String? category,
    String? cursor,
  }) async {
    listCalls++;
    lastCategory = category;
    final List<MunicipalBusiness> items = category == null
        ? <MunicipalBusiness>[_business('1', 'bar'), _business('2', 'taller')]
        : <MunicipalBusiness>[_business('1', category)];
    return Success<BusinessPage>(BusinessPage(items: items, nextCursor: null));
  }

  @override
  Future<Result<List<String>>> categories(String municipalityId) async =>
      const Success<List<String>>(<String>['bar', 'taller']);

  @override
  Future<Result<MunicipalBusiness>> detail({
    required String id,
    required String municipalityId,
  }) async => Success<MunicipalBusiness>(_business(id, 'bar'));
}

void main() {
  late _RecordingBusinessRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _RecordingBusinessRepository();
    getIt
      ..registerSingleton<GetBusinesses>(GetBusinesses(repository))
      ..registerSingleton<GetBusinessCategories>(
        GetBusinessCategories(repository),
      );
    container = ProviderContainer(
      overrides: <Override>[
        sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('loads every category and its business list on build', () async {
    final BusinessesUiState initial = await container.read(
      businessesViewModelProvider.future,
    );

    expect(initial.items, hasLength(2));
    expect(initial.categories, <String>['bar', 'taller']);
    expect(repository.lastCategory, isNull);
  });

  test('filtering by category reloads with only that category', () async {
    await container.read(businessesViewModelProvider.future);

    await container
        .read(businessesViewModelProvider.notifier)
        .setCategory('bar');

    final BusinessesUiState filtered = container
        .read(businessesViewModelProvider)
        .requireValue;
    expect(filtered.category, 'bar');
    expect(filtered.items, hasLength(1));
    expect(repository.lastCategory, 'bar');
    expect(repository.listCalls, 2);
  });

  test('clearing the filter goes back to the full list', () async {
    await container.read(businessesViewModelProvider.future);
    await container
        .read(businessesViewModelProvider.notifier)
        .setCategory('taller');

    await container
        .read(businessesViewModelProvider.notifier)
        .setCategory(null);

    final BusinessesUiState cleared = container
        .read(businessesViewModelProvider)
        .requireValue;
    expect(cleared.category, isNull);
    expect(cleared.items, hasLength(2));
  });
}
