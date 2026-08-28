import '../../domain/entities/managed_event.dart';

class ManagedEventModel {
  const ManagedEventModel(this.entity);

  final ManagedEvent entity;

  factory ManagedEventModel.fromJson(Map<String, dynamic> json) {
    EventLocalizedText localized(Object? raw) {
      final value = raw as Map<String, dynamic>;
      return EventLocalizedText(
        es: value['es'] as String? ?? '',
        va: value['va'] as String?,
      );
    }

    return ManagedEventModel(
      ManagedEvent(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        title: localized(json['title']),
        description: localized(json['description']),
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: switch (json['endAt']) {
          final String value => DateTime.parse(value),
          _ => null,
        },
        locationName: json['locationName'] as String?,
        latitude: (json['lat'] as num?)?.toDouble(),
        longitude: (json['lng'] as num?)?.toDouble(),
        category: json['category'] as String,
      ),
    );
  }
}
