import '../../domain/entities/managed_facility.dart';

class ManagedFacilityModel {
  const ManagedFacilityModel(this.entity);
  final ManagedFacility entity;

  factory ManagedFacilityModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as Map<String, dynamic>;
    final rawDescription = json['description'] as Map<String, dynamic>?;
    final rawFeeNote = json['feeNote'] as Map<String, dynamic>?;
    final rawHours = json['openingHours'] as Map<String, dynamic>;
    return ManagedFacilityModel(
      ManagedFacility(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        name: FacilityLocalizedText(
          es: rawName['es'] as String? ?? '',
          va: rawName['va'] as String?,
        ),
        description: rawDescription == null
            ? null
            : FacilityLocalizedText(
                es: rawDescription['es'] as String? ?? '',
                va: rawDescription['va'] as String?,
              ),
        category: json['category'] as String,
        imageUrl: json['imageUrl'] as String?,
        slotDurationMinutes: json['slotDurationMinutes'] as int,
        openingHours: {
          for (final day in facilityDayKeys)
            day: _dayHours(rawHours[day] as Map<String, dynamic>?),
        },
        feeNote: rawFeeNote == null
            ? null
            : FacilityLocalizedText(
                es: rawFeeNote['es'] as String? ?? '',
                va: rawFeeNote['va'] as String?,
              ),
        maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int,
        active: json['active'] as bool,
      ),
    );
  }

  static FacilityDayHours? _dayHours(Map<String, dynamic>? json) {
    if (json == null) return null;
    return FacilityDayHours(
      open: json['open'] as String,
      close: json['close'] as String,
    );
  }
}

class ManagedFacilityListModel {
  const ManagedFacilityListModel(this.items);
  final List<ManagedFacility> items;

  factory ManagedFacilityListModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return ManagedFacilityListModel(
      rawItems
          .map(
            (raw) => ManagedFacilityModel.fromJson(
              raw as Map<String, dynamic>,
            ).entity,
          )
          .toList(growable: false),
    );
  }
}

class ManagedReservationModel {
  const ManagedReservationModel(this.entity);
  final ManagedReservation entity;

  factory ManagedReservationModel.fromJson(Map<String, dynamic> json) =>
      ManagedReservationModel(
        ManagedReservation(
          id: json['id'] as String,
          facilityId: json['facilityId'] as String,
          municipalityId: json['municipalityId'] as String,
          slotStart: DateTime.parse(json['slotStart'] as String),
          slotEnd: DateTime.parse(json['slotEnd'] as String),
        ),
      );
}

class ManagedReservationPageModel {
  const ManagedReservationPageModel({required this.items, this.nextCursor});
  final List<ManagedReservation> items;
  final String? nextCursor;

  factory ManagedReservationPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return ManagedReservationPageModel(
      items: rawItems
          .map(
            (raw) => ManagedReservationModel.fromJson(
              raw as Map<String, dynamic>,
            ).entity,
          )
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
