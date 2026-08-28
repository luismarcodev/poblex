import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_business.dart';
import '../../domain/usecases/business_usecases.dart';

class BusinessEditorUiState extends Equatable {
  const BusinessEditorUiState({
    this.business,
    this.uploadingPhoto = false,
    this.failedPhoto,
    this.photoFailure,
  });

  final ManagedBusiness? business;
  final bool uploadingPhoto;
  final BusinessPhotoUploadFile? failedPhoto;
  final AppFailure? photoFailure;

  BusinessEditorUiState copyWith({
    ManagedBusiness? business,
    bool? uploadingPhoto,
    BusinessPhotoUploadFile? failedPhoto,
    AppFailure? photoFailure,
    bool clearPhotoFailure = false,
  }) => BusinessEditorUiState(
    business: business ?? this.business,
    uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
    failedPhoto: clearPhotoFailure ? null : failedPhoto ?? this.failedPhoto,
    photoFailure: clearPhotoFailure ? null : photoFailure ?? this.photoFailure,
  );

  @override
  List<Object?> get props => [
    business,
    uploadingPhoto,
    failedPhoto,
    photoFailure,
  ];
}

final businessEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      BusinessEditorViewModel,
      BusinessEditorUiState
    >(BusinessEditorViewModel.new);

class BusinessEditorViewModel
    extends AutoDisposeAsyncNotifier<BusinessEditorUiState> {
  @override
  BusinessEditorUiState build() => const BusinessEditorUiState();

  Future<void> load(String id, {ManagedBusiness? initial}) async {
    if (initial != null) {
      state = AsyncData(BusinessEditorUiState(business: initial));
      return;
    }
    state = const AsyncLoading();
    final result = await getIt<GetManagedBusinessDetail>()(id);
    state = switch (result) {
      Success(value: final business) => AsyncData(
        BusinessEditorUiState(business: business),
      ),
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<AppFailure?> save(SaveBusinessInput input) async {
    final previous = state.valueOrNull ?? const BusinessEditorUiState();
    state = const AsyncLoading();
    final result = await getIt<SaveBusiness>()(input);
    return switch (result) {
      Success(value: final business) => _complete(previous, business),
      Failure(error: final error) => _fail(previous, error),
    };
  }

  Future<AppFailure?> setActive(bool active) async {
    final previous = state.valueOrNull;
    final business = previous?.business;
    if (previous == null || business == null) {
      return const UnknownFailure();
    }
    final result = await getIt<SetBusinessActive>()(business.id, active);
    return switch (result) {
      Success(value: final updated) => _complete(previous, updated),
      Failure(error: final error) => error,
    };
  }

  Future<AppFailure?> uploadPhoto(BusinessPhotoUploadFile file) async {
    final previous = state.valueOrNull;
    final business = previous?.business;
    if (previous == null || business == null || previous.uploadingPhoto) {
      return const ValidationFailure(
        message: UploadBusinessPhoto.invalidFileCode,
      );
    }

    state = AsyncData(
      previous.copyWith(uploadingPhoto: true, clearPhotoFailure: true),
    );
    final result = await getIt<UploadBusinessPhoto>()(business.id, file);
    return switch (result) {
      Success(value: final updated) => _completePhoto(previous, updated),
      Failure(error: final error) => _failPhoto(previous, file, error),
    };
  }

  Future<AppFailure?> retryPhoto() async {
    final file = state.valueOrNull?.failedPhoto;
    if (file == null) {
      return const ValidationFailure(
        message: UploadBusinessPhoto.invalidFileCode,
      );
    }
    return uploadPhoto(file);
  }

  Future<AppFailure?> deletePhoto(String photoId) async {
    final previous = state.valueOrNull;
    final business = previous?.business;
    if (previous == null || business == null) return const UnknownFailure();
    final result = await getIt<DeleteBusinessPhoto>()(
      businessId: business.id,
      photoId: photoId,
    );
    if (result case Failure(error: final error)) return error;
    state = AsyncData(
      previous.copyWith(
        business: business.copyWith(
          photos: business.photos
              .where((photo) => photo.id != photoId)
              .toList(growable: false),
        ),
      ),
    );
    return null;
  }

  Future<AppFailure?> reorderPhotos(List<String> orderedPhotoIds) async {
    final previous = state.valueOrNull;
    final business = previous?.business;
    if (previous == null || business == null) return const UnknownFailure();
    final result = await getIt<ReorderBusinessPhotos>()(
      businessId: business.id,
      orderedPhotoIds: orderedPhotoIds,
    );
    return switch (result) {
      Success(value: final updated) => _complete(previous, updated),
      Failure(error: final error) => error,
    };
  }

  AppFailure? _complete(
    BusinessEditorUiState previous,
    ManagedBusiness business,
  ) {
    state = AsyncData(BusinessEditorUiState(business: business));
    return null;
  }

  AppFailure _fail(BusinessEditorUiState previous, AppFailure error) {
    state = AsyncData(previous);
    return error;
  }

  AppFailure? _completePhoto(
    BusinessEditorUiState previous,
    ManagedBusiness updated,
  ) {
    state = AsyncData(
      BusinessEditorUiState(business: updated, uploadingPhoto: false),
    );
    return null;
  }

  AppFailure _failPhoto(
    BusinessEditorUiState previous,
    BusinessPhotoUploadFile file,
    AppFailure error,
  ) {
    state = AsyncData(
      previous.copyWith(
        uploadingPhoto: false,
        failedPhoto: file,
        photoFailure: error,
      ),
    );
    return error;
  }
}
