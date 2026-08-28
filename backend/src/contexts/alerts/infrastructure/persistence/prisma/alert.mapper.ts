import type {
  Alert as PrismaAlert,
  AlertPhenomenonType as PrismaAlertPhenomenonType,
  AlertSeverity as PrismaAlertSeverity,
  AlertSource as PrismaAlertSource,
} from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Alert } from '../../../domain/entities/alert.entity';
import { AlertPhenomenonType } from '../../../domain/value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../../../domain/value-objects/alert-severity.vo';
import { AlertSource } from '../../../domain/value-objects/alert-source.vo';

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

// Los enums de Prisma van en mayúsculas; los del dominio, en minúsculas y con
// significado propio. La traducción vive aquí, en el adaptador.
export class AlertMapper {
  static toDomain(row: PrismaAlert): Alert {
    return Alert.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      source: AlertSource.create(row.source.toLowerCase()),
      severity: AlertSeverity.create(row.severity.toLowerCase()),
      phenomenonType: AlertPhenomenonType.create(
        row.phenomenonType.toLowerCase(),
      ),
      phenomenon: row.phenomenon,
      body: LocalizedText.create(row.body as RawLocalizedJson),
      startAt: row.startAt,
      endAt: row.endAt,
      aemetId: row.aemetId,
      createdBy: row.createdBy,
      updatedBy: row.updatedBy,
      createdAt: row.createdAt,
    });
  }

  static toPrismaSource(source: AlertSource): PrismaAlertSource {
    return source.value.toUpperCase() as PrismaAlertSource;
  }

  static toPrismaSeverity(severity: AlertSeverity): PrismaAlertSeverity {
    return severity.value.toUpperCase() as PrismaAlertSeverity;
  }

  static toPrismaPhenomenonType(
    type: AlertPhenomenonType,
  ): PrismaAlertPhenomenonType {
    return type.value.toUpperCase() as PrismaAlertPhenomenonType;
  }
}
