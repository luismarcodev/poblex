import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

class FacilityDayHours extends Equatable {
  const FacilityDayHours({required this.open, required this.close});

  /// "HH:mm", server clock time (UTC, no timezone conversion — see backend
  /// OpeningHours VO comment for why).
  final String open;
  final String close;

  @override
  List<Object?> get props => <Object?>[open, close];
}

class Facility extends Equatable {
  const Facility({
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
  final LocalizedText name;
  final LocalizedText? description;
  final String category;
  final String? imageUrl;
  final int slotDurationMinutes;

  /// Keyed by `mon`..`sun`; `null` value means closed that day.
  final Map<String, FacilityDayHours?> openingHours;
  final LocalizedText? feeNote;
  final int maxAdvanceBookingDays;
  final bool active;

  @override
  List<Object?> get props => <Object?>[
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

class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => <Object?>[start, end];
}

class Reservation extends Equatable {
  const Reservation({
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
  List<Object?> get props => <Object?>[
    id,
    facilityId,
    municipalityId,
    slotStart,
    slotEnd,
  ];
}

class ReservationPage extends Equatable {
  const ReservationPage({required this.items, required this.nextCursor});

  final List<Reservation> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
