import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/form.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/form_remote_datasource.dart';
import '../mappers/form_mapper.dart';
import '../models/form_model.dart';

class FormRepositoryImpl implements FormRepository {
  const FormRepositoryImpl(this._remote);
  final FormRemoteDataSource _remote;

  @override
  Future<Result<FormPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    try {
      final FormPageModel page = await _remote.list(
        municipalityId: municipalityId,
        includeClosed: includeClosed,
        cursor: cursor,
      );
      return Success<FormPage>(
        FormPage(
          items: page.items.map(FormMapper.toDomain).toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<FormPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<MunicipalForm>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<MunicipalForm>(
        FormMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<MunicipalForm>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> submit({
    required String formId,
    required Map<String, String> answers,
  }) async {
    try {
      await _remote.submit(formId: formId, answers: answers);
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }
}
