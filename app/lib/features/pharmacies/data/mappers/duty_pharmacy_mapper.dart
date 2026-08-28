import '../../domain/entities/duty_pharmacy.dart';
import '../models/duty_pharmacy_model.dart';

abstract final class DutyPharmacyMapper {
  static DutyPharmacy toDomain(DutyPharmacyModel model) => DutyPharmacy(
    id: model.id,
    municipalityId: model.municipalityId,
    date: model.date,
    pharmacyName: model.pharmacyName,
    address: model.address,
    phone: model.phone,
    schedule: model.schedule,
  );
}
