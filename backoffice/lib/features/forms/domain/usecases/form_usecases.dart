import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/managed_form.dart';
import '../repositories/form_repository.dart';

class GetManagedForms {
  const GetManagedForms(this._repository);
  final FormRepository _repository;

  Future<Result<ManagedFormsPage>> call({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _repository.getForms(
    municipalityId: municipalityId,
    includeClosed: includeClosed,
    cursor: cursor,
  );
}

class GetManagedFormDetail {
  const GetManagedFormDetail(this._repository);
  final FormRepository _repository;
  Future<Result<ManagedForm>> call({
    required String id,
    required String municipalityId,
  }) => _repository.getDetail(id: id, municipalityId: municipalityId);
}

class CreateManagedForm {
  const CreateManagedForm(this._repository);
  final FormRepository _repository;

  Future<Result<ManagedForm>> call(CreateFormInput input, {DateTime? now}) {
    final keys = input.fields.map((field) => field.key.trim()).toList();
    final invalid =
        input.municipalityId.trim().isEmpty ||
        input.title.es.trim().isEmpty ||
        input.description.es.trim().isEmpty ||
        input.fields.isEmpty ||
        input.fields.any(
          (field) =>
              !RegExp(r'^[a-z0-9_]+$').hasMatch(field.key.trim()) ||
              field.label.es.trim().isEmpty ||
              (field.type == ManagedFormFieldType.select &&
                  field.options
                          .map((option) => option.trim())
                          .where((option) => option.isNotEmpty)
                          .toSet()
                          .length <
                      2),
        );
    if (invalid) {
      return Future.value(
        const Failure(ValidationFailure(message: 'form_invalid_fields')),
      );
    }
    if (keys.toSet().length != keys.length) {
      return Future.value(
        const Failure(ValidationFailure(message: 'form_duplicate_keys')),
      );
    }
    if (input.deadline != null &&
        !input.deadline!.isAfter(now ?? DateTime.now())) {
      return Future.value(
        const Failure(ValidationFailure(message: 'form_future_deadline')),
      );
    }
    return _repository.create(input);
  }
}

class DeleteManagedForm {
  const DeleteManagedForm(this._repository);
  final FormRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}

class ExportFormSubmissionsCsv {
  const ExportFormSubmissionsCsv(this._repository);
  final FormRepository _repository;
  Future<Result<String>> call(String id) =>
      _repository.exportSubmissionsCsv(id);
}
