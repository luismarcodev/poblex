import 'package:equatable/equatable.dart';

class AlertLocalizedText extends Equatable {
  const AlertLocalizedText({required this.es, this.va});

  final String es;
  final String? va;

  Map<String, dynamic> toJson() => {
    'es': es.trim(),
    if (va != null && va!.trim().isNotEmpty) 'va': va!.trim(),
  };

  String resolve(String languageCode) {
    if (languageCode == 'ca' && va != null && va!.trim().isNotEmpty) {
      return va!;
    }
    return es.trim().isNotEmpty ? es : va ?? '';
  }

  @override
  List<Object?> get props => [es, va];
}

enum ManagedAlertSource { aemet, manual }

enum ManagedAlertSeverity {
  yellow(apiValue: 'amarillo', level: 1),
  orange(apiValue: 'naranja', level: 2),
  red(apiValue: 'rojo', level: 3);

  const ManagedAlertSeverity({required this.apiValue, required this.level});

  final String apiValue;
  final int level;

  static ManagedAlertSeverity fromApi(String value) => switch (value) {
    'amarillo' => ManagedAlertSeverity.yellow,
    'naranja' => ManagedAlertSeverity.orange,
    'rojo' => ManagedAlertSeverity.red,
    _ => throw FormatException('Unknown alert severity: $value'),
  };
}

/// Clasificación por tipo de fenómeno, independiente de [ManagedAlertSeverity]:
/// nunca la sustituye. AEMET siempre trae `meteorologico`; incendio y
/// evacuación son siempre de origen manual. El orden de declaración es
/// también el orden del selector en el editor — incendio/evacuación
/// primero, a propósito (énfasis de producto).
enum ManagedAlertPhenomenonType {
  incendio(apiValue: 'incendio'),
  evacuacion(apiValue: 'evacuacion'),
  sanitario(apiValue: 'sanitario'),
  meteorologico(apiValue: 'meteorologico'),
  otro(apiValue: 'otro');

  const ManagedAlertPhenomenonType({required this.apiValue});

  final String apiValue;

  static ManagedAlertPhenomenonType fromApi(String value) => switch (value) {
    'incendio' => ManagedAlertPhenomenonType.incendio,
    'evacuacion' => ManagedAlertPhenomenonType.evacuacion,
    'sanitario' => ManagedAlertPhenomenonType.sanitario,
    'meteorologico' => ManagedAlertPhenomenonType.meteorologico,
    'otro' => ManagedAlertPhenomenonType.otro,
    _ => throw FormatException('Unknown alert phenomenon type: $value'),
  };
}

enum ManagedAlertStatus { scheduled, active, expired }

class ManagedAlert extends Equatable {
  const ManagedAlert({
    required this.id,
    required this.municipalityId,
    required this.source,
    required this.severity,
    required this.phenomenonType,
    required this.phenomenon,
    required this.body,
    required this.startAt,
    required this.forcesNotification,
    this.endAt,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
  });

  final String id;
  final String municipalityId;
  final ManagedAlertSource source;
  final ManagedAlertSeverity severity;
  final ManagedAlertPhenomenonType phenomenonType;
  final String phenomenon;
  final AlertLocalizedText body;
  final DateTime startAt;
  final DateTime? endAt;
  final bool forcesNotification;

  /// Optional until the admin API exposes the audit fields.
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;

  bool get canManage => source == ManagedAlertSource.manual;

  ManagedAlertStatus statusAt(DateTime instant) {
    if (startAt.isAfter(instant)) return ManagedAlertStatus.scheduled;
    final end = endAt;
    if (end != null && end.isBefore(instant)) {
      return ManagedAlertStatus.expired;
    }
    return ManagedAlertStatus.active;
  }

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    source,
    severity,
    phenomenonType,
    phenomenon,
    body,
    startAt,
    endAt,
    forcesNotification,
    createdBy,
    updatedBy,
    createdAt,
  ];
}

class ManagedAlertsPage extends Equatable {
  const ManagedAlertsPage({required this.items, required this.nextCursor});

  final List<ManagedAlert> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

class SaveManualAlertInput extends Equatable {
  const SaveManualAlertInput({
    required this.municipalityId,
    required this.severity,
    required this.phenomenonType,
    required this.phenomenon,
    required this.body,
    required this.startAt,
    this.id,
    this.endAt,
  });

  final String? id;
  final String municipalityId;
  final ManagedAlertSeverity severity;
  final ManagedAlertPhenomenonType phenomenonType;
  final String phenomenon;
  final AlertLocalizedText body;
  final DateTime startAt;
  final DateTime? endAt;

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    severity,
    phenomenonType,
    phenomenon,
    body,
    startAt,
    endAt,
  ];
}
