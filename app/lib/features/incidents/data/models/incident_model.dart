class IncidentStatusChangeModel {
  const IncidentStatusChangeModel({
    required this.status,
    required this.note,
    required this.changedAt,
  });

  final String status;
  final String? note;
  final DateTime changedAt;

  factory IncidentStatusChangeModel.fromJson(Map<String, dynamic> json) =>
      IncidentStatusChangeModel(
        status: json['status'] as String,
        note: json['note'] as String?,
        changedAt: DateTime.parse(json['changedAt'] as String),
      );
}

class IncidentModel {
  const IncidentModel({
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
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory IncidentModel.fromJson(Map<String, dynamic> json) => IncidentModel(
    id: json['id'] as String,
    municipalityId: json['municipalityId'] as String,
    category: json['category'] as String,
    description: json['description'] as String,
    photoUrl: json['photoUrl'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class IncidentDetailModel {
  const IncidentDetailModel({required this.incident, required this.history});

  final IncidentModel incident;
  final List<IncidentStatusChangeModel> history;

  factory IncidentDetailModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawHistory = json['history'];
    return IncidentDetailModel(
      incident: IncidentModel.fromJson(json),
      history: rawHistory is List<dynamic>
          ? rawHistory
                .whereType<Map<String, dynamic>>()
                .map(IncidentStatusChangeModel.fromJson)
                .toList(growable: false)
          : const <IncidentStatusChangeModel>[],
    );
  }
}

class IncidentPageModel {
  const IncidentPageModel({required this.items, this.nextCursor});

  final List<IncidentModel> items;
  final String? nextCursor;

  factory IncidentPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return IncidentPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(IncidentModel.fromJson)
                .toList(growable: false)
          : const <IncidentModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
