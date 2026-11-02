import 'package:equatable/equatable.dart';

class FacilityLocalizedText extends Equatable {
  const FacilityLocalizedText({required this.es, this.va});

  final String es;
  final String? va;

  Map<String, dynamic> toJson() => {
    'es': es.trim(),
    if (va != null && va!.trim().isNotEmpty) 'va': va!.trim(),
  };

  @override
  List<Object?> get props => [es, va];
}

const List<String> facilityDayKeys = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

class FacilityDayHours extends Equatable {
  const FacilityDayHours({required this.open, required this.close});

  /// "HH:mm".
  final String open;
  final String close;

  @override
  List<Object?> get props => [open, close];
}

class ManagedFacility extends Equatable {
  const ManagedFacility({
    required this.id,
    required this.municipalityId,
    required this.name,
    required this.category,
    required this.slotDurationMinutes,
    required this.openingHours,
    required this.maxAdvanceBookingDays,
    required this.active,
    this.description,
    this.imageUrl,
    this.feeNote,
  });

  final String id;
  final String municipalityId;
  final FacilityLocalizedText name;
  final FacilityLocalizedText? description;
  final String category;
  final String? imageUrl;
  final int slotDurationMinutes;

  /// Keyed by `mon`..`sun`; `null` value means closed that day.
  final Map<String, FacilityDayHours?> openingHours;
  final FacilityLocalizedText? feeNote;
  final int maxAdvanceBookingDays;
  final bool active;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    name,
    description,
    category,
    imageUrl,
    slotDurationMinutes,
    openingHours,
    feeNote,
    maxAdvanceBookingDays,
    active,
  ];
}

class ManagedFacilityPage extends Equatable {
  const ManagedFacilityPage({required this.items});
  final List<ManagedFacility> items;
  @override
  List<Object?> get props => [items];
}

class SaveFacilityInput extends Equatable {
  const SaveFacilityInput({
    required this.municipalityId,
    required this.name,
    required this.category,
    required this.slotDurationMinutes,
    required this.openingHours,
    required this.maxAdvanceBookingDays,
    this.id,
    this.description,
    this.feeNote,
    this.active = true,
  });

  final String? id;
  final String municipalityId;
  final FacilityLocalizedText name;
  final FacilityLocalizedText? description;
  final String category;
  final int slotDurationMinutes;
  final Map<String, FacilityDayHours?> openingHours;
  final FacilityLocalizedText? feeNote;
  final int maxAdvanceBookingDays;
  final bool active;

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    name,
    description,
    category,
    slotDurationMinutes,
    openingHours,
    feeNote,
    maxAdvanceBookingDays,
    active,
  ];
}

class ManagedReservation extends Equatable {
  const ManagedReservation({
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

  @override
  List<Object?> get props => [
    id,
    facilityId,
    municipalityId,
    slotStart,
    slotEnd,
  ];
}

class ManagedReservationPage extends Equatable {
  const ManagedReservationPage({required this.items, required this.nextCursor});
  final List<ManagedReservation> items;
  final String? nextCursor;
  @override
  List<Object?> get props => [items, nextCursor];
}
