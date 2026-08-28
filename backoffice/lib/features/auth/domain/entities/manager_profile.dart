import 'package:equatable/equatable.dart';

class ManagedMunicipality extends Equatable {
  const ManagedMunicipality({
    required this.id,
    required this.name,
    required this.province,
    required this.languages,
    this.primaryColor,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String province;
  final List<String> languages;
  final String? primaryColor;
  final String? logoUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    province,
    languages,
    primaryColor,
    logoUrl,
  ];
}

class ManagerProfile extends Equatable {
  const ManagerProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.municipalities,
  });

  final String id;
  final String email;
  final String displayName;
  final List<ManagedMunicipality> municipalities;

  @override
  List<Object?> get props => [id, email, displayName, municipalities];
}
