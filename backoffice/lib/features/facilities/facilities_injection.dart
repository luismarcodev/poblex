import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/facility_remote_datasource.dart';
import 'data/repositories/facility_repository_impl.dart';
import 'domain/repositories/facility_repository.dart';
import 'domain/usecases/facility_usecases.dart';

void configureFacilityDependencies(GetIt getIt) {
  if (getIt.isRegistered<FacilityRepository>()) return;

  getIt.registerLazySingleton(
    () => FacilityRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<FacilityRepository>(
    () => FacilityRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedFacilities(getIt()));
  getIt.registerFactory(() => SaveFacility(getIt()));
  getIt.registerFactory(() => GetManagedReservations(getIt()));
  getIt.registerFactory(() => CancelManagedReservation(getIt()));
}
