import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('es'),
  ];

  /// Nombre de la aplicación.
  ///
  /// In es, this message translates to:
  /// **'Poblex'**
  String get appName;

  /// Barra inferior: panel de inicio. Una sola palabra (§8.10).
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navNews.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get navNews;

  /// No description provided for @navEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get navEvents;

  /// No description provided for @navAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get navAlerts;

  /// No description provided for @navMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get navMore;

  /// No description provided for @sectionNews.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get sectionNews;

  /// No description provided for @sectionEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get sectionEvents;

  /// No description provided for @sectionAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get sectionAlerts;

  /// No description provided for @sectionIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get sectionIncidents;

  /// No description provided for @sectionSurveys.
  ///
  /// In es, this message translates to:
  /// **'Encuestas'**
  String get sectionSurveys;

  /// No description provided for @sectionForms.
  ///
  /// In es, this message translates to:
  /// **'Formularios'**
  String get sectionForms;

  /// No description provided for @sectionPharmacies.
  ///
  /// In es, this message translates to:
  /// **'Farmacias de guardia'**
  String get sectionPharmacies;

  /// No description provided for @sectionBusinesses.
  ///
  /// In es, this message translates to:
  /// **'Comercios'**
  String get sectionBusinesses;

  /// No description provided for @sectionFacilities.
  ///
  /// In es, this message translates to:
  /// **'Instalaciones'**
  String get sectionFacilities;

  /// No description provided for @sectionSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get sectionSettings;

  /// No description provided for @sectionNewsDescription.
  ///
  /// In es, this message translates to:
  /// **'Bandos y avisos del ayuntamiento'**
  String get sectionNewsDescription;

  /// No description provided for @sectionEventsDescription.
  ///
  /// In es, this message translates to:
  /// **'Agenda de actos del municipio'**
  String get sectionEventsDescription;

  /// No description provided for @sectionAlertsDescription.
  ///
  /// In es, this message translates to:
  /// **'Avisos meteorológicos y de emergencia'**
  String get sectionAlertsDescription;

  /// No description provided for @sectionIncidentsDescription.
  ///
  /// In es, this message translates to:
  /// **'Comunica un problema en la vía pública'**
  String get sectionIncidentsDescription;

  /// No description provided for @sectionSurveysDescription.
  ///
  /// In es, this message translates to:
  /// **'Consultas del ayuntamiento a los vecinos'**
  String get sectionSurveysDescription;

  /// No description provided for @sectionFormsDescription.
  ///
  /// In es, this message translates to:
  /// **'Inscripciones y solicitudes'**
  String get sectionFormsDescription;

  /// No description provided for @sectionPharmaciesDescription.
  ///
  /// In es, this message translates to:
  /// **'Qué farmacia está de guardia'**
  String get sectionPharmaciesDescription;

  /// No description provided for @sectionBusinessesDescription.
  ///
  /// In es, this message translates to:
  /// **'Directorio de comercios locales'**
  String get sectionBusinessesDescription;

  /// No description provided for @sectionFacilitiesDescription.
  ///
  /// In es, this message translates to:
  /// **'Reserva pistas y espacios municipales'**
  String get sectionFacilitiesDescription;

  /// Encabezado del panel de inicio.
  ///
  /// In es, this message translates to:
  /// **'Tu ayuntamiento, en el móvil'**
  String get homeGreeting;

  /// No description provided for @homeSectionsHeading.
  ///
  /// In es, this message translates to:
  /// **'Secciones'**
  String get homeSectionsHeading;

  /// No description provided for @homeLatestNewsHeading.
  ///
  /// In es, this message translates to:
  /// **'Últimas noticias'**
  String get homeLatestNewsHeading;

  /// No description provided for @homeSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get homeSeeAll;

  /// No description provided for @drawerTitle.
  ///
  /// In es, this message translates to:
  /// **'Secciones'**
  String get drawerTitle;

  /// No description provided for @drawerOpenLabel.
  ///
  /// In es, this message translates to:
  /// **'Abrir el menú de secciones'**
  String get drawerOpenLabel;

  /// No description provided for @drawerAccessibilityStatement.
  ///
  /// In es, this message translates to:
  /// **'Declaración de accesibilidad'**
  String get drawerAccessibilityStatement;

  /// Pestaña de noticias vigentes.
  ///
  /// In es, this message translates to:
  /// **'Actualidad'**
  String get newsTabCurrent;

  /// Noticias archivadas automáticamente a los 90 días.
  ///
  /// In es, this message translates to:
  /// **'Histórico'**
  String get newsTabArchive;

  /// No description provided for @newsPinnedLabel.
  ///
  /// In es, this message translates to:
  /// **'Destacada'**
  String get newsPinnedLabel;

  /// No description provided for @newsReadFullArticle.
  ///
  /// In es, this message translates to:
  /// **'Leer artículo completo'**
  String get newsReadFullArticle;

  /// No description provided for @newsAttachmentsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin adjuntos} =1{1 adjunto} other{{count} adjuntos}}'**
  String newsAttachmentsCount(int count);

  /// Etiqueta agrupada de la tarjeta de noticia (A-27).
  ///
  /// In es, this message translates to:
  /// **'Noticia. {title}. Categoría {category}. Publicada el {date}. {attachments}.'**
  String newsSemanticCard(
    String title,
    String category,
    String date,
    String attachments,
  );

  /// No description provided for @newsFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get newsFilterAll;

  /// No description provided for @newsFilterSemantic.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por {category}'**
  String newsFilterSemantic(String category);

  /// No description provided for @newsDetailAttachmentsHeading.
  ///
  /// In es, this message translates to:
  /// **'Adjuntos'**
  String get newsDetailAttachmentsHeading;

  /// No description provided for @newsDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Noticia'**
  String get newsDetailTitle;

  /// No description provided for @newsImageSemantic.
  ///
  /// In es, this message translates to:
  /// **'Imagen de la noticia: {title}'**
  String newsImageSemantic(String title);

  /// No description provided for @newsOpenAttachment.
  ///
  /// In es, this message translates to:
  /// **'Abrir {name}'**
  String newsOpenAttachment(String name);

  /// No description provided for @categoryGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categorySanitaria.
  ///
  /// In es, this message translates to:
  /// **'Sanitaria'**
  String get categorySanitaria;

  /// No description provided for @categoryServicios.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get categoryServicios;

  /// No description provided for @categoryCultural.
  ///
  /// In es, this message translates to:
  /// **'Cultural'**
  String get categoryCultural;

  /// No description provided for @categoryDeportes.
  ///
  /// In es, this message translates to:
  /// **'Deportes'**
  String get categoryDeportes;

  /// No description provided for @categoryFiestas.
  ///
  /// In es, this message translates to:
  /// **'Fiestas'**
  String get categoryFiestas;

  /// No description provided for @categoryObras.
  ///
  /// In es, this message translates to:
  /// **'Obras'**
  String get categoryObras;

  /// Chip discreto cuando falta la traducción (A-55). Nunca se deja hueco vacío.
  ///
  /// In es, this message translates to:
  /// **'Solo disponible en castellano'**
  String get languageFallbackNotice;

  /// No description provided for @languageFallbackNoticeValencian.
  ///
  /// In es, this message translates to:
  /// **'Solo disponible en valenciano'**
  String get languageFallbackNoticeValencian;

  /// Anuncio del contenedor de skeletons (A-31).
  ///
  /// In es, this message translates to:
  /// **'Cargando noticias'**
  String get loadingNews;

  /// No description provided for @emptyNewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay noticias'**
  String get emptyNewsTitle;

  /// No description provided for @emptyNewsBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento las irá publicando aquí.'**
  String get emptyNewsBody;

  /// No description provided for @emptyNewsArchiveTitle.
  ///
  /// In es, this message translates to:
  /// **'El histórico está vacío'**
  String get emptyNewsArchiveTitle;

  /// No description provided for @emptyNewsArchiveBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán las noticias con más de 90 días.'**
  String get emptyNewsArchiveBody;

  /// No description provided for @emptyByFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay nada en esta categoría'**
  String get emptyByFilterTitle;

  /// No description provided for @emptyByFilterBody.
  ///
  /// In es, this message translates to:
  /// **'Prueba a quitar el filtro para ver todo el contenido.'**
  String get emptyByFilterBody;

  /// No description provided for @emptyClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get emptyClearFilters;

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkBody.
  ///
  /// In es, this message translates to:
  /// **'Comprueba que tienes datos o wifi y vuelve a intentarlo.'**
  String get errorNetworkBody;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In es, this message translates to:
  /// **'La conexión va muy lenta'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutBody.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido cargar el contenido a tiempo. Inténtalo de nuevo.'**
  String get errorTimeoutBody;

  /// No description provided for @errorServerTitle.
  ///
  /// In es, this message translates to:
  /// **'El servicio no responde'**
  String get errorServerTitle;

  /// No description provided for @errorServerBody.
  ///
  /// In es, this message translates to:
  /// **'Es un problema nuestro, no tuyo. Vuelve a intentarlo en unos minutos.'**
  String get errorServerBody;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Este contenido ya no está'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundBody.
  ///
  /// In es, this message translates to:
  /// **'Puede que el ayuntamiento lo haya retirado.'**
  String get errorNotFoundBody;

  /// No description provided for @errorTooManyRequestsTitle.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos'**
  String get errorTooManyRequestsTitle;

  /// No description provided for @errorTooManyRequestsBody.
  ///
  /// In es, this message translates to:
  /// **'Has hecho muchas peticiones seguidas. Espera unos minutos antes de volver a probar.'**
  String get errorTooManyRequestsBody;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In es, this message translates to:
  /// **'Algo ha fallado'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownBody.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido completar la operación. Inténtalo de nuevo.'**
  String get errorUnknownBody;

  /// No description provided for @errorConflictTitle.
  ///
  /// In es, this message translates to:
  /// **'Ya no está libre'**
  String get errorConflictTitle;

  /// No description provided for @errorConflictBody.
  ///
  /// In es, this message translates to:
  /// **'Alguien se te ha adelantado. Elige otra opción.'**
  String get errorConflictBody;

  /// No description provided for @errorRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get errorRetry;

  /// No description provided for @errorRetrySemantic.
  ///
  /// In es, this message translates to:
  /// **'Reintentar cargar {section}'**
  String errorRetrySemantic(String section);

  /// No description provided for @onboardingMunicipalityTitle.
  ///
  /// In es, this message translates to:
  /// **'¿De qué pueblo eres?'**
  String get onboardingMunicipalityTitle;

  /// No description provided for @onboardingMunicipalityBody.
  ///
  /// In es, this message translates to:
  /// **'Elige tu municipio para recibir sus avisos. Podrás cambiarlo cuando quieras desde Ajustes.'**
  String get onboardingMunicipalityBody;

  /// No description provided for @onboardingMunicipalityContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get onboardingMunicipalityContinue;

  /// No description provided for @onboardingSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar municipio...'**
  String get onboardingSearchHint;

  /// No description provided for @onboardingSearchClear.
  ///
  /// In es, this message translates to:
  /// **'Borrar búsqueda'**
  String get onboardingSearchClear;

  /// No description provided for @onboardingSearchNoResults.
  ///
  /// In es, this message translates to:
  /// **'No hay ningún municipio que coincida con \"{query}\"'**
  String onboardingSearchNoResults(String query);

  /// No description provided for @onboardingMunicipalitySemantic.
  ///
  /// In es, this message translates to:
  /// **'Escudo de {name}'**
  String onboardingMunicipalitySemantic(String name);

  /// No description provided for @onboardingNoMunicipalitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay municipios disponibles'**
  String get onboardingNoMunicipalitiesTitle;

  /// No description provided for @onboardingNoMunicipalitiesBody.
  ///
  /// In es, this message translates to:
  /// **'Estamos incorporando ayuntamientos. Vuelve a intentarlo más tarde.'**
  String get onboardingNoMunicipalitiesBody;

  /// No description provided for @comingSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta sección llega pronto'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In es, this message translates to:
  /// **'Estamos terminándola. Mientras tanto puedes consultar las noticias del municipio.'**
  String get comingSoonBody;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageBody.
  ///
  /// In es, this message translates to:
  /// **'El idioma elegido se aplica también a las notificaciones.'**
  String get settingsLanguageBody;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In es, this message translates to:
  /// **'Idioma actualizado'**
  String get settingsLanguageChanged;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Castellano'**
  String get languageSpanish;

  /// No description provided for @languageValencian.
  ///
  /// In es, this message translates to:
  /// **'Valenciano'**
  String get languageValencian;

  /// No description provided for @notificationNewNews.
  ///
  /// In es, this message translates to:
  /// **'Nueva noticia del ayuntamiento'**
  String get notificationNewNews;

  /// No description provided for @notificationOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get notificationOpen;

  /// No description provided for @notificationOtherMunicipality.
  ///
  /// In es, this message translates to:
  /// **'Esta noticia pertenece a otro municipio y ya no está disponible en tu selección actual.'**
  String get notificationOtherMunicipality;

  /// No description provided for @pdfViewerSemantic.
  ///
  /// In es, this message translates to:
  /// **'Documento PDF: {name}'**
  String pdfViewerSemantic(String name);

  /// No description provided for @pdfUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'No podemos abrir este documento'**
  String get pdfUnavailableTitle;

  /// No description provided for @pdfUnavailableBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a la noticia y abre el adjunto de nuevo.'**
  String get pdfUnavailableBody;

  /// No description provided for @pdfBackToNews.
  ///
  /// In es, this message translates to:
  /// **'Volver a noticias'**
  String get pdfBackToNews;

  /// No description provided for @eventDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Evento'**
  String get eventDetailTitle;

  /// No description provided for @eventPastLabel.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get eventPastLabel;

  /// No description provided for @eventReminderSet.
  ///
  /// In es, this message translates to:
  /// **'Avisarme'**
  String get eventReminderSet;

  /// No description provided for @eventReminderActive.
  ///
  /// In es, this message translates to:
  /// **'Aviso activado'**
  String get eventReminderActive;

  /// No description provided for @eventReminderCancelled.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio cancelado'**
  String get eventReminderCancelled;

  /// No description provided for @eventReminderConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Te avisaremos antes del evento'**
  String get eventReminderConfirmed;

  /// No description provided for @eventReminderSemantic.
  ///
  /// In es, this message translates to:
  /// **'{active, select, true{Recordatorio activado para {title}} other{Avisarme de {title}}}'**
  String eventReminderSemantic(String active, String title);

  /// No description provided for @eventPickReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo quieres que te avisemos?'**
  String get eventPickReminderTitle;

  /// No description provided for @eventLocationSemantic.
  ///
  /// In es, this message translates to:
  /// **'Lugar: {location}'**
  String eventLocationSemantic(String location);

  /// No description provided for @emptyEventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay eventos'**
  String get emptyEventsTitle;

  /// No description provided for @emptyEventsBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento los irá añadiendo aquí.'**
  String get emptyEventsBody;

  /// No description provided for @alertDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso'**
  String get alertDetailTitle;

  /// Etiqueta visible del chip de severidad (§8.5). Nunca solo el color.
  ///
  /// In es, this message translates to:
  /// **'{severity, select, rojo{Aviso rojo · Nivel 3} naranja{Aviso naranja · Nivel 2} other{Aviso amarillo · Nivel 1}}'**
  String alertSeverityLabel(String severity);

  /// No description provided for @alertSourceAemet.
  ///
  /// In es, this message translates to:
  /// **'Fuente: AEMET'**
  String get alertSourceAemet;

  /// No description provided for @alertSourceManual.
  ///
  /// In es, this message translates to:
  /// **'Fuente: Ayuntamiento'**
  String get alertSourceManual;

  /// No description provided for @alertActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get alertActiveLabel;

  /// No description provided for @alertExpiredLabel.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get alertExpiredLabel;

  /// No description provided for @alertForcedNotice.
  ///
  /// In es, this message translates to:
  /// **'Este aviso se muestra aunque tengas las alertas silenciadas'**
  String get alertForcedNotice;

  /// No description provided for @alertIncludeExpiredLabel.
  ///
  /// In es, this message translates to:
  /// **'Ver avisos finalizados'**
  String get alertIncludeExpiredLabel;

  /// Etiqueta del chip de tipo de fenómeno, junto al de severidad. Clasificación aparte de la severidad.
  ///
  /// In es, this message translates to:
  /// **'{type, select, incendio{Incendio} evacuacion{Evacuación} sanitario{Sanitario} meteorologico{Meteorológico} other{Otro}}'**
  String alertPhenomenonTypeLabel(String type);

  /// Cabecera del banner de Inicio cuando hay una alerta roja vigente.
  ///
  /// In es, this message translates to:
  /// **'Aviso rojo activo'**
  String get homeActiveRedAlertBannerLabel;

  /// No description provided for @emptyAlertsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay avisos activos'**
  String get emptyAlertsTitle;

  /// No description provided for @emptyAlertsBody.
  ///
  /// In es, this message translates to:
  /// **'Te avisaremos aquí si el ayuntamiento o AEMET publican algo.'**
  String get emptyAlertsBody;

  /// No description provided for @incidentReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar incidencia'**
  String get incidentReportTitle;

  /// No description provided for @incidentCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get incidentCategoryLabel;

  /// No description provided for @incidentDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Describe el problema'**
  String get incidentDescriptionLabel;

  /// No description provided for @incidentDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: farola fundida en el Carrer Major'**
  String get incidentDescriptionHint;

  /// No description provided for @incidentSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar incidencia'**
  String get incidentSubmit;

  /// No description provided for @incidentSubmitted.
  ///
  /// In es, this message translates to:
  /// **'Incidencia enviada. Te avisaremos de su seguimiento.'**
  String get incidentSubmitted;

  /// No description provided for @incidentPhotoAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir foto'**
  String get incidentPhotoAdd;

  /// No description provided for @incidentPhotoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get incidentPhotoRemove;

  /// No description provided for @incidentPhotoSourceCamera.
  ///
  /// In es, this message translates to:
  /// **'Hacer foto'**
  String get incidentPhotoSourceCamera;

  /// No description provided for @incidentPhotoSourceGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get incidentPhotoSourceGallery;

  /// No description provided for @incidentDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Incidencia'**
  String get incidentDetailTitle;

  /// No description provided for @incidentHistoryHeading.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento'**
  String get incidentHistoryHeading;

  /// No description provided for @incidentStatusReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get incidentStatusReceived;

  /// No description provided for @incidentStatusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get incidentStatusInProgress;

  /// No description provided for @incidentStatusResolved.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get incidentStatusResolved;

  /// No description provided for @emptyIncidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'No has reportado ninguna incidencia'**
  String get emptyIncidentsTitle;

  /// No description provided for @emptyIncidentsBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando reportes un problema en la vía pública, aparecerá aquí.'**
  String get emptyIncidentsBody;

  /// No description provided for @incidentCategoryAlumbrado.
  ///
  /// In es, this message translates to:
  /// **'Alumbrado'**
  String get incidentCategoryAlumbrado;

  /// No description provided for @incidentCategoryBaches.
  ///
  /// In es, this message translates to:
  /// **'Baches y firme'**
  String get incidentCategoryBaches;

  /// No description provided for @incidentCategoryLimpieza.
  ///
  /// In es, this message translates to:
  /// **'Limpieza'**
  String get incidentCategoryLimpieza;

  /// No description provided for @incidentCategoryJardines.
  ///
  /// In es, this message translates to:
  /// **'Jardines y parques'**
  String get incidentCategoryJardines;

  /// No description provided for @incidentCategoryMobiliario.
  ///
  /// In es, this message translates to:
  /// **'Mobiliario urbano'**
  String get incidentCategoryMobiliario;

  /// No description provided for @incidentCategoryAgua.
  ///
  /// In es, this message translates to:
  /// **'Agua y saneamiento'**
  String get incidentCategoryAgua;

  /// No description provided for @incidentCategoryOtros.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get incidentCategoryOtros;

  /// No description provided for @surveyDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuesta'**
  String get surveyDetailTitle;

  /// No description provided for @surveyNonBinding.
  ///
  /// In es, this message translates to:
  /// **'Consulta no vinculante'**
  String get surveyNonBinding;

  /// No description provided for @surveyVote.
  ///
  /// In es, this message translates to:
  /// **'Votar'**
  String get surveyVote;

  /// No description provided for @surveyVoted.
  ///
  /// In es, this message translates to:
  /// **'Voto registrado'**
  String get surveyVoted;

  /// No description provided for @surveyYourVote.
  ///
  /// In es, this message translates to:
  /// **'Tu voto'**
  String get surveyYourVote;

  /// No description provided for @surveyClosedLabel.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get surveyClosedLabel;

  /// No description provided for @surveyResultsHidden.
  ///
  /// In es, this message translates to:
  /// **'Los resultados se verán al cerrarse la encuesta'**
  String get surveyResultsHidden;

  /// No description provided for @surveyIncludeClosedLabel.
  ///
  /// In es, this message translates to:
  /// **'Ver encuestas cerradas'**
  String get surveyIncludeClosedLabel;

  /// No description provided for @emptySurveysTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay encuestas abiertas'**
  String get emptySurveysTitle;

  /// No description provided for @emptySurveysBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento publicará aquí sus próximas consultas.'**
  String get emptySurveysBody;

  /// No description provided for @formDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Formulario'**
  String get formDetailTitle;

  /// No description provided for @formSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get formSubmit;

  /// No description provided for @formSubmitted.
  ///
  /// In es, this message translates to:
  /// **'Formulario enviado'**
  String get formSubmitted;

  /// No description provided for @formAlreadySubmitted.
  ///
  /// In es, this message translates to:
  /// **'Ya has enviado este formulario'**
  String get formAlreadySubmitted;

  /// No description provided for @formRequiredLabel.
  ///
  /// In es, this message translates to:
  /// **'obligatorio'**
  String get formRequiredLabel;

  /// No description provided for @formFieldRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio.'**
  String get formFieldRequiredError;

  /// No description provided for @formDeadlineLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite: {date}'**
  String formDeadlineLabel(String date);

  /// No description provided for @formIncludeClosedLabel.
  ///
  /// In es, this message translates to:
  /// **'Ver formularios cerrados'**
  String get formIncludeClosedLabel;

  /// No description provided for @formSelectPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Elige una opción'**
  String get formSelectPlaceholder;

  /// No description provided for @formBooleanYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get formBooleanYes;

  /// No description provided for @formBooleanNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get formBooleanNo;

  /// No description provided for @formPickDate.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get formPickDate;

  /// No description provided for @emptyFormsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay formularios abiertos'**
  String get emptyFormsTitle;

  /// No description provided for @emptyFormsBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento publicará aquí sus próximas inscripciones y solicitudes.'**
  String get emptyFormsBody;

  /// No description provided for @pharmacyTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'Farmacia de guardia hoy'**
  String get pharmacyTodayTitle;

  /// No description provided for @pharmacyUpcomingHeading.
  ///
  /// In es, this message translates to:
  /// **'Próximos días'**
  String get pharmacyUpcomingHeading;

  /// No description provided for @pharmacyNoneToday.
  ///
  /// In es, this message translates to:
  /// **'No hay farmacia de guardia registrada para hoy'**
  String get pharmacyNoneToday;

  /// No description provided for @pharmacyCall.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get pharmacyCall;

  /// No description provided for @pharmacyCallSemantic.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {name}, {phone}'**
  String pharmacyCallSemantic(String name, String phone);

  /// No description provided for @backSemantic.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get backSemantic;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get loading;

  /// No description provided for @businessesTitle.
  ///
  /// In es, this message translates to:
  /// **'Comercios'**
  String get businessesTitle;

  /// No description provided for @businessDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Comercio'**
  String get businessDetailTitle;

  /// No description provided for @businessCallSemantic.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {name}, {phone}'**
  String businessCallSemantic(String name, String phone);

  /// No description provided for @businessEmailSemantic.
  ///
  /// In es, this message translates to:
  /// **'Escribir a {name} por correo, {email}'**
  String businessEmailSemantic(String name, String email);

  /// No description provided for @businessWebsiteSemantic.
  ///
  /// In es, this message translates to:
  /// **'Abrir la web de {name}'**
  String businessWebsiteSemantic(String name);

  /// No description provided for @businessCall.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get businessCall;

  /// No description provided for @businessEmail.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get businessEmail;

  /// No description provided for @businessWebsite.
  ///
  /// In es, this message translates to:
  /// **'Ver web'**
  String get businessWebsite;

  /// No description provided for @businessNoPhotos.
  ///
  /// In es, this message translates to:
  /// **'Sin fotos'**
  String get businessNoPhotos;

  /// No description provided for @emptyBusinessesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay comercios registrados'**
  String get emptyBusinessesTitle;

  /// No description provided for @emptyBusinessesBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento irá añadiendo aquí los comercios del municipio.'**
  String get emptyBusinessesBody;

  /// No description provided for @galleryPrevious.
  ///
  /// In es, this message translates to:
  /// **'Foto anterior'**
  String get galleryPrevious;

  /// No description provided for @galleryNext.
  ///
  /// In es, this message translates to:
  /// **'Foto siguiente'**
  String get galleryNext;

  /// No description provided for @galleryGoToPhoto.
  ///
  /// In es, this message translates to:
  /// **'Ir a la foto {index} de {total}'**
  String galleryGoToPhoto(int index, int total);

  /// No description provided for @galleryPhotoOfTotal.
  ///
  /// In es, this message translates to:
  /// **'Foto {index} de {total}'**
  String galleryPhotoOfTotal(int index, int total);

  /// No description provided for @facilityDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Instalación'**
  String get facilityDetailTitle;

  /// No description provided for @myReservationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get myReservationsTitle;

  /// No description provided for @emptyFacilitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay instalaciones registradas'**
  String get emptyFacilitiesTitle;

  /// No description provided for @emptyFacilitiesBody.
  ///
  /// In es, this message translates to:
  /// **'El ayuntamiento irá añadiendo aquí sus pistas y espacios reservables.'**
  String get emptyFacilitiesBody;

  /// No description provided for @facilityFeeNoteHeading.
  ///
  /// In es, this message translates to:
  /// **'Tarifa'**
  String get facilityFeeNoteHeading;

  /// No description provided for @facilityOpeningHoursHeading.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get facilityOpeningHoursHeading;

  /// No description provided for @facilityOpeningHoursClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get facilityOpeningHoursClosed;

  /// No description provided for @facilitySelectDateHeading.
  ///
  /// In es, this message translates to:
  /// **'Elige un día'**
  String get facilitySelectDateHeading;

  /// No description provided for @facilitySlotsHeading.
  ///
  /// In es, this message translates to:
  /// **'Huecos disponibles'**
  String get facilitySlotsHeading;

  /// No description provided for @emptyFacilitySlotsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay huecos libres este día'**
  String get emptyFacilitySlotsTitle;

  /// No description provided for @emptyFacilitySlotsBody.
  ///
  /// In es, this message translates to:
  /// **'Prueba a elegir otro día.'**
  String get emptyFacilitySlotsBody;

  /// No description provided for @facilitySlotSemantic.
  ///
  /// In es, this message translates to:
  /// **'Hueco de {start} a {end}'**
  String facilitySlotSemantic(String start, String end);

  /// No description provided for @facilityBookConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Reservar este hueco?'**
  String get facilityBookConfirmTitle;

  /// No description provided for @facilityBookConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'{facility} · {date} · {start} - {end}'**
  String facilityBookConfirmBody(
    String facility,
    String date,
    String start,
    String end,
  );

  /// No description provided for @facilityBookConfirmAction.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get facilityBookConfirmAction;

  /// No description provided for @facilityBookedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Reserva confirmada'**
  String get facilityBookedSnackbar;

  /// No description provided for @dialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dialogCancel;

  /// No description provided for @emptyReservationsTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes reservas'**
  String get emptyReservationsTitle;

  /// No description provided for @emptyReservationsBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando reserves una instalación, aparecerá aquí.'**
  String get emptyReservationsBody;

  /// No description provided for @reservationCardSemantic.
  ///
  /// In es, this message translates to:
  /// **'{facility}. {date}, de {start} a {end}'**
  String reservationCardSemantic(
    String facility,
    String date,
    String start,
    String end,
  );

  /// No description provided for @reservationCancelAction.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get reservationCancelAction;

  /// No description provided for @reservationCancelSemantic.
  ///
  /// In es, this message translates to:
  /// **'Cancelar la reserva de {facility} del {date}'**
  String reservationCancelSemantic(String facility, String date);

  /// No description provided for @reservationCancelConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar esta reserva?'**
  String get reservationCancelConfirmTitle;

  /// No description provided for @reservationCancelConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer y el hueco quedará libre para otro vecino.'**
  String get reservationCancelConfirmBody;

  /// No description provided for @reservationCancelConfirmAction.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get reservationCancelConfirmAction;

  /// No description provided for @reservationCancelledSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada'**
  String get reservationCancelledSnackbar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
