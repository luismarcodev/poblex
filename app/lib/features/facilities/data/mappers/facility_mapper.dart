import '../../../../shared/data/models/localized_text_model.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/facility.dart';
import '../models/facility_model.dart';

abstract final class FacilityMapper {
  static LocalizedText? _toLocalizedText(LocalizedTextModel? model) =>
      model == null ? null : LocalizedText(es: model.es, va: model.va);

  static Facility toDomain(FacilityModel model) => Facility(
    id: model.id,
    municipalityId: model.municipalityId,
    name: LocalizedText(es: model.name.es, va: model.name.va),
    description: _toLocalizedText(model.description),
    category: model.category,
    imageUrl: model.imageUrl,
    slotDurationMinutes: model.slotDurationMinutes,
    openingHours: model.openingHours.map(
      (String day, FacilityDayHoursModel? hours) =>
          MapEntry<String, FacilityDayHours?>(
            day,
            hours == null
                ? null
                : FacilityDayHours(open: hours.open, close: hours.close),
          ),
    ),
    feeNote: _toLocalizedText(model.feeNote),
    maxAdvanceBookingDays: model.maxAdvanceBookingDays,
    active: model.active,
  );

  static AvailabilitySlot toSlotDomain(AvailabilitySlotModel model) =>
      AvailabilitySlot(start: model.start, end: model.end);

  static Reservation toReservationDomain(ReservationModel model) => Reservation(
    id: model.id,
    facilityId: model.facilityId,
    municipalityId: model.municipalityId,
    slotStart: model.slotStart,
    slotEnd: model.slotEnd,
  );
}
