import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/auth/domain/entities/manager_profile.dart';
import 'package:poblex_backoffice/features/auth/presentation/viewmodels/municipality_view_model.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';
import 'package:poblex_backoffice/features/forms/domain/repositories/form_repository.dart';
import 'package:poblex_backoffice/features/forms/domain/usecases/form_usecases.dart';
import 'package:poblex_backoffice/features/forms/presentation/viewmodels/forms_view_model.dart';

const municipality = ManagedMunicipality(
  id: 'municipality-1',
  name: 'Sollana',
  province: 'València',
  languages: ['es', 'va'],
);

class _MunicipalityViewModel extends SelectedMunicipalityViewModel {
  @override
  ManagedMunicipality build() => municipality;
}

class _Repository implements FormRepository {
  final loadMoreResult = Completer<Result<ManagedFormsPage>>();
  int loadMoreCalls = 0;

  @override
  Future<Result<ManagedFormsPage>> getForms({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    if (cursor == null) {
      return Success(
        ManagedFormsPage(items: [_form('one')], nextCursor: 'next'),
      );
    }
    loadMoreCalls++;
    return loadMoreResult.future;
  }

  @override
  Future<Result<void>> delete(String id) async => const Success(null);
  @override
  Future<Result<ManagedForm>> create(CreateFormInput input) =>
      throw UnimplementedError();
  @override
  Future<Result<String>> exportSubmissionsCsv(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedForm>> getDetail({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();
}

void main() {
  late _Repository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = _Repository();
    getIt.registerFactory(() => GetManagedForms(repository));
    getIt.registerFactory(() => DeleteManagedForm(repository));
    container = ProviderContainer(
      overrides: [
        selectedMunicipalityProvider.overrideWith(_MunicipalityViewModel.new),
      ],
    );
    await container.read(formsViewModelProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('prevents duplicate pagination and preserves data on failure', () async {
    final viewModel = container.read(formsViewModelProvider.notifier);
    final first = viewModel.loadMore();
    final duplicate = viewModel.loadMore();
    expect(repository.loadMoreCalls, 1);

    repository.loadMoreResult.complete(
      const Failure(NetworkFailure(message: 'offline')),
    );
    expect(await first, isA<NetworkFailure>());
    expect(await duplicate, isNull);
    final state = container.read(formsViewModelProvider).value!;
    expect(state.items.single.id, 'one');
    expect(state.isLoadingMore, isFalse);
  });

  test('removes a deleted form from the current page', () async {
    final form = container.read(formsViewModelProvider).value!.items.single;
    expect(
      await container.read(formsViewModelProvider.notifier).delete(form),
      isNull,
    );
    expect(container.read(formsViewModelProvider).value!.items, isEmpty);
  });
}

ManagedForm _form(String id) => ManagedForm(
  id: id,
  municipalityId: municipality.id,
  title: FormLocalizedText(es: 'Formulario $id'),
  description: const FormLocalizedText(es: 'Descripción'),
  deadline: DateTime.utc(2026, 9, 1),
  isOpen: true,
  fields: const [
    ManagedFormField(
      id: 'field-1',
      key: 'name',
      label: FormLocalizedText(es: 'Nombre'),
      type: ManagedFormFieldType.text,
      required: true,
      options: [],
      position: 0,
    ),
  ],
);
