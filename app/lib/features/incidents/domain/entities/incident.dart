import 'package:equatable/equatable.dart';

enum IncidentStatus {
  received(slug: 'recibido'),
  inProgress(slug: 'en_curso'),
  resolved(slug: 'resuelta');

  const IncidentStatus({required this.slug});

  final String slug;

  static IncidentStatus fromSlug(String slug) => switch (slug) {
    'en_curso' => IncidentStatus.inProgress,
    'resuelta' => IncidentStatus.resolved,
    _ => IncidentStatus.received,
  };
}

class IncidentStatusChange extends Equatable {
  const IncidentStatusChange({
    required this.status,
    required this.note,
    required this.changedAt,
  });

  final IncidentStatus status;
  final String? note;
  final DateTime changedAt;

  @override
  List<Object?> get props => <Object?>[status, note, changedAt];
}

class Incident extends Equatable {
  const Incident({
    required this.id,
    required this.municipalityId,
    required this.category,
    required this.description,
    required this.photoUrl,
    required this.lat,
    required this.lng,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String municipalityId;
  final String category;
  final String description;
  final String? photoUrl;
  final double? lat;
  final double? lng;
  final IncidentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    category,
    description,
    photoUrl,
    lat,
    lng,
    status,
    createdAt,
    updatedAt,
  ];
}

class IncidentDetail extends Equatable {
  const IncidentDetail({required this.incident, required this.history});

  final Incident incident;
  final List<IncidentStatusChange> history;

  @override
  List<Object?> get props => <Object?>[incident, history];
}

class IncidentPage extends Equatable {
  const IncidentPage({required this.items, required this.nextCursor});

  final List<Incident> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
