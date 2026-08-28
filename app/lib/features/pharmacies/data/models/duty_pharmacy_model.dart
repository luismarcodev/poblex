class DutyPharmacyModel {
  const DutyPharmacyModel({
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

  factory DutyPharmacyModel.fromJson(Map<String, dynamic> json) =>
      DutyPharmacyModel(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        date: DateTime.parse(json['date'] as String),
        pharmacyName: json['pharmacyName'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String,
        schedule: json['schedule'] as String,
      );
}
