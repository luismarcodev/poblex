import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/event_remote_datasource.dart';
import 'data/repositories/event_repository_impl.dart';
import 'domain/repositories/event_repository.dart';
import 'domain/usecases/event_usecases.dart';

void configureEventDependencies(GetIt getIt) {
  if (getIt.isRegistered<EventRepository>()) return;

  getIt.registerLazySingleton(
    () => EventRemoteDataSource(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetManagedEvents(getIt()));
  getIt.registerFactory(() => GetManagedEventDetail(getIt()));
  getIt.registerFactory(() => SaveEvent(getIt()));
  getIt.registerFactory(() => DeleteEvent(getIt()));
}
