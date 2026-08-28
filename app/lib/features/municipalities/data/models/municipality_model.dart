class MunicipalityModel {
  const MunicipalityModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.province,
    required this.languages,
    this.primaryColor,
    this.logoUrl,
  });

  final String id;
  final String slug;
  final String name;
  final String province;
  final List<String> languages;
  final String? primaryColor;
  final String? logoUrl;

  factory MunicipalityModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawLanguages = json['languages'];
    return MunicipalityModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      languages: rawLanguages is List<dynamic>
          ? rawLanguages.whereType<String>().toList(growable: false)
          : const <String>[],
      primaryColor: json['primaryColor'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
