import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/device/data/datasources/device_remote_datasource.dart';
import '../../features/device/data/repositories/device_registration_repository_impl.dart';
import '../../features/device/domain/repositories/device_registration_repository.dart';
import '../../features/device/domain/usecases/device_registration_usecases.dart';
import '../../features/device/domain/usecases/sync_device_push.dart';
import '../../features/alerts/data/datasources/alert_remote_datasource.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/domain/usecases/alert_usecases.dart';
import '../../features/businesses/data/datasources/business_remote_datasource.dart';
import '../../features/businesses/data/repositories/business_repository_impl.dart';
import '../../features/businesses/domain/repositories/business_repository.dart';
import '../../features/businesses/domain/usecases/business_usecases.dart';
import '../../features/events/data/datasources/event_remote_datasource.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/event_usecases.dart';
import '../../features/facilities/data/datasources/facility_remote_datasource.dart';
import '../../features/facilities/data/repositories/facility_repository_impl.dart';
import '../../features/facilities/domain/repositories/facility_repository.dart';
import '../../features/facilities/domain/usecases/facility_usecases.dart';
import '../../features/forms/data/datasources/form_remote_datasource.dart';
import '../../features/forms/data/repositories/form_repository_impl.dart';
import '../../features/forms/domain/repositories/form_repository.dart';
import '../../features/forms/domain/usecases/form_usecases.dart';
import '../../features/incidents/data/datasources/incident_remote_datasource.dart';
import '../../features/incidents/data/repositories/incident_repository_impl.dart';
import '../../features/incidents/domain/repositories/incident_repository.dart';
import '../../features/incidents/domain/usecases/incident_usecases.dart';
import '../../features/municipalities/data/datasources/municipality_remote_datasource.dart';
import '../../features/surveys/data/datasources/survey_remote_datasource.dart';
import '../../features/surveys/data/repositories/survey_repository_impl.dart';
import '../../features/surveys/domain/repositories/survey_repository.dart';
import '../../features/surveys/domain/usecases/survey_usecases.dart';
import '../../features/municipalities/data/repositories/municipality_repository_impl.dart';
import '../../features/municipalities/domain/repositories/municipality_repository.dart';
import '../../features/municipalities/domain/usecases/list_municipalities.dart';
import '../../features/pharmacies/data/datasources/duty_pharmacy_remote_datasource.dart';
import '../../features/pharmacies/data/repositories/duty_pharmacy_repository_impl.dart';
import '../../features/pharmacies/domain/repositories/duty_pharmacy_repository.dart';
import '../../features/pharmacies/domain/usecases/duty_pharmacy_usecases.dart';
import '../../features/news/data/datasources/news_remote_datasource.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../../features/news/domain/usecases/news_usecases.dart';
import '../device/device_id_store.dart';
import '../device/secure_device_id_store.dart';
import '../l10n/locale_controller.dart';
import '../network/dio_client.dart';
import '../notifications/firebase_push_notification_service.dart';
import '../notifications/push_notification_service.dart';
import '../session/prefs_session_store.dart';
import '../session/session_store.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({required bool firebaseAvailable}) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final DeviceIdStore deviceIdStore = SecureDeviceIdStore();
  final LocaleController localeController = LocaleController();
  final Dio dio = buildDioClient(
    deviceIdStore: deviceIdStore,
    currentLocale: () => localeController.current,
  );

  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<DeviceIdStore>(deviceIdStore)
    ..registerSingleton<SessionStore>(PrefsSessionStore(preferences))
    ..registerSingleton<LocaleController>(localeController)
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<PushNotificationService>(
      firebaseAvailable
          ? FirebasePushNotificationService(
              FirebaseMessaging.instance,
              preferences,
            )
          : const DisabledPushNotificationService(),
    );

  _registerDevice();
  _registerMunicipalities();
  _registerNews();
  _registerEvents();
  _registerAlerts();
  _registerIncidents();
  _registerSurveys();
  _registerForms();
  _registerPharmacies();
  _registerBusinesses();
  _registerFacilities();
}

void _registerDevice() {
  getIt
    ..registerLazySingleton<DeviceRemoteDataSource>(
      () => DeviceRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<DeviceRegistrationRepository>(
      () => DeviceRegistrationRepositoryImpl(getIt<DeviceRemoteDataSource>()),
    )
    ..registerLazySingleton<RegisterDevice>(
      () => RegisterDevice(
        getIt<DeviceRegistrationRepository>(),
        getIt<DeviceIdStore>(),
      ),
    )
    ..registerLazySingleton<UpdateDevicePush>(
      () => UpdateDevicePush(getIt<DeviceRegistrationRepository>()),
    )
    ..registerLazySingleton<SyncDevicePush>(
      () => SyncDevicePush(
        getIt<PushNotificationService>(),
        getIt<UpdateDevicePush>(),
      ),
    );
}

void _registerMunicipalities() {
  getIt
    ..registerLazySingleton<MunicipalityRemoteDataSource>(
      () => MunicipalityRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<MunicipalityRepository>(
      () => MunicipalityRepositoryImpl(getIt<MunicipalityRemoteDataSource>()),
    )
    ..registerLazySingleton<ListMunicipalities>(
      () => ListMunicipalities(getIt<MunicipalityRepository>()),
    );
}

void _registerNews() {
  getIt
    ..registerLazySingleton<NewsRemoteDataSource>(
      () => NewsRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<NewsRepository>(
      () => NewsRepositoryImpl(getIt<NewsRemoteDataSource>()),
    )
    ..registerLazySingleton<GetNews>(() => GetNews(getIt<NewsRepository>()))
    ..registerLazySingleton<GetNewsCategories>(
      () => GetNewsCategories(getIt<NewsRepository>()),
    )
    ..registerLazySingleton<GetNewsDetail>(
      () => GetNewsDetail(getIt<NewsRepository>()),
    );
}

void _registerEvents() {
  getIt
    ..registerLazySingleton<EventRemoteDataSource>(
      () => EventRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(getIt<EventRemoteDataSource>()),
    )
    ..registerLazySingleton<GetEvents>(
      () => GetEvents(getIt<EventRepository>()),
    )
    ..registerLazySingleton<GetEventDetail>(
      () => GetEventDetail(getIt<EventRepository>()),
    )
    ..registerLazySingleton<SetEventReminder>(
      () => SetEventReminder(getIt<EventRepository>()),
    )
    ..registerLazySingleton<CancelEventReminder>(
      () => CancelEventReminder(getIt<EventRepository>()),
    );
}

void _registerAlerts() {
  getIt
    ..registerLazySingleton<AlertRemoteDataSource>(
      () => AlertRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<AlertRepository>(
      () => AlertRepositoryImpl(getIt<AlertRemoteDataSource>()),
    )
    ..registerLazySingleton<GetAlerts>(
      () => GetAlerts(getIt<AlertRepository>()),
    )
    ..registerLazySingleton<GetAlertDetail>(
      () => GetAlertDetail(getIt<AlertRepository>()),
    );
}

void _registerIncidents() {
  getIt
    ..registerLazySingleton<IncidentRemoteDataSource>(
      () => IncidentRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<IncidentRepository>(
      () => IncidentRepositoryImpl(getIt<IncidentRemoteDataSource>()),
    )
    ..registerLazySingleton<ReportIncident>(
      () => ReportIncident(getIt<IncidentRepository>()),
    )
    ..registerLazySingleton<UploadIncidentPhoto>(
      () => UploadIncidentPhoto(getIt<IncidentRepository>()),
    )
    ..registerLazySingleton<GetMyIncidents>(
      () => GetMyIncidents(getIt<IncidentRepository>()),
    )
    ..registerLazySingleton<GetMyIncidentDetail>(
      () => GetMyIncidentDetail(getIt<IncidentRepository>()),
    );
}

void _registerSurveys() {
  getIt
    ..registerLazySingleton<SurveyRemoteDataSource>(
      () => SurveyRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<SurveyRepository>(
      () => SurveyRepositoryImpl(getIt<SurveyRemoteDataSource>()),
    )
    ..registerLazySingleton<GetSurveys>(
      () => GetSurveys(getIt<SurveyRepository>()),
    )
    ..registerLazySingleton<GetSurveyDetail>(
      () => GetSurveyDetail(getIt<SurveyRepository>()),
    )
    ..registerLazySingleton<VoteSurvey>(
      () => VoteSurvey(getIt<SurveyRepository>()),
    );
}

void _registerForms() {
  getIt
    ..registerLazySingleton<FormRemoteDataSource>(
      () => FormRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<FormRepository>(
      () => FormRepositoryImpl(getIt<FormRemoteDataSource>()),
    )
    ..registerLazySingleton<GetForms>(() => GetForms(getIt<FormRepository>()))
    ..registerLazySingleton<GetFormDetail>(
      () => GetFormDetail(getIt<FormRepository>()),
    )
    ..registerLazySingleton<SubmitForm>(
      () => SubmitForm(getIt<FormRepository>()),
    );
}

void _registerPharmacies() {
  getIt
    ..registerLazySingleton<DutyPharmacyRemoteDataSource>(
      () => DutyPharmacyRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<DutyPharmacyRepository>(
      () => DutyPharmacyRepositoryImpl(getIt<DutyPharmacyRemoteDataSource>()),
    )
    ..registerLazySingleton<GetDutyPharmacies>(
      () => GetDutyPharmacies(getIt<DutyPharmacyRepository>()),
    )
    ..registerLazySingleton<GetTodayDutyPharmacy>(
      () => GetTodayDutyPharmacy(getIt<DutyPharmacyRepository>()),
    );
}

void _registerBusinesses() {
  getIt
    ..registerLazySingleton<BusinessRemoteDataSource>(
      () => BusinessRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<BusinessRepository>(
      () => BusinessRepositoryImpl(getIt<BusinessRemoteDataSource>()),
    )
    ..registerLazySingleton<GetBusinesses>(
      () => GetBusinesses(getIt<BusinessRepository>()),
    )
    ..registerLazySingleton<GetBusinessCategories>(
      () => GetBusinessCategories(getIt<BusinessRepository>()),
    )
    ..registerLazySingleton<GetBusinessDetail>(
      () => GetBusinessDetail(getIt<BusinessRepository>()),
    );
}

void _registerFacilities() {
  getIt
    ..registerLazySingleton<FacilityRemoteDataSource>(
      () => FacilityRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<FacilityRepository>(
      () => FacilityRepositoryImpl(getIt<FacilityRemoteDataSource>()),
    )
    ..registerLazySingleton<GetFacilities>(
      () => GetFacilities(getIt<FacilityRepository>()),
    )
    ..registerLazySingleton<GetFacilityDetail>(
      () => GetFacilityDetail(getIt<FacilityRepository>()),
    )
    ..registerLazySingleton<GetFacilityAvailability>(
      () => GetFacilityAvailability(getIt<FacilityRepository>()),
    )
    ..registerLazySingleton<CreateReservation>(
      () => CreateReservation(getIt<FacilityRepository>()),
    )
    ..registerLazySingleton<GetMyReservations>(
      () => GetMyReservations(getIt<FacilityRepository>()),
    )
    ..registerLazySingleton<CancelReservation>(
      () => CancelReservation(getIt<FacilityRepository>()),
    );
}
