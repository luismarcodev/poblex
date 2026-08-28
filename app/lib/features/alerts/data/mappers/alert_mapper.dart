import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/alert.dart';
import '../models/alert_model.dart';

abstract final class AlertMapper {
  static MunicipalAlert toDomain(AlertModel model) => MunicipalAlert(
    id: model.id,
    municipalityId: model.municipalityId,
    source: model.source == 'manual' ? AlertSource.manual : AlertSource.aemet,
    severity: AlertSeverityLevel.fromSlug(model.severity),
    phenomenonType: AlertPhenomenonType.fromSlug(model.phenomenonType),
    phenomenon: model.phenomenon,
    body: LocalizedText(es: model.body.es, va: model.body.va),
    startAt: model.startAt,
    endAt: model.endAt,
    forcesNotification: model.forcesNotification,
  );
}
