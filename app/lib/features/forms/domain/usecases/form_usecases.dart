import '../../../../core/result/result.dart';
import '../entities/form.dart';
import '../repositories/form_repository.dart';

class GetForms {
  const GetForms(this._repository);
  final FormRepository _repository;

  Future<Result<FormPage>> call({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _repository.list(
    municipalityId: municipalityId,
    includeClosed: includeClosed,
    cursor: cursor,
  );
}

class GetFormDetail {
  const GetFormDetail(this._repository);
  final FormRepository _repository;

  Future<Result<MunicipalForm>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}

class SubmitForm {
  const SubmitForm(this._repository);
  final FormRepository _repository;

  Future<Result<void>> call({
    required String formId,
    required Map<String, String> answers,
  }) => _repository.submit(formId: formId, answers: answers);
}
