import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/pharmacies/data/models/duty_pharmacy_model.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';

void main() {
  test('maps the complete duty pharmacy contract', () {
    final model = DutyPharmacyModel.fromJson(_response);

    expect(model.entity.id, 'pharmacy-1');
    expect(model.entity.municipalityId, 'municipality-1');
    expect(model.entity.date, DateTime(2026, 8, 12));
    expect(model.entity.pharmacyName, 'Farmacia Ribera');
    expect(model.entity.address, 'Carrer Major, 12');
    expect(model.entity.phone, '961 234 567');
    expect(model.entity.schedule, '9:00 - 22:00');
  });

  test('serializes a trimmed date-only upsert payload', () {
    final model = DutyPharmacyModel(
      DutyPharmacy(
        id: '',
        municipalityId: 'municipality-1',
        date: DateTime(2026, 8, 2, 23, 45),
        pharmacyName: ' Farmacia Ribera ',
        address: ' Carrer Major, 12 ',
        phone: ' 961 234 567 ',
        schedule: ' 9:00 - 22:00 ',
      ),
    );

    expect(model.toJson(municipalityId: 'municipality-1'), {
      'municipalityId': 'municipality-1',
      'date': '2026-08-02',
      'pharmacyName': 'Farmacia Ribera',
      'address': 'Carrer Major, 12',
      'phone': '961 234 567',
      'schedule': '9:00 - 22:00',
    });
  });

  test('rejects impossible and time-bearing API dates', () {
    expect(() => parseDutyPharmacyDate('2026-02-30'), throwsFormatException);
    expect(
      () => parseDutyPharmacyDate('2026-08-12T00:00:00.000Z'),
      throwsFormatException,
    );
  });
}

final Map<String, dynamic> _response = {
  'id': 'pharmacy-1',
  'municipalityId': 'municipality-1',
  'date': '2026-08-12',
  'pharmacyName': 'Farmacia Ribera',
  'address': 'Carrer Major, 12',
  'phone': '961 234 567',
  'schedule': '9:00 - 22:00',
};
