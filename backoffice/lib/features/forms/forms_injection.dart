import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/form_remote_datasource.dart';
import 'data/repositories/form_repository_impl.dart';
import 'domain/repositories/form_repository.dart';
import 'domain/usecases/form_usecases.dart';

void configureFormDependencies(GetIt getIt) {
  if (getIt.isRegistered<FormRepository>()) return;
  getIt.registerLazySingleton(
    () => FormRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<FormRepository>(
    () => FormRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedForms(getIt()));
  getIt.registerFactory(() => GetManagedFormDetail(getIt()));
  getIt.registerFactory(() => CreateManagedForm(getIt()));
  getIt.registerFactory(() => DeleteManagedForm(getIt()));
  getIt.registerFactory(() => ExportFormSubmissionsCsv(getIt()));
}
