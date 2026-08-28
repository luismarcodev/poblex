import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

class MunicipalBusiness extends Equatable {
  const MunicipalBusiness({
    required this.id,
    required this.municipalityId,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.schedule,
    required this.photoUrls,
  });

  final String id;
  final String municipalityId;
  final String name;
  final String category;
  final LocalizedText? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? schedule;
  final List<String> photoUrls;

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    name,
    category,
    description,
    address,
    phone,
    email,
    website,
    schedule,
    photoUrls,
  ];
}

class BusinessPage extends Equatable {
  const BusinessPage({required this.items, required this.nextCursor});

  final List<MunicipalBusiness> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];
}
