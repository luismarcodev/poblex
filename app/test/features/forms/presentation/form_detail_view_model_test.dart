import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/forms/domain/entities/form.dart';
import 'package:poblex/features/forms/domain/repositories/form_repository.dart';
import 'package:poblex/features/forms/domain/usecases/form_usecases.dart';
import 'package:poblex/features/forms/presentation/viewmodels/form_detail_view_model.dart';
import 'package:poblex/shared/domain/value_objects/localized_text.dart';

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

final MunicipalForm _form = MunicipalForm(
  id: 'form-1',
  municipalityId: 'municipality-1',
  title: const LocalizedText(
    es: 'Inscripción paellas',
    va: 'Inscripció paelles',
  ),
  description: const LocalizedText(es: 'Censo', va: 'Cens'),
  deadline: null,
  isOpen: true,
  alreadySubmitted: false,
  fields: const <FormFieldDefinition>[
    FormFieldDefinition(
      id: 'field-name',
      key: 'nombre',
      label: LocalizedText(es: 'Nombre', va: 'Nom'),
      type: FormFieldType.text,
      required: true,
      options: <String>[],
      position: 0,
    ),
    FormFieldDefinition(
      id: 'field-comments',
      key: 'comensales',
      label: LocalizedText(es: 'Comensales', va: 'Comensals'),
      type: FormFieldType.number,
      required: false,
      options: <String>[],
      position: 1,
    ),
  ],
);

class _StubFormRepository implements FormRepository {
  @override
  Future<Result<FormPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async => const Success<FormPage>(
    FormPage(items: <MunicipalForm>[], nextCursor: null),
  );

  @override
  Future<Result<MunicipalForm>> detail({
    required String id,
    required String municipalityId,
  }) async => Success<MunicipalForm>(_form);

  @override
  Future<Result<void>> submit({
    required String formId,
    required Map<String, String> answers,
  }) async => const Success<void>(null);
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    final repository = _StubFormRepository();
    getIt
      ..registerSingleton<GetFormDetail>(GetFormDetail(repository))
      ..registerSingleton<SubmitForm>(SubmitForm(repository));
    container = ProviderContainer(
      overrides: <Override>[
        sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
      ],
    );
    // autoDispose.family: keep it alive across the awaits below, or the
    // provider tears down and a fresh instance replaces the answers.
    container.listen(formDetailViewModelProvider('form-1'), (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('a required field left blank blocks submission', () async {
    await container.read(formDetailViewModelProvider('form-1').future);
    final notifier = container.read(
      formDetailViewModelProvider('form-1').notifier,
    );

    expect(
      container
          .read(formDetailViewModelProvider('form-1'))
          .requireValue
          .canSubmit,
      isFalse,
    );

    notifier.setAnswer('field-comments', '4');
    expect(
      container
          .read(formDetailViewModelProvider('form-1'))
          .requireValue
          .canSubmit,
      isFalse,
      reason: 'the optional field alone must not unlock submission',
    );

    notifier.setAnswer('field-name', 'Luis');
    expect(
      container
          .read(formDetailViewModelProvider('form-1'))
          .requireValue
          .canSubmit,
      isTrue,
    );
  });
}
