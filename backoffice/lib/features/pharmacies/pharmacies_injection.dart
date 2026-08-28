import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/duty_pharmacy_remote_datasource.dart';
import 'data/repositories/duty_pharmacy_repository_impl.dart';
import 'domain/repositories/duty_pharmacy_repository.dart';
import 'domain/usecases/duty_pharmacy_usecases.dart';

void configurePharmacyDependencies(GetIt getIt) {
  if (getIt.isRegistered<DutyPharmacyRepository>()) return;

  getIt.registerLazySingleton(
    () => DutyPharmacyRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<DutyPharmacyRepository>(
    () => DutyPharmacyRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetDutyPharmacies(getIt()));
  getIt.registerFactory(() => SaveDutyPharmacy(getIt()));
}
