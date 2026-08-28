import 'package:equatable/equatable.dart';

class DutyPharmacy extends Equatable {
  const DutyPharmacy({
    required this.id,
    required this.municipalityId,
    required this.date,
    required this.pharmacyName,
    required this.address,
    required this.phone,
    required this.schedule,
  });

  final String id;
  final String municipalityId;

  /// Day-only — the backend never sends a time component for this field.
  final DateTime date;
  final String pharmacyName;
  final String address;
  final String phone;
  final String schedule;

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    date,
    pharmacyName,
    address,
    phone,
    schedule,
  ];
}
