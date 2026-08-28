import '../../domain/entities/managed_alert.dart';

class ManagedAlertModel {
  const ManagedAlertModel(this.entity);

  final ManagedAlert entity;

  factory ManagedAlertModel.fromJson(Map<String, dynamic> json) {
    final body = json['body'];
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Missing alert body');
    }

    return ManagedAlertModel(
      ManagedAlert(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        source: switch (json['source']) {
          'manual' => ManagedAlertSource.manual,
          'aemet' => ManagedAlertSource.aemet,
          final value => throw FormatException('Unknown alert source: $value'),
        },
        severity: ManagedAlertSeverity.fromApi(json['severity'] as String),
        phenomenonType: ManagedAlertPhenomenonType.fromApi(
          json['phenomenonType'] as String,
        ),
        phenomenon: json['phenomenon'] as String,
        body: AlertLocalizedText(
          es: body['es'] as String? ?? '',
          va: body['va'] as String?,
        ),
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: switch (json['endAt']) {
          final String value => DateTime.parse(value),
          _ => null,
        },
        forcesNotification: json['forcesNotification'] as bool? ?? false,
        createdBy: json['createdBy'] as String?,
        updatedBy: json['updatedBy'] as String?,
        createdAt: switch (json['createdAt']) {
          final String value => DateTime.parse(value),
          _ => null,
        },
      ),
    );
  }
}
