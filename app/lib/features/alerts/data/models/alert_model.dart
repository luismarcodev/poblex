import '../../../../shared/data/models/localized_text_model.dart';

class AlertModel {
  const AlertModel({
    required this.id,
    required this.municipalityId,
    required this.source,
    required this.severity,
    required this.phenomenonType,
    required this.phenomenon,
    required this.body,
    required this.startAt,
    required this.endAt,
    required this.forcesNotification,
  });

  final String id;
  final String municipalityId;
  final String source;
  final String severity;
  final String phenomenonType;
  final String phenomenon;
  final LocalizedTextModel body;
  final DateTime startAt;
  final DateTime? endAt;
  final bool forcesNotification;

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
    id: json['id'] as String,
    municipalityId: json['municipalityId'] as String,
    source: json['source'] as String,
    severity: json['severity'] as String,
    phenomenonType: json['phenomenonType'] as String,
    phenomenon: json['phenomenon'] as String,
    body: LocalizedTextModel.fromJson(
      Map<String, dynamic>.from(json['body'] as Map),
    ),
    startAt: DateTime.parse(json['startAt'] as String),
    endAt: json['endAt'] == null
        ? null
        : DateTime.parse(json['endAt'] as String),
    forcesNotification: json['forcesNotification'] as bool,
  );
}

class AlertPageModel {
  const AlertPageModel({required this.items, this.nextCursor});

  final List<AlertModel> items;
  final String? nextCursor;

  factory AlertPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return AlertPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(AlertModel.fromJson)
                .toList(growable: false)
          : const <AlertModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
