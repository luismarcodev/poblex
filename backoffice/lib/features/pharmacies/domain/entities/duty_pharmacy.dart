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
  final DateTime date;
  final String pharmacyName;
  final String address;
  final String phone;
  final String schedule;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    date,
    pharmacyName,
    address,
    phone,
    schedule,
  ];
}

class SaveDutyPharmacyInput extends Equatable {
  const SaveDutyPharmacyInput({
    required this.date,
    required this.pharmacyName,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.municipalityIds,
    this.replaceExisting = false,
  });

  final DateTime date;
  final String pharmacyName;
  final String address;
  final String phone;
  final String schedule;
  final List<String> municipalityIds;
  final bool replaceExisting;

  @override
  List<Object?> get props => [
    date,
    pharmacyName,
    address,
    phone,
    schedule,
    municipalityIds,
    replaceExisting,
  ];
}
