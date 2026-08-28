import '../../domain/entities/duty_pharmacy.dart';

class DutyPharmacyModel {
  const DutyPharmacyModel(this.entity);

  final DutyPharmacy entity;

  factory DutyPharmacyModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'municipalityId': final String municipalityId,
        'date': final String date,
        'pharmacyName': final String pharmacyName,
        'address': final String address,
        'phone': final String phone,
        'schedule': final String schedule,
      } =>
        DutyPharmacyModel(
          DutyPharmacy(
            id: id,
            municipalityId: municipalityId,
            date: parseDutyPharmacyDate(date),
            pharmacyName: pharmacyName,
            address: address,
            phone: phone,
            schedule: schedule,
          ),
        ),
      _ => throw const FormatException('Invalid duty pharmacy response'),
    };
  }

  Map<String, dynamic> toJson({required String municipalityId}) => {
    'municipalityId': municipalityId,
    'date': formatDutyPharmacyDate(entity.date),
    'pharmacyName': entity.pharmacyName.trim(),
    'address': entity.address.trim(),
    'phone': entity.phone.trim(),
    'schedule': entity.schedule.trim(),
  };
}

DateTime parseDutyPharmacyDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) throw const FormatException('Invalid pharmacy date');
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw const FormatException('Invalid pharmacy date');
  }
  return date;
}

String formatDutyPharmacyDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
