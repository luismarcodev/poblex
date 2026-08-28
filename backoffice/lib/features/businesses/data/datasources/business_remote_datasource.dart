import 'package:dio/dio.dart';

import '../../domain/entities/managed_business.dart';
import '../models/managed_business_model.dart';

class BusinessRemoteDataSource {
  BusinessRemoteDataSource(this._dio, {Dio? uploadDio})
    : _uploadDio = uploadDio ?? Dio();
  final Dio _dio;
  final Dio _uploadDio;

  Future<ManagedBusiness> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/businesses/$id',
    );
    return _entity(response.data);
  }

  Future<ManagedBusinessPage> getManagedBusinesses({
    required String municipalityId,
    required bool includeInactive,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/businesses',
      queryParameters: {
        'municipalityId': municipalityId,
        'includeInactive': includeInactive,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing business page');
    final rawItems = data['items'] as List<dynamic>;
    return ManagedBusinessPage(
      items: rawItems
          .map(
            (raw) => ManagedBusinessModel.fromJson(
              raw as Map<String, dynamic>,
            ).entity,
          )
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<List<String>> categories(String municipalityId) async {
    // Endpoint público: el dato no es sensible y evita duplicar el caso de
    // uso de categorías en el lado admin solo para el autocompletado.
    final response = await _dio.get<Map<String, dynamic>>(
      '/businesses/categories',
      queryParameters: {'municipalityId': municipalityId},
    );
    final raw = response.data?['categories'] as List<dynamic>? ?? const [];
    return raw.cast<String>();
  }

  Future<ManagedBusiness> create(SaveBusinessInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/businesses',
      data: {
        'municipalityId': input.municipalityId,
        'name': input.name,
        'category': input.category,
        'description': ?_descriptionJson(
          input.descriptionEs,
          input.descriptionVa,
        ),
        'address': ?_blankToNull(input.address),
        'phone': ?_blankToNull(input.phone),
        'email': ?_blankToNull(input.email),
        'website': ?_blankToNull(input.website),
        'schedule': ?_blankToNull(input.schedule),
      },
    );
    return _entity(response.data);
  }

  Future<ManagedBusiness> update(SaveBusinessInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/businesses/${input.id}',
      data: {
        'name': input.name,
        'category': input.category,
        'description': _descriptionJson(
          input.descriptionEs,
          input.descriptionVa,
        ),
        'address': _blankToNull(input.address),
        'phone': _blankToNull(input.phone),
        'email': _blankToNull(input.email),
        'website': _blankToNull(input.website),
        'schedule': _blankToNull(input.schedule),
      },
    );
    return _entity(response.data);
  }

  Future<ManagedBusiness> setActive(String id, bool active) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/businesses/$id/active',
      data: {'active': active},
    );
    return _entity(response.data);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/businesses/$id');

  Future<BusinessPhotoUploadTarget> requestPhotoUpload({
    required String businessId,
    required String fileName,
    required String mimeType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/businesses/$businessId/photos/upload-url',
      data: {'fileName': fileName, 'contentType': mimeType},
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing upload target');
    return BusinessPhotoUploadTarget(
      uploadUrl: data['uploadUrl'] as String,
      publicUrl: data['publicUrl'] as String,
      expiresInSeconds: data['expiresInSeconds'] as int,
    );
  }

  Future<void> uploadPhotoBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String mimeType,
  }) => _uploadDio.put<void>(
    uploadUrl,
    data: bytes,
    options: Options(headers: {'Content-Type': mimeType}),
  );

  Future<ManagedBusiness> confirmPhoto({
    required String businessId,
    required String url,
    required String mimeType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/businesses/$businessId/photos',
      data: {'url': url, 'mimeType': mimeType},
    );
    return _entity(response.data);
  }

  Future<void> deletePhoto({
    required String businessId,
    required String photoId,
  }) => _dio.delete<void>('/admin/businesses/$businessId/photos/$photoId');

  Future<ManagedBusiness> reorderPhotos({
    required String businessId,
    required List<String> orderedPhotoIds,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/businesses/$businessId/photos/order',
      data: {'orderedPhotoIds': orderedPhotoIds},
    );
    return _entity(response.data);
  }

  ManagedBusiness _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing business');
    return ManagedBusinessModel.fromJson(data).entity;
  }

  Map<String, dynamic>? _descriptionJson(String? es, String? va) {
    final trimmedEs = es?.trim();
    final trimmedVa = va?.trim();
    if ((trimmedEs == null || trimmedEs.isEmpty) &&
        (trimmedVa == null || trimmedVa.isEmpty)) {
      return null;
    }
    return {
      if (trimmedEs != null && trimmedEs.isNotEmpty) 'es': trimmedEs,
      if (trimmedVa != null && trimmedVa.isNotEmpty) 'va': trimmedVa,
    };
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
