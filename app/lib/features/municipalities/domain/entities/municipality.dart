import 'package:equatable/equatable.dart';

class Municipality extends Equatable {
  const Municipality({
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

  @override
  List<Object?> get props => <Object?>[
    id,
    slug,
    name,
    province,
    languages,
    primaryColor,
    logoUrl,
  ];
}
