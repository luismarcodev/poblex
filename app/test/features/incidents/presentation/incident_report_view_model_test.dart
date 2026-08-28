import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/core/di/injection_container.dart';
import 'package:poblex/core/errors/failure.dart';
import 'package:poblex/core/l10n/app_locales.dart';
import 'package:poblex/core/result/result.dart';
import 'package:poblex/core/session/session_state.dart';
import 'package:poblex/core/session/session_view_model.dart';
import 'package:poblex/features/incidents/domain/entities/incident.dart';
import 'package:poblex/features/incidents/domain/repositories/incident_repository.dart';
import 'package:poblex/features/incidents/domain/usecases/incident_usecases.dart';
import 'package:poblex/features/incidents/presentation/viewmodels/incident_report_view_model.dart';

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

Incident _reported({String? photoUrl}) => Incident(
  id: 'incident-1',
  municipalityId: 'municipality-1',
  category: 'alumbrado',
  description: 'Farola fundida',
  photoUrl: photoUrl,
  lat: null,
  lng: null,
  status: IncidentStatus.received,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

class _StubIncidentRepository implements IncidentRepository {
  _StubIncidentRepository({this.uploadFails = false});
  final bool uploadFails;
  bool uploadCalled = false;

  @override
  Future<Result<Incident>> report({
    required String municipalityId,
    required String category,
    required String description,
    double? lat,
    double? lng,
  }) async => Success<Incident>(_reported());

  @override
  Future<Result<Incident>> uploadPhoto({
    required String incidentId,
    required List<int> bytes,
    required String filename,
  }) async {
    uploadCalled = true;
    if (uploadFails) return const Failed<Incident>(NetworkFailure());
    return Success<Incident>(_reported(photoUrl: 'https://cdn/photo.jpg'));
  }

  @override
  Future<Result<IncidentPage>> listMine({String? cursor}) async =>
      const Success<IncidentPage>(
        IncidentPage(items: <Incident>[], nextCursor: null),
      );

  @override
  Future<Result<IncidentDetail>> detail(String id) async =>
      Success<IncidentDetail>(
        IncidentDetail(
          incident: _reported(),
          history: const <IncidentStatusChange>[],
        ),
      );
}

ProviderContainer _buildContainer(IncidentRepository repository) {
  getIt
    ..registerSingleton<ReportIncident>(ReportIncident(repository))
    ..registerSingleton<UploadIncidentPhoto>(UploadIncidentPhoto(repository));
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sessionViewModelProvider.overrideWith(_ControlledSessionViewModel.new),
    ],
  );
  // incidentReportViewModelProvider is autoDispose: without a keep-alive
  // listener it tears itself down between reads and the next read starts a
  // brand-new notifier with a blank form, silently dropping every answer
  // set so far.
  container.listen(incidentReportViewModelProvider, (_, _) {});
  return container;
}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('cannot submit without a category or a description', () async {
    final container = _buildContainer(_StubIncidentRepository());
    addTearDown(container.dispose);
    final notifier = container.read(incidentReportViewModelProvider.notifier);
    await container.read(incidentReportViewModelProvider.future);

    expect(
      container.read(incidentReportViewModelProvider).requireValue.canSubmit,
      isFalse,
    );

    notifier.setCategory('alumbrado');
    expect(
      container.read(incidentReportViewModelProvider).requireValue.canSubmit,
      isFalse,
    );

    notifier.setDescription('Farola fundida en el Carrer Major');
    expect(
      container.read(incidentReportViewModelProvider).requireValue.canSubmit,
      isTrue,
    );
  });

  test('a failed photo upload still confirms the incident report', () async {
    final repository = _StubIncidentRepository(uploadFails: true);
    final container = _buildContainer(repository);
    addTearDown(container.dispose);
    final notifier = container.read(incidentReportViewModelProvider.notifier);
    await container.read(incidentReportViewModelProvider.future);
    // submit() reads sessionViewModelProvider synchronously — it must
    // already be resolved, exactly as it always is by the time a vecino
    // can reach this screen (onboarding requires a municipality first).
    await container.read(sessionViewModelProvider.future);

    notifier
      ..setCategory('alumbrado')
      ..setDescription('Farola fundida')
      ..setPhoto(Uint8List.fromList(<int>[1, 2, 3]), 'foto.jpg');

    await notifier.submit();

    final IncidentReportUiState result = container
        .read(incidentReportViewModelProvider)
        .requireValue;
    expect(repository.uploadCalled, isTrue);
    expect(result.submitted, isNotNull);
    expect(result.submitted!.id, 'incident-1');
    expect(result.failure, isNull);
  });
}
