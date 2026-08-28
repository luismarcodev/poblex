import '../../../../core/result/result.dart';
import '../entities/incident.dart';

abstract interface class IncidentRepository {
  Future<Result<Incident>> report({
    required String municipalityId,
    required String category,
    required String description,
    double? lat,
    double? lng,
  });

  Future<Result<Incident>> uploadPhoto({
    required String incidentId,
    required List<int> bytes,
    required String filename,
  });

  Future<Result<IncidentPage>> listMine({String? cursor});

  Future<Result<IncidentDetail>> detail(String id);
}
