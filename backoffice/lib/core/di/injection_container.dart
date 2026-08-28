import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/alerts/alerts_injection.dart';
import '../../features/businesses/businesses_injection.dart';
import '../../features/events/events_injection.dart';
import '../../features/facilities/facilities_injection.dart';
import '../../features/forms/forms_injection.dart';
import '../../features/incidents/incidents_injection.dart';
import '../../features/news/data/datasources/news_remote_datasource.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../../features/news/domain/usecases/news_usecases.dart';
import '../../features/pharmacies/pharmacies_injection.dart';
import '../../features/social/social_injection.dart';
import '../../features/surveys/surveys_injection.dart';
import '../network/api_client.dart';
import '../session/auth_session.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<AuthSession>()) return;

  getIt.registerLazySingleton(AuthSession.new);
  getIt.registerLazySingleton(() => ApiClient(getIt()));

  getIt.registerLazySingleton(
    () => AuthRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory(() => RestoreManagerSession(getIt()));
  getIt.registerFactory(() => LoginManager(getIt()));
  getIt.registerFactory(() => LogoutManager(getIt()));
  getIt.registerFactory(() => ForgotManagerPassword(getIt()));
  getIt.registerFactory(() => ResetManagerPassword(getIt()));

  getIt.registerLazySingleton(
    () => NewsRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedNews(getIt()));
  getIt.registerFactory(() => GetManagedNewsDetail(getIt()));
  getIt.registerFactory(() => SaveNews(getIt()));
  getIt.registerFactory(() => UploadNewsAttachment(getIt()));
  getIt.registerFactory(() => SetNewsPinned(getIt()));
  getIt.registerFactory(() => SetNewsArchived(getIt()));
  getIt.registerFactory(() => DeleteNews(getIt()));

  configureEventDependencies(getIt);
  configureAlertDependencies(getIt);
  configureSurveyDependencies(getIt);
  configureIncidentDependencies(getIt);
  configurePharmacyDependencies(getIt);
  configureFormDependencies(getIt);
  configureBusinessDependencies(getIt);
  configureSocialDependencies(getIt);
  configureFacilityDependencies(getIt);
}
