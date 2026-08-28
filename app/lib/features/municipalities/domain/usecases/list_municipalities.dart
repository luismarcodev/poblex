import '../../../../core/result/result.dart';
import '../entities/municipality.dart';
import '../repositories/municipality_repository.dart';

class ListMunicipalities {
  const ListMunicipalities(this._repository);

  final MunicipalityRepository _repository;

  Future<Result<List<Municipality>>> call() => _repository.listActive();
}
