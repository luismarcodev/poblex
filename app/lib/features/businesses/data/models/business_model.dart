import '../../../../shared/data/models/localized_text_model.dart';

class BusinessModel {
  const BusinessModel({
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
  final LocalizedTextModel? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? schedule;
  final List<String> photoUrls;

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDescription = json['description'];
    final dynamic rawPhotos = json['photos'];
    return BusinessModel(
      id: json['id'] as String,
      municipalityId: json['municipalityId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: rawDescription == null
          ? null
          : LocalizedTextModel.fromJson(
              Map<String, dynamic>.from(rawDescription as Map),
            ),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      schedule: json['schedule'] as String?,
      // El backend ya las devuelve ordenadas por posición de galería.
      photoUrls: rawPhotos is List<dynamic>
          ? rawPhotos
                .whereType<Map<String, dynamic>>()
                .map((Map<String, dynamic> photo) => photo['url'] as String)
                .toList(growable: false)
          : const <String>[],
    );
  }
}

class BusinessPageModel {
  const BusinessPageModel({required this.items, this.nextCursor});

  final List<BusinessModel> items;
  final String? nextCursor;

  factory BusinessPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return BusinessPageModel(
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(BusinessModel.fromJson)
                .toList(growable: false)
          : const <BusinessModel>[],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
