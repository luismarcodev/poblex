import '../../../../shared/data/models/localized_text_model.dart';

class FacilityDayHoursModel {
  const FacilityDayHoursModel({required this.open, required this.close});

  final String open;
  final String close;

  factory FacilityDayHoursModel.fromJson(Map<String, dynamic> json) =>
      FacilityDayHoursModel(
        open: json['open'] as String,
        close: json['close'] as String,
      );
}

const List<String> _dayKeys = <String>[
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

class FacilityModel {
  const FacilityModel({
    required this.id,
    required this.municipalityId,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.slotDurationMinutes,
    required this.openingHours,
    required this.feeNote,
    required this.maxAdvanceBookingDays,
    required this.active,
  });

  final String id;
  final String municipalityId;
  final LocalizedTextModel name;
  final LocalizedTextModel? description;
  final String category;
  final String? imageUrl;
  final int slotDurationMinutes;
  final Map<String, FacilityDayHoursModel?> openingHours;
  final LocalizedTextModel? feeNote;
  final int maxAdvanceBookingDays;
  final bool active;

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDescription = json['description'];
    final dynamic rawFeeNote = json['feeNote'];
    final Map<String, dynamic> rawHours = Map<String, dynamic>.from(
      json['openingHours'] as Map,
    );
    return FacilityModel(
      id: json['id'] as String,
      municipalityId: json['municipalityId'] as String,
      name: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      description: rawDescription == null
          ? null
          : LocalizedTextModel.fromJson(
              Map<String, dynamic>.from(rawDescription as Map),
            ),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      slotDurationMinutes: json['slotDurationMinutes'] as int,
      openingHours: <String, FacilityDayHoursModel?>{
        for (final String day in _dayKeys)
          day: rawHours[day] == null
              ? null
              : FacilityDayHoursModel.fromJson(
                  Map<String, dynamic>.from(rawHours[day] as Map),
                ),
      },
      feeNote: rawFeeNote == null
          ? null
          : LocalizedTextModel.fromJson(
              Map<String, dynamic>.from(rawFeeNote as Map),
            ),
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int,
      active: json['active'] as bool,
    );
  }
}

class FacilityListModel {
  const FacilityListModel({required this.items});

  final List<FacilityModel> items;

  factory FacilityListModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return FacilityListModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(FacilityModel.fromJson)
                .toList(growable: false)
          : const <FacilityModel>[],
    );
  }
}

class AvailabilitySlotModel {
  const AvailabilitySlotModel({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlotModel(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );
}

class FacilityAvailabilityModel {
  const FacilityAvailabilityModel({required this.slots});

  final List<AvailabilitySlotModel> slots;

  factory FacilityAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSlots = json['slots'];
    return FacilityAvailabilityModel(
      slots: rawSlots is List<dynamic>
          ? rawSlots
                .whereType<Map<String, dynamic>>()
                .map(AvailabilitySlotModel.fromJson)
                .toList(growable: false)
          : const <AvailabilitySlotModel>[],
    );
  }
}

class ReservationModel {
  const ReservationModel({
    required this.id,
    required this.facilityId,
    required this.municipalityId,
    required this.slotStart,
    required this.slotEnd,
  });

  final String id;
  final String facilityId;
  final String municipalityId;
  final DateTime slotStart;
  final DateTime slotEnd;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      ReservationModel(
        id: json['id'] as String,
        facilityId: json['facilityId'] as String,
        municipalityId: json['municipalityId'] as String,
        slotStart: DateTime.parse(json['slotStart'] as String),
        slotEnd: DateTime.parse(json['slotEnd'] as String),
      );
}

class ReservationPageModel {
  const ReservationPageModel({required this.items, this.nextCursor});

  final List<ReservationModel> items;
  final String? nextCursor;

  factory ReservationPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return ReservationPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(ReservationModel.fromJson)
                .toList(growable: false)
          : const <ReservationModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
