import '../../domain/entities/manager_profile.dart';

class ManagerProfileModel {
  const ManagerProfileModel({required this.profile});
  final ManagerProfile profile;

  factory ManagerProfileModel.fromJson(Map<String, dynamic> json) {
    final rawMunicipalities = json['municipalities'];
    if (rawMunicipalities is! List<dynamic>) {
      throw const FormatException('Invalid manager municipalities');
    }
    return ManagerProfileModel(
      profile: ManagerProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        municipalities: rawMunicipalities
            .map((raw) {
              final value = raw as Map<String, dynamic>;
              final rawLanguages = value['languages'] as List<dynamic>;
              return ManagedMunicipality(
                id: value['id'] as String,
                name: value['name'] as String,
                province: value['province'] as String,
                languages: rawLanguages.cast<String>(),
                primaryColor: value['primaryColor'] as String?,
                logoUrl: value['logoUrl'] as String?,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
