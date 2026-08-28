import 'package:equatable/equatable.dart';

class EventLocalizedText extends Equatable {
  const EventLocalizedText({required this.es, this.va});

  final String es;
  final String? va;

  Map<String, dynamic> toJson() => {
    'es': es.trim(),
    if (va != null && va!.trim().isNotEmpty) 'va': va!.trim(),
  };

  @override
  List<Object?> get props => [es, va];
}

enum ManagedEventStatus { upcoming, ongoing, past }

class ManagedEvent extends Equatable {
  const ManagedEvent({
    required this.id,
    required this.municipalityId,
    required this.title,
    required this.description,
    required this.startAt,
    required this.category,
    this.endAt,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String municipalityId;
  final EventLocalizedText title;
  final EventLocalizedText description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String category;

  ManagedEventStatus statusAt(DateTime now) {
    if (startAt.isAfter(now)) return ManagedEventStatus.upcoming;
    final end = endAt;
    if (end != null && end.isAfter(now)) return ManagedEventStatus.ongoing;
    return ManagedEventStatus.past;
  }

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    title,
    description,
    startAt,
    endAt,
    locationName,
    latitude,
    longitude,
    category,
  ];
}

class ManagedEventsPage extends Equatable {
  const ManagedEventsPage({required this.items, required this.nextCursor});

  final List<ManagedEvent> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

class SaveEventInput extends Equatable {
  const SaveEventInput({
    required this.title,
    required this.description,
    required this.startAt,
    required this.category,
    required this.municipalityIds,
    this.id,
    this.endAt,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  final String? id;
  final EventLocalizedText title;
  final EventLocalizedText description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String category;
  final List<String> municipalityIds;

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startAt,
    endAt,
    locationName,
    latitude,
    longitude,
    category,
    municipalityIds,
  ];
}
