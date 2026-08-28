import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart' as design;

import '../../domain/entities/alert.dart';

/// Maps the domain severity (parsed from the backend's Spanish slug) to the
/// design system's [design.AlertSeverity], which owns the colour tokens and
/// the R3 bar-width channel. Two enums on purpose: the domain stays free of
/// Flutter/theme imports, only presentation knows about the design package.
design.AlertSeverity toDesignSeverity(AlertSeverityLevel level) =>
    switch (level) {
      AlertSeverityLevel.yellow => design.AlertSeverity.yellow,
      AlertSeverityLevel.orange => design.AlertSeverity.orange,
      AlertSeverityLevel.red => design.AlertSeverity.red,
    };

/// Distinct silhouette per level (R3): a lookalike colour is not enough for
/// a vecino reading the app in direct sunlight, so the icon shape itself
/// must change, not just its fill.
IconData severityIcon(AlertSeverityLevel level) => switch (level) {
  AlertSeverityLevel.yellow => Icons.info_outline,
  AlertSeverityLevel.orange => Icons.warning_amber_rounded,
  AlertSeverityLevel.red => Icons.emergency_outlined,
};

/// Icono por tipo de fenómeno, capa aparte de la severidad: un incendio y una
/// inundación pueden ser ambos severidad roja, esto es lo que los distingue
/// de un vistazo sin tocar color/barra/severidad (bloqueados a la paleta
/// AEMET). Para meteorológico/otro cae al icono de severidad de siempre — el
/// comportamiento actual de cualquier alerta meteorológica no cambia.
IconData phenomenonIcon(
  AlertPhenomenonType type,
  AlertSeverityLevel severity,
) => switch (type) {
  AlertPhenomenonType.incendio => Icons.local_fire_department,
  AlertPhenomenonType.evacuacion => Icons.directions_run,
  AlertPhenomenonType.sanitario => Icons.medical_services_outlined,
  AlertPhenomenonType.meteorologico ||
  AlertPhenomenonType.otro => severityIcon(severity),
};
