import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/social_remote_datasource.dart';
import 'data/repositories/social_repository_impl.dart';
import 'domain/repositories/social_repository.dart';
import 'domain/usecases/social_usecases.dart';

void configureSocialDependencies(GetIt getIt) {
  if (getIt.isRegistered<SocialRepository>()) return;

  getIt.registerLazySingleton(
    () => SocialRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => ListSocialAccounts(getIt()));
  getIt.registerFactory(() => StartSocialOAuth(getIt()));
  getIt.registerFactory(() => DisconnectSocialAccount(getIt()));
}
