import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_form.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/form_remote_datasource.dart';

class FormRepositoryImpl implements FormRepository {
  const FormRepositoryImpl(this._remote);

  final FormRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedFormsPage>> getForms({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _capture(
    () => _remote.getForms(
      municipalityId: municipalityId,
      includeClosed: includeClosed,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<ManagedForm>> getDetail({
    required String id,
    required String municipalityId,
  }) =>
      _capture(() => _remote.getDetail(id: id, municipalityId: municipalityId));

  @override
  Future<Result<ManagedForm>> create(CreateFormInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));

  @override
  Future<Result<String>> exportSubmissionsCsv(String id) =>
      _capture(() => _remote.exportSubmissionsCsv(id));
}
