import '../../domain/entities/managed_business.dart';

class ManagedBusinessModel {
  const ManagedBusinessModel(this.entity);
  final ManagedBusiness entity;

  factory ManagedBusinessModel.fromJson(Map<String, dynamic> json) {
    final rawDescription = json['description'] as Map<String, dynamic>?;
    final rawPhotos = json['photos'] as List<dynamic>? ?? const [];
    return ManagedBusinessModel(
      ManagedBusiness(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        descriptionEs: rawDescription?['es'] as String?,
        descriptionVa: rawDescription?['va'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        website: json['website'] as String?,
        schedule: json['schedule'] as String?,
        active: json['active'] as bool,
        photos: rawPhotos
            .map((raw) {
              final value = raw as Map<String, dynamic>;
              return BusinessPhoto(
                id: value['id'] as String,
                url: value['url'] as String,
                mimeType: value['mimeType'] as String,
                position: value['position'] as int,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
