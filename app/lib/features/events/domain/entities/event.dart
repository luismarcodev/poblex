import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

class MunicipalEvent extends Equatable {
  const MunicipalEvent({
    required this.id,
    required this.municipalityId,
    required this.title,
    required this.description,
    required this.startAt,
    required this.category,
    this.endAt,
    this.locationName,
    this.lat,
    this.lng,
  });

  final String id;
  final String municipalityId;
  final LocalizedText title;
  final LocalizedText description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? locationName;
  final double? lat;
  final double? lng;
  final String category;

  bool isPastAt(DateTime instant) => startAt.isBefore(instant);

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    title,
    description,
    startAt,
    endAt,
    locationName,
    lat,
    lng,
    category,
  ];
}

class EventPage extends Equatable {
  const EventPage({required this.items, this.nextCursor});

  final List<MunicipalEvent> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
