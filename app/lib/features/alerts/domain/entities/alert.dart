import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

enum AlertSeverityLevel {
  yellow(slug: 'amarillo'),
  orange(slug: 'naranja'),
  red(slug: 'rojo');

  const AlertSeverityLevel({required this.slug});

  /// The exact backend/AEMET slug, also the placeholder `alertSeverityLabel`
  /// expects — keeping it here avoids a second translation table drifting
  /// out of sync with the one in the ARB files.
  final String slug;

  static AlertSeverityLevel fromSlug(String slug) => switch (slug) {
    'rojo' => AlertSeverityLevel.red,
    'naranja' => AlertSeverityLevel.orange,
    _ => AlertSeverityLevel.yellow,
  };
}

enum AlertSource { aemet, manual }

/// Clasificación por tipo de fenómeno, independiente de [AlertSeverityLevel]:
/// nunca la sustituye, se le añade. AEMET siempre trae `meteorologico`
/// (fijado en `sync-aemet-alerts.use-case.ts`); incendio y evacuación son
/// siempre de origen manual — no hay integración automática de datos de
/// incendio forestal.
enum AlertPhenomenonType {
  incendio(slug: 'incendio'),
  evacuacion(slug: 'evacuacion'),
  meteorologico(slug: 'meteorologico'),
  sanitario(slug: 'sanitario'),
  otro(slug: 'otro');

  const AlertPhenomenonType({required this.slug});

  final String slug;

  static AlertPhenomenonType fromSlug(String slug) => switch (slug) {
    'incendio' => AlertPhenomenonType.incendio,
    'evacuacion' => AlertPhenomenonType.evacuacion,
    'sanitario' => AlertPhenomenonType.sanitario,
    'meteorologico' => AlertPhenomenonType.meteorologico,
    _ => AlertPhenomenonType.otro,
  };
}

class MunicipalAlert extends Equatable {
  const MunicipalAlert({
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
  final AlertSource source;
  final AlertSeverityLevel severity;
  final AlertPhenomenonType phenomenonType;
  final String phenomenon;
  final LocalizedText body;
  final DateTime startAt;
  final DateTime? endAt;

  /// True only for red alerts: the app must show these regardless of the
  /// vecino's muted categories.
  final bool forcesNotification;

  bool isActiveAt(DateTime instant) => endAt == null || endAt!.isAfter(instant);

  @override
  List<Object?> get props => <Object?>[
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
  ];
}

class AlertPage extends Equatable {
  const AlertPage({required this.items, required this.nextCursor});

  final List<MunicipalAlert> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
