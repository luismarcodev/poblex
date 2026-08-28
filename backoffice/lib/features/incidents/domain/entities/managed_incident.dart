import 'package:equatable/equatable.dart';

enum IncidentStatus {
  received('recibido'),
  inProgress('en_curso'),
  resolved('resuelta');

  const IncidentStatus(this.apiValue);

  final String apiValue;

  static IncidentStatus fromApi(String value) => switch (value) {
    'recibido' => IncidentStatus.received,
    'en_curso' => IncidentStatus.inProgress,
    'resuelta' => IncidentStatus.resolved,
    _ => throw FormatException('Unknown incident status: $value'),
  };

  bool canTransitionTo(IncidentStatus next) {
    if (this == next || this == IncidentStatus.resolved) return false;
    return this == IncidentStatus.received || next == IncidentStatus.resolved;
  }
}

class ManagedIncident extends Equatable {
  const ManagedIncident({
    required this.id,
    required this.municipalityId,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.latitude,
    this.longitude,
  }) : assert(
         (latitude == null) == (longitude == null),
         'Incident coordinates must be provided together',
       );

  final String id;
  final String municipalityId;
  final String category;
  final String description;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final IncidentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasCoordinates => latitude != null && longitude != null;

  ManagedIncident copyWith({IncidentStatus? status, DateTime? updatedAt}) =>
      ManagedIncident(
        id: id,
        municipalityId: municipalityId,
        category: category,
        description: description,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    category,
    description,
    photoUrl,
    latitude,
    longitude,
    status,
    createdAt,
    updatedAt,
  ];
}

class ManagedIncidentsPage extends Equatable {
  const ManagedIncidentsPage({required this.items, required this.nextCursor});

  final List<ManagedIncident> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

class ChangeIncidentStatusInput extends Equatable {
  const ChangeIncidentStatusInput({
    required this.incident,
    required this.status,
    this.note,
  });

  final ManagedIncident incident;
  final IncidentStatus status;
  final String? note;

  @override
  List<Object?> get props => [incident, status, note];
}
