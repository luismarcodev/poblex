import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/incident_remote_datasource.dart';
import 'data/repositories/incident_repository_impl.dart';
import 'domain/repositories/incident_repository.dart';
import 'domain/usecases/incident_usecases.dart';

void configureIncidentDependencies(GetIt getIt) {
  if (getIt.isRegistered<IncidentRepository>()) return;

  getIt.registerLazySingleton(
    () => IncidentRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<IncidentRepository>(
    () => IncidentRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedIncidents(getIt()));
  getIt.registerFactory(() => ChangeManagedIncidentStatus(getIt()));
  getIt.registerFactory(() => GetIncidentHistory(getIt()));
  getIt.registerFactory(() => ListIncidentCategories(getIt()));
}
