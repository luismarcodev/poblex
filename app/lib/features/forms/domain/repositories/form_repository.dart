import '../../../../core/result/result.dart';
import '../entities/form.dart';

abstract interface class FormRepository {
  Future<Result<FormPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  });

  Future<Result<MunicipalForm>> detail({
    required String id,
    required String municipalityId,
  });

  /// [answers] maps field id to its value serialized as text — the backend
  /// stores every answer as a string regardless of the field's type.
  Future<Result<void>> submit({
    required String formId,
    required Map<String, String> answers,
  });
}
