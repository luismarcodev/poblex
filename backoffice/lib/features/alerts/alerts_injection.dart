import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/alert_remote_datasource.dart';
import 'data/repositories/alert_repository_impl.dart';
import 'domain/repositories/alert_repository.dart';
import 'domain/usecases/alert_usecases.dart';

void configureAlertDependencies(GetIt getIt) {
  if (getIt.isRegistered<AlertRepository>()) return;

  getIt.registerLazySingleton(
    () => AlertRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedAlerts(getIt()));
  getIt.registerFactory(() => GetManagedAlertDetail(getIt()));
  getIt.registerFactory(() => SaveManualAlert(getIt()));
  getIt.registerFactory(() => DeleteManualAlert(getIt()));
}
