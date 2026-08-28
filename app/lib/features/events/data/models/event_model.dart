import '../../../../shared/data/models/localized_text_model.dart';

class EventModel {
  const EventModel({
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
  final LocalizedTextModel title;
  final LocalizedTextModel description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? locationName;
  final double? lat;
  final double? lng;
  final String category;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] as String,
    municipalityId: json['municipalityId'] as String,
    title: LocalizedTextModel.fromJson(
      Map<String, dynamic>.from(json['title'] as Map),
    ),
    description: LocalizedTextModel.fromJson(
      Map<String, dynamic>.from(json['description'] as Map),
    ),
    startAt: DateTime.parse(json['startAt'] as String),
    endAt: json['endAt'] == null
        ? null
        : DateTime.parse(json['endAt'] as String),
    locationName: json['locationName'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    category: json['category'] as String,
  );
}

class EventPageModel {
  const EventPageModel({required this.items, this.nextCursor});

  final List<EventModel> items;
  final String? nextCursor;

  factory EventPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return EventPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(EventModel.fromJson)
                .toList(growable: false)
          : const <EventModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
