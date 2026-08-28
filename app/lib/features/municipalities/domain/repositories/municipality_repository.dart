import '../../../../core/result/result.dart';
import '../entities/municipality.dart';

abstract interface class MunicipalityRepository {
  Future<Result<List<Municipality>>> listActive();
}
