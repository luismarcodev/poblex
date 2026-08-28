// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'Poblex';

  @override
  String get navHome => 'Inici';

  @override
  String get navNews => 'Notícies';

  @override
  String get navEvents => 'Agenda';

  @override
  String get navAlerts => 'Avisos';

  @override
  String get navMore => 'Més';

  @override
  String get sectionNews => 'Notícies';

  @override
  String get sectionEvents => 'Esdeveniments';

  @override
  String get sectionAlerts => 'Avisos';

  @override
  String get sectionIncidents => 'Incidències';

  @override
  String get sectionSurveys => 'Enquestes';

  @override
  String get sectionForms => 'Formularis';

  @override
  String get sectionPharmacies => 'Farmàcies de guàrdia';

  @override
  String get sectionBusinesses => 'Comerços';

  @override
  String get sectionFacilities => 'Instal·lacions';

  @override
  String get sectionSettings => 'Ajustos';

  @override
  String get sectionNewsDescription => 'Bans i avisos de l\'ajuntament';

  @override
  String get sectionEventsDescription => 'Agenda d\'actes del municipi';

  @override
  String get sectionAlertsDescription => 'Avisos meteorològics i d\'emergència';

  @override
  String get sectionIncidentsDescription =>
      'Comunica un problema a la via pública';

  @override
  String get sectionSurveysDescription =>
      'Consultes de l\'ajuntament als veïns';

  @override
  String get sectionFormsDescription => 'Inscripcions i sol·licituds';

  @override
  String get sectionPharmaciesDescription => 'Quina farmàcia està de guàrdia';

  @override
  String get sectionBusinessesDescription => 'Directori de comerços locals';

  @override
  String get sectionFacilitiesDescription =>
      'Reserva pistes i espais municipals';

  @override
  String get homeGreeting => 'El teu ajuntament, al mòbil';

  @override
  String get homeSectionsHeading => 'Seccions';

  @override
  String get homeLatestNewsHeading => 'Últimes notícies';

  @override
  String get homeSeeAll => 'Veure-les totes';

  @override
  String get drawerTitle => 'Seccions';

  @override
  String get drawerOpenLabel => 'Obrir el menú de seccions';

  @override
  String get drawerAccessibilityStatement => 'Declaració d\'accessibilitat';

  @override
  String get newsTabCurrent => 'Actualitat';

  @override
  String get newsTabArchive => 'Històric';

  @override
  String get newsPinnedLabel => 'Destacada';

  @override
  String get newsReadFullArticle => 'Llegir article complet';

  @override
  String newsAttachmentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adjunts',
      one: '1 adjunt',
      zero: 'Sense adjunts',
    );
    return '$_temp0';
  }

  @override
  String newsSemanticCard(
    String title,
    String category,
    String date,
    String attachments,
  ) {
    return 'Notícia. $title. Categoria $category. Publicada el $date. $attachments.';
  }

  @override
  String get newsFilterAll => 'Totes';

  @override
  String newsFilterSemantic(String category) {
    return 'Filtrar per $category';
  }

  @override
  String get newsDetailAttachmentsHeading => 'Adjunts';

  @override
  String get newsDetailTitle => 'Notícia';

  @override
  String newsImageSemantic(String title) {
    return 'Imatge de la notícia: $title';
  }

  @override
  String newsOpenAttachment(String name) {
    return 'Obrir $name';
  }

  @override
  String get categoryGeneral => 'General';

  @override
  String get categorySanitaria => 'Sanitària';

  @override
  String get categoryServicios => 'Serveis';

  @override
  String get categoryCultural => 'Cultural';

  @override
  String get categoryDeportes => 'Esports';

  @override
  String get categoryFiestas => 'Festes';

  @override
  String get categoryObras => 'Obres';

  @override
  String get languageFallbackNotice => 'Només disponible en castellà';

  @override
  String get languageFallbackNoticeValencian => 'Només disponible en valencià';

  @override
  String get loadingNews => 'Carregant notícies';

  @override
  String get emptyNewsTitle => 'Encara no hi ha notícies';

  @override
  String get emptyNewsBody => 'L\'ajuntament les anirà publicant ací.';

  @override
  String get emptyNewsArchiveTitle => 'L\'històric està buit';

  @override
  String get emptyNewsArchiveBody =>
      'Ací apareixeran les notícies amb més de 90 dies.';

  @override
  String get emptyByFilterTitle => 'No hi ha res en aquesta categoria';

  @override
  String get emptyByFilterBody =>
      'Prova a llevar el filtre per a veure tot el contingut.';

  @override
  String get emptyClearFilters => 'Llevar filtres';

  @override
  String get loadMore => 'Carregar-ne més';

  @override
  String get errorNetworkTitle => 'No hi ha connexió';

  @override
  String get errorNetworkBody =>
      'Comprova que tens dades o wifi i torna a intentar-ho.';

  @override
  String get errorTimeoutTitle => 'La connexió va molt lenta';

  @override
  String get errorTimeoutBody =>
      'No hem pogut carregar el contingut a temps. Intenta-ho de nou.';

  @override
  String get errorServerTitle => 'El servei no respon';

  @override
  String get errorServerBody =>
      'És un problema nostre, no teu. Torna a intentar-ho d\'ací a uns minuts.';

  @override
  String get errorNotFoundTitle => 'Aquest contingut ja no hi és';

  @override
  String get errorNotFoundBody => 'Pot ser que l\'ajuntament l\'haja retirat.';

  @override
  String get errorTooManyRequestsTitle => 'Massa intents';

  @override
  String get errorTooManyRequestsBody =>
      'Has fet moltes peticions seguides. Espera uns minuts abans de tornar a provar.';

  @override
  String get errorUnknownTitle => 'Alguna cosa ha fallat';

  @override
  String get errorUnknownBody =>
      'No hem pogut completar l\'operació. Intenta-ho de nou.';

  @override
  String get errorConflictTitle => 'Ja no està lliure';

  @override
  String get errorConflictBody => 'Algú s\'ha avançat. Tria una altra opció.';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String errorRetrySemantic(String section) {
    return 'Reintentar carregar $section';
  }

  @override
  String get onboardingMunicipalityTitle => 'De quin poble eres?';

  @override
  String get onboardingMunicipalityBody =>
      'Tria el teu municipi per a rebre els seus avisos. El podràs canviar quan vulgues des d\'Ajustos.';

  @override
  String get onboardingMunicipalityContinue => 'Continuar';

  @override
  String get onboardingSearchHint => 'Cercar municipi...';

  @override
  String get onboardingSearchClear => 'Esborrar cerca';

  @override
  String onboardingSearchNoResults(String query) {
    return 'No hi ha cap municipi que coincidisca amb \"$query\"';
  }

  @override
  String onboardingMunicipalitySemantic(String name) {
    return 'Escut de $name';
  }

  @override
  String get onboardingNoMunicipalitiesTitle =>
      'Encara no hi ha municipis disponibles';

  @override
  String get onboardingNoMunicipalitiesBody =>
      'Estem incorporant ajuntaments. Torna a intentar-ho més tard.';

  @override
  String get comingSoonTitle => 'Aquesta secció arriba prompte';

  @override
  String get comingSoonBody =>
      'L\'estem acabant. Mentrestant pots consultar les notícies del municipi.';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageBody =>
      'L\'idioma triat s\'aplica també a les notificacions.';

  @override
  String get settingsLanguageChanged => 'Idioma actualitzat';

  @override
  String get languageSpanish => 'Castellà';

  @override
  String get languageValencian => 'Valencià';

  @override
  String get notificationNewNews => 'Nova notícia de l\'ajuntament';

  @override
  String get notificationOpen => 'Obrir';

  @override
  String get notificationOtherMunicipality =>
      'Esta notícia pertany a un altre municipi i ja no està disponible en la selecció actual.';

  @override
  String pdfViewerSemantic(String name) {
    return 'Document PDF: $name';
  }

  @override
  String get pdfUnavailableTitle => 'No podem obrir este document';

  @override
  String get pdfUnavailableBody =>
      'Torna a la notícia i obri l\'adjunt de nou.';

  @override
  String get pdfBackToNews => 'Tornar a notícies';

  @override
  String get eventDetailTitle => 'Esdeveniment';

  @override
  String get eventPastLabel => 'Finalitzat';

  @override
  String get eventReminderSet => 'Avisar-me';

  @override
  String get eventReminderActive => 'Avís activat';

  @override
  String get eventReminderCancelled => 'Recordatori cancel·lat';

  @override
  String get eventReminderConfirmed => 'T\'avisarem abans de l\'esdeveniment';

  @override
  String eventReminderSemantic(String active, String title) {
    String _temp0 = intl.Intl.selectLogic(active, {
      'true': 'Recordatori activat per a $title',
      'other': 'Avisar-me de $title',
    });
    return '$_temp0';
  }

  @override
  String get eventPickReminderTitle => 'Quan vols que t\'avisem?';

  @override
  String eventLocationSemantic(String location) {
    return 'Lloc: $location';
  }

  @override
  String get emptyEventsTitle => 'Encara no hi ha esdeveniments';

  @override
  String get emptyEventsBody => 'L\'ajuntament els anirà afegint ací.';

  @override
  String get alertDetailTitle => 'Avís';

  @override
  String alertSeverityLabel(String severity) {
    String _temp0 = intl.Intl.selectLogic(severity, {
      'rojo': 'Avís roig · Nivell 3',
      'naranja': 'Avís taronja · Nivell 2',
      'other': 'Avís groc · Nivell 1',
    });
    return '$_temp0';
  }

  @override
  String get alertSourceAemet => 'Font: AEMET';

  @override
  String get alertSourceManual => 'Font: Ajuntament';

  @override
  String get alertActiveLabel => 'Vigent';

  @override
  String get alertExpiredLabel => 'Finalitzada';

  @override
  String get alertForcedNotice =>
      'Este avís es mostra encara que tingues les alertes silenciades';

  @override
  String get alertIncludeExpiredLabel => 'Veure avisos finalitzats';

  @override
  String alertPhenomenonTypeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'incendio': 'Incendi',
      'evacuacion': 'Evacuació',
      'sanitario': 'Sanitari',
      'meteorologico': 'Meteorològic',
      'other': 'Altre',
    });
    return '$_temp0';
  }

  @override
  String get homeActiveRedAlertBannerLabel => 'Avís roig actiu';

  @override
  String get emptyAlertsTitle => 'No hi ha avisos actius';

  @override
  String get emptyAlertsBody =>
      'T\'avisarem ací si l\'ajuntament o AEMET publiquen alguna cosa.';

  @override
  String get incidentReportTitle => 'Reportar incidència';

  @override
  String get incidentCategoryLabel => 'Categoria';

  @override
  String get incidentDescriptionLabel => 'Descriu el problema';

  @override
  String get incidentDescriptionHint =>
      'Per exemple: fanal fus al Carrer Major';

  @override
  String get incidentSubmit => 'Enviar incidència';

  @override
  String get incidentSubmitted =>
      'Incidència enviada. T\'avisarem del seguiment.';

  @override
  String get incidentPhotoAdd => 'Afegir foto';

  @override
  String get incidentPhotoRemove => 'Llevar foto';

  @override
  String get incidentPhotoSourceCamera => 'Fer foto';

  @override
  String get incidentPhotoSourceGallery => 'Triar de la galeria';

  @override
  String get incidentDetailTitle => 'Incidència';

  @override
  String get incidentHistoryHeading => 'Seguiment';

  @override
  String get incidentStatusReceived => 'Rebuda';

  @override
  String get incidentStatusInProgress => 'En curs';

  @override
  String get incidentStatusResolved => 'Resolta';

  @override
  String get emptyIncidentsTitle => 'No has reportat cap incidència';

  @override
  String get emptyIncidentsBody =>
      'Quan reportes un problema a la via pública, apareixerà ací.';

  @override
  String get incidentCategoryAlumbrado => 'Enllumenat';

  @override
  String get incidentCategoryBaches => 'Clots i ferm';

  @override
  String get incidentCategoryLimpieza => 'Neteja';

  @override
  String get incidentCategoryJardines => 'Jardins i parcs';

  @override
  String get incidentCategoryMobiliario => 'Mobiliari urbà';

  @override
  String get incidentCategoryAgua => 'Aigua i sanejament';

  @override
  String get incidentCategoryOtros => 'Altres';

  @override
  String get surveyDetailTitle => 'Enquesta';

  @override
  String get surveyNonBinding => 'Consulta no vinculant';

  @override
  String get surveyVote => 'Votar';

  @override
  String get surveyVoted => 'Vot registrat';

  @override
  String get surveyYourVote => 'El teu vot';

  @override
  String get surveyClosedLabel => 'Tancada';

  @override
  String get surveyResultsHidden =>
      'Els resultats es veuran en tancar-se l\'enquesta';

  @override
  String get surveyIncludeClosedLabel => 'Veure enquestes tancades';

  @override
  String get emptySurveysTitle => 'No hi ha enquestes obertes';

  @override
  String get emptySurveysBody =>
      'L\'ajuntament publicarà ací les seues pròximes consultes.';

  @override
  String get formDetailTitle => 'Formulari';

  @override
  String get formSubmit => 'Enviar';

  @override
  String get formSubmitted => 'Formulari enviat';

  @override
  String get formAlreadySubmitted => 'Ja has enviat este formulari';

  @override
  String get formRequiredLabel => 'obligatori';

  @override
  String formDeadlineLabel(String date) {
    return 'Data límit: $date';
  }

  @override
  String get formIncludeClosedLabel => 'Veure formularis tancats';

  @override
  String get formSelectPlaceholder => 'Tria una opció';

  @override
  String get formBooleanYes => 'Sí';

  @override
  String get formBooleanNo => 'No';

  @override
  String get formPickDate => 'Triar data';

  @override
  String get emptyFormsTitle => 'No hi ha formularis oberts';

  @override
  String get emptyFormsBody =>
      'L\'ajuntament publicarà ací les seues pròximes inscripcions i sol·licituds.';

  @override
  String get pharmacyTodayTitle => 'Farmàcia de guàrdia hui';

  @override
  String get pharmacyUpcomingHeading => 'Pròxims dies';

  @override
  String get pharmacyNoneToday =>
      'No hi ha farmàcia de guàrdia registrada per a hui';

  @override
  String get pharmacyCall => 'Telefonar';

  @override
  String pharmacyCallSemantic(String name, String phone) {
    return 'Telefonar a $name, $phone';
  }

  @override
  String get backSemantic => 'Tornar';

  @override
  String get loading => 'Carregant';

  @override
  String get businessesTitle => 'Comerços';

  @override
  String get businessDetailTitle => 'Comerç';

  @override
  String businessCallSemantic(String name, String phone) {
    return 'Telefonar a $name, $phone';
  }

  @override
  String businessEmailSemantic(String name, String email) {
    return 'Escriure a $name per correu, $email';
  }

  @override
  String businessWebsiteSemantic(String name) {
    return 'Obrir la web de $name';
  }

  @override
  String get businessCall => 'Telefonar';

  @override
  String get businessEmail => 'Escriure';

  @override
  String get businessWebsite => 'Veure web';

  @override
  String get businessNoPhotos => 'Sense fotos';

  @override
  String get emptyBusinessesTitle => 'No hi ha comerços registrats';

  @override
  String get emptyBusinessesBody =>
      'L\'ajuntament anirà afegint ací els comerços del municipi.';

  @override
  String get galleryPrevious => 'Foto anterior';

  @override
  String get galleryNext => 'Foto següent';

  @override
  String galleryGoToPhoto(int index, int total) {
    return 'Anar a la foto $index de $total';
  }

  @override
  String galleryPhotoOfTotal(int index, int total) {
    return 'Foto $index de $total';
  }

  @override
  String get facilityDetailTitle => 'Instal·lació';

  @override
  String get myReservationsTitle => 'Les meues reserves';

  @override
  String get emptyFacilitiesTitle => 'No hi ha instal·lacions registrades';

  @override
  String get emptyFacilitiesBody =>
      'L\'ajuntament anirà afegint ací les seues pistes i espais reservables.';

  @override
  String get facilityFeeNoteHeading => 'Tarifa';

  @override
  String get facilityOpeningHoursHeading => 'Horari';

  @override
  String get facilityOpeningHoursClosed => 'Tancat';

  @override
  String get facilitySelectDateHeading => 'Tria un dia';

  @override
  String get facilitySlotsHeading => 'Hores disponibles';

  @override
  String get emptyFacilitySlotsTitle => 'No hi ha hores lliures aquest dia';

  @override
  String get emptyFacilitySlotsBody => 'Prova a triar un altre dia.';

  @override
  String facilitySlotSemantic(String start, String end) {
    return 'Hora de $start a $end';
  }

  @override
  String get facilityBookConfirmTitle => 'Vols reservar aquesta hora?';

  @override
  String facilityBookConfirmBody(
    String facility,
    String date,
    String start,
    String end,
  ) {
    return '$facility · $date · $start - $end';
  }

  @override
  String get facilityBookConfirmAction => 'Confirmar reserva';

  @override
  String get facilityBookedSnackbar => 'Reserva confirmada';

  @override
  String get dialogCancel => 'Cancel·lar';

  @override
  String get emptyReservationsTitle => 'No tens reserves';

  @override
  String get emptyReservationsBody =>
      'Quan reserves una instal·lació, apareixerà ací.';

  @override
  String reservationCardSemantic(
    String facility,
    String date,
    String start,
    String end,
  ) {
    return '$facility. $date, de $start a $end';
  }

  @override
  String get reservationCancelAction => 'Cancel·lar reserva';

  @override
  String reservationCancelSemantic(String facility, String date) {
    return 'Cancel·lar la reserva de $facility del $date';
  }

  @override
  String get reservationCancelConfirmTitle =>
      'Vols cancel·lar aquesta reserva?';

  @override
  String get reservationCancelConfirmBody =>
      'Aquesta acció no es pot desfer i l\'hora quedarà lliure per a un altre veí.';

  @override
  String get reservationCancelConfirmAction => 'Sí, cancel·lar';

  @override
  String get reservationCancelledSnackbar => 'Reserva cancel·lada';
}
