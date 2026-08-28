import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_view_model.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/incident_usecases.dart';

final incidentReportViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      IncidentReportViewModel,
      IncidentReportUiState
    >(IncidentReportViewModel.new);

class IncidentReportUiState extends Equatable {
  const IncidentReportUiState({
    this.category,
    this.description = '',
    this.lat,
    this.lng,
    this.photoBytes,
    this.photoFilename,
    this.submitting = false,
    this.submitted,
    this.failure,
  });

  final String? category;
  final String description;
  final double? lat;
  final double? lng;
  final Uint8List? photoBytes;
  final String? photoFilename;
  final bool submitting;
  final Incident? submitted;
  final AppFailure? failure;

  bool get canSubmit =>
      !submitting && category != null && description.trim().isNotEmpty;

  IncidentReportUiState copyWith({
    String? category,
    String? description,
    double? lat,
    double? lng,
    Uint8List? photoBytes,
    bool clearPhoto = false,
    String? photoFilename,
    bool? submitting,
    Incident? submitted,
    AppFailure? failure,
    bool clearFailure = false,
  }) => IncidentReportUiState(
    category: category ?? this.category,
    description: description ?? this.description,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    photoBytes: clearPhoto ? null : photoBytes ?? this.photoBytes,
    photoFilename: clearPhoto ? null : photoFilename ?? this.photoFilename,
    submitting: submitting ?? this.submitting,
    submitted: submitted ?? this.submitted,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    category,
    description,
    lat,
    lng,
    photoBytes,
    photoFilename,
    submitting,
    submitted,
    failure,
  ];
}

class IncidentReportViewModel
    extends AutoDisposeAsyncNotifier<IncidentReportUiState> {
  late final ReportIncident _reportIncident = getIt<ReportIncident>();
  late final UploadIncidentPhoto _uploadPhoto = getIt<UploadIncidentPhoto>();

  @override
  Future<IncidentReportUiState> build() async => const IncidentReportUiState();

  void setCategory(String category) {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    state = AsyncData<IncidentReportUiState>(
      current.copyWith(category: category),
    );
  }

  void setDescription(String description) {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    state = AsyncData<IncidentReportUiState>(
      current.copyWith(description: description),
    );
  }

  void setLocation({required double lat, required double lng}) {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    state = AsyncData<IncidentReportUiState>(
      current.copyWith(lat: lat, lng: lng),
    );
  }

  void setPhoto(Uint8List bytes, String filename) {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    state = AsyncData<IncidentReportUiState>(
      current.copyWith(photoBytes: bytes, photoFilename: filename),
    );
  }

  void clearPhoto() {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    state = AsyncData<IncidentReportUiState>(
      current.copyWith(clearPhoto: true),
    );
  }

  Future<void> submit() async {
    final IncidentReportUiState current =
        state.value ?? const IncidentReportUiState();
    if (!current.canSubmit) return;
    final String? municipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (municipalityId == null) {
      state = AsyncData<IncidentReportUiState>(
        current.copyWith(failure: const ValidationFailure()),
      );
      return;
    }

    state = AsyncData<IncidentReportUiState>(
      current.copyWith(submitting: true, clearFailure: true),
    );

    final Result<Incident> result = await _reportIncident(
      municipalityId: municipalityId,
      category: current.category!,
      description: current.description.trim(),
      lat: current.lat,
      lng: current.lng,
    );

    switch (result) {
      case Failed<Incident>(:final failure):
        state = AsyncData<IncidentReportUiState>(
          current.copyWith(submitting: false, failure: failure),
        );
      case Success<Incident>(:final value):
        Incident incident = value;
        if (current.photoBytes != null && current.photoFilename != null) {
          final Result<Incident> photoResult = await _uploadPhoto(
            incidentId: incident.id,
            bytes: current.photoBytes!,
            filename: current.photoFilename!,
          );
          if (photoResult is Success<Incident>) {
            incident = photoResult.value;
          }
          // A failed photo upload does not undo a successfully reported
          // incident: the vecino still gets the confirmation, just without
          // the picture attached.
        }
        state = AsyncData<IncidentReportUiState>(
          current.copyWith(submitting: false, submitted: incident),
        );
    }
  }
}
