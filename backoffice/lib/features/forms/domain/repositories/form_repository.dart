import '../../../../core/result/result.dart';
import '../entities/managed_form.dart';

abstract interface class FormRepository {
  Future<Result<ManagedFormsPage>> getForms({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  });
  Future<Result<ManagedForm>> getDetail({
    required String id,
    required String municipalityId,
  });
  Future<Result<ManagedForm>> create(CreateFormInput input);
  Future<Result<void>> delete(String id);
  Future<Result<String>> exportSubmissionsCsv(String id);
}
