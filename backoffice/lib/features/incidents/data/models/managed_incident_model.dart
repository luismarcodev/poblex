import '../../domain/entities/managed_incident.dart';

class ManagedIncidentModel {
  const ManagedIncidentModel(this.entity);

  final ManagedIncident entity;

  factory ManagedIncidentModel.fromJson(Map<String, dynamic> json) {
    final latitude = (json['lat'] as num?)?.toDouble();
    final longitude = (json['lng'] as num?)?.toDouble();
    if ((latitude == null) != (longitude == null)) {
      throw const FormatException('Incomplete incident coordinates');
    }
    return ManagedIncidentModel(
      ManagedIncident(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        photoUrl: json['photoUrl'] as String?,
        latitude: latitude,
        longitude: longitude,
        status: IncidentStatus.fromApi(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      ),
    );
  }
}
