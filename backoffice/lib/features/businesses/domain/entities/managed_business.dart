import 'package:equatable/equatable.dart';

class BusinessPhoto extends Equatable {
  const BusinessPhoto({
    required this.id,
    required this.url,
    required this.mimeType,
    required this.position,
  });

  final String id;
  final String url;
  final String mimeType;
  final int position;

  @override
  List<Object?> get props => [id, url, mimeType, position];
}

class ManagedBusiness extends Equatable {
  const ManagedBusiness({
    required this.id,
    required this.municipalityId,
    required this.name,
    required this.category,
    required this.descriptionEs,
    required this.descriptionVa,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.schedule,
    required this.active,
    required this.photos,
  });

  final String id;
  final String municipalityId;
  final String name;
  final String category;
  final String? descriptionEs;
  final String? descriptionVa;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? schedule;
  final bool active;
  final List<BusinessPhoto> photos;

  ManagedBusiness copyWith({List<BusinessPhoto>? photos, bool? active}) =>
      ManagedBusiness(
        id: id,
        municipalityId: municipalityId,
        name: name,
        category: category,
        descriptionEs: descriptionEs,
        descriptionVa: descriptionVa,
        address: address,
        phone: phone,
        email: email,
        website: website,
        schedule: schedule,
        active: active ?? this.active,
        photos: photos ?? this.photos,
      );

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    name,
    category,
    descriptionEs,
    descriptionVa,
    address,
    phone,
    email,
    website,
    schedule,
    active,
    photos,
  ];
}

class ManagedBusinessPage extends Equatable {
  const ManagedBusinessPage({required this.items, required this.nextCursor});
  final List<ManagedBusiness> items;
  final String? nextCursor;
  @override
  List<Object?> get props => [items, nextCursor];
}

class SaveBusinessInput extends Equatable {
  const SaveBusinessInput({
    required this.municipalityId,
    required this.name,
    required this.category,
    this.id,
    this.descriptionEs,
    this.descriptionVa,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.schedule,
  });

  final String? id;
  final String municipalityId;
  final String name;
  final String category;
  final String? descriptionEs;
  final String? descriptionVa;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? schedule;

  bool get isEditing => id != null;

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    name,
    category,
    descriptionEs,
    descriptionVa,
    address,
    phone,
    email,
    website,
    schedule,
  ];
}

class BusinessPhotoUploadFile {
  const BusinessPhotoUploadFile({required this.name, required this.bytes});
  final String name;
  final List<int> bytes;
}

class BusinessPhotoUploadTarget extends Equatable {
  const BusinessPhotoUploadTarget({
    required this.uploadUrl,
    required this.publicUrl,
    required this.expiresInSeconds,
  });
  final String uploadUrl;
  final String publicUrl;
  final int expiresInSeconds;
  @override
  List<Object?> get props => [uploadUrl, publicUrl, expiresInSeconds];
}
