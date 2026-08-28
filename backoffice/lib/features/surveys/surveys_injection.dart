import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/survey_remote_datasource.dart';
import 'data/repositories/survey_repository_impl.dart';
import 'domain/repositories/survey_repository.dart';
import 'domain/usecases/survey_usecases.dart';

void configureSurveyDependencies(GetIt getIt) {
  if (getIt.isRegistered<SurveyRepository>()) return;

  getIt.registerLazySingleton(
    () => SurveyRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<SurveyRepository>(
    () => SurveyRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedSurveys(getIt()));
  getIt.registerFactory(() => GetManagedSurveyDetail(getIt()));
  getIt.registerFactory(() => CreateSurvey(getIt()));
  getIt.registerFactory(() => CloseSurvey(getIt()));
  getIt.registerFactory(() => SetSurveyResultsVisibility(getIt()));
  getIt.registerFactory(() => DeleteSurvey(getIt()));
  getIt.registerFactory(() => ExportSurveyResultsCsv(getIt()));
}
