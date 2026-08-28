import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/business_remote_datasource.dart';
import 'data/repositories/business_repository_impl.dart';
import 'domain/repositories/business_repository.dart';
import 'domain/usecases/business_usecases.dart';

void configureBusinessDependencies(GetIt getIt) {
  if (getIt.isRegistered<BusinessRepository>()) return;

  getIt.registerLazySingleton(
    () => BusinessRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedBusinesses(getIt()));
  getIt.registerFactory(() => GetManagedBusinessDetail(getIt()));
  getIt.registerFactory(() => GetBusinessCategories(getIt()));
  getIt.registerFactory(() => SaveBusiness(getIt()));
  getIt.registerFactory(() => UploadBusinessPhoto(getIt()));
  getIt.registerFactory(() => DeleteBusinessPhoto(getIt()));
  getIt.registerFactory(() => ReorderBusinessPhotos(getIt()));
  getIt.registerFactory(() => SetBusinessActive(getIt()));
  getIt.registerFactory(() => DeleteBusiness(getIt()));
}
