// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Poblex';

  @override
  String get navHome => 'Inicio';

  @override
  String get navNews => 'Noticias';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navMore => 'Más';

  @override
  String get sectionNews => 'Noticias';

  @override
  String get sectionEvents => 'Eventos';

  @override
  String get sectionAlerts => 'Alertas';

  @override
  String get sectionIncidents => 'Incidencias';

  @override
  String get sectionSurveys => 'Encuestas';

  @override
  String get sectionForms => 'Formularios';

  @override
  String get sectionPharmacies => 'Farmacias de guardia';

  @override
  String get sectionBusinesses => 'Comercios';

  @override
  String get sectionFacilities => 'Instalaciones';

  @override
  String get sectionSettings => 'Ajustes';

  @override
  String get sectionNewsDescription => 'Bandos y avisos del ayuntamiento';

  @override
  String get sectionEventsDescription => 'Agenda de actos del municipio';

  @override
  String get sectionAlertsDescription =>
      'Avisos meteorológicos y de emergencia';

  @override
  String get sectionIncidentsDescription =>
      'Comunica un problema en la vía pública';

  @override
  String get sectionSurveysDescription =>
      'Consultas del ayuntamiento a los vecinos';

  @override
  String get sectionFormsDescription => 'Inscripciones y solicitudes';

  @override
  String get sectionPharmaciesDescription => 'Qué farmacia está de guardia';

  @override
  String get sectionBusinessesDescription => 'Directorio de comercios locales';

  @override
  String get sectionFacilitiesDescription =>
      'Reserva pistas y espacios municipales';

  @override
  String get homeGreeting => 'Tu ayuntamiento, en el móvil';

  @override
  String get homeSectionsHeading => 'Secciones';

  @override
  String get homeLatestNewsHeading => 'Últimas noticias';

  @override
  String get homeSeeAll => 'Ver todas';

  @override
  String get drawerTitle => 'Secciones';

  @override
  String get drawerOpenLabel => 'Abrir el menú de secciones';

  @override
  String get drawerAccessibilityStatement => 'Declaración de accesibilidad';

  @override
  String get newsTabCurrent => 'Actualidad';

  @override
  String get newsTabArchive => 'Histórico';

  @override
  String get newsPinnedLabel => 'Destacada';

  @override
  String get newsReadFullArticle => 'Leer artículo completo';

  @override
  String newsAttachmentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adjuntos',
      one: '1 adjunto',
      zero: 'Sin adjuntos',
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
    return 'Noticia. $title. Categoría $category. Publicada el $date. $attachments.';
  }

  @override
  String get newsFilterAll => 'Todas';

  @override
  String newsFilterSemantic(String category) {
    return 'Filtrar por $category';
  }

  @override
  String get newsDetailAttachmentsHeading => 'Adjuntos';

  @override
  String get newsDetailTitle => 'Noticia';

  @override
  String newsImageSemantic(String title) {
    return 'Imagen de la noticia: $title';
  }

  @override
  String newsOpenAttachment(String name) {
    return 'Abrir $name';
  }

  @override
  String get categoryGeneral => 'General';

  @override
  String get categorySanitaria => 'Sanitaria';

  @override
  String get categoryServicios => 'Servicios';

  @override
  String get categoryCultural => 'Cultural';

  @override
  String get categoryDeportes => 'Deportes';

  @override
  String get categoryFiestas => 'Fiestas';

  @override
  String get categoryObras => 'Obras';

  @override
  String get languageFallbackNotice => 'Solo disponible en castellano';

  @override
  String get languageFallbackNoticeValencian => 'Solo disponible en valenciano';

  @override
  String get loadingNews => 'Cargando noticias';

  @override
  String get emptyNewsTitle => 'Todavía no hay noticias';

  @override
  String get emptyNewsBody => 'El ayuntamiento las irá publicando aquí.';

  @override
  String get emptyNewsArchiveTitle => 'El histórico está vacío';

  @override
  String get emptyNewsArchiveBody =>
      'Aquí aparecerán las noticias con más de 90 días.';

  @override
  String get emptyByFilterTitle => 'No hay nada en esta categoría';

  @override
  String get emptyByFilterBody =>
      'Prueba a quitar el filtro para ver todo el contenido.';

  @override
  String get emptyClearFilters => 'Quitar filtros';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get errorNetworkTitle => 'No hay conexión';

  @override
  String get errorNetworkBody =>
      'Comprueba que tienes datos o wifi y vuelve a intentarlo.';

  @override
  String get errorTimeoutTitle => 'La conexión va muy lenta';

  @override
  String get errorTimeoutBody =>
      'No hemos podido cargar el contenido a tiempo. Inténtalo de nuevo.';

  @override
  String get errorServerTitle => 'El servicio no responde';

  @override
  String get errorServerBody =>
      'Es un problema nuestro, no tuyo. Vuelve a intentarlo en unos minutos.';

  @override
  String get errorNotFoundTitle => 'Este contenido ya no está';

  @override
  String get errorNotFoundBody => 'Puede que el ayuntamiento lo haya retirado.';

  @override
  String get errorTooManyRequestsTitle => 'Demasiados intentos';

  @override
  String get errorTooManyRequestsBody =>
      'Has hecho muchas peticiones seguidas. Espera unos minutos antes de volver a probar.';

  @override
  String get errorUnknownTitle => 'Algo ha fallado';

  @override
  String get errorUnknownBody =>
      'No hemos podido completar la operación. Inténtalo de nuevo.';

  @override
  String get errorConflictTitle => 'Ya no está libre';

  @override
  String get errorConflictBody =>
      'Alguien se te ha adelantado. Elige otra opción.';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String errorRetrySemantic(String section) {
    return 'Reintentar cargar $section';
  }

  @override
  String get onboardingMunicipalityTitle => '¿De qué pueblo eres?';

  @override
  String get onboardingMunicipalityBody =>
      'Elige tu municipio para recibir sus avisos. Podrás cambiarlo cuando quieras desde Ajustes.';

  @override
  String get onboardingMunicipalityContinue => 'Continuar';

  @override
  String get onboardingSearchHint => 'Buscar municipio...';

  @override
  String get onboardingSearchClear => 'Borrar búsqueda';

  @override
  String onboardingSearchNoResults(String query) {
    return 'No hay ningún municipio que coincida con \"$query\"';
  }

  @override
  String onboardingMunicipalitySemantic(String name) {
    return 'Escudo de $name';
  }

  @override
  String get onboardingNoMunicipalitiesTitle =>
      'Todavía no hay municipios disponibles';

  @override
  String get onboardingNoMunicipalitiesBody =>
      'Estamos incorporando ayuntamientos. Vuelve a intentarlo más tarde.';

  @override
  String get comingSoonTitle => 'Esta sección llega pronto';

  @override
  String get comingSoonBody =>
      'Estamos terminándola. Mientras tanto puedes consultar las noticias del municipio.';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageBody =>
      'El idioma elegido se aplica también a las notificaciones.';

  @override
  String get settingsLanguageChanged => 'Idioma actualizado';

  @override
  String get languageSpanish => 'Castellano';

  @override
  String get languageValencian => 'Valenciano';

  @override
  String get notificationNewNews => 'Nueva noticia del ayuntamiento';

  @override
  String get notificationOpen => 'Abrir';

  @override
  String get notificationOtherMunicipality =>
      'Esta noticia pertenece a otro municipio y ya no está disponible en tu selección actual.';

  @override
  String pdfViewerSemantic(String name) {
    return 'Documento PDF: $name';
  }

  @override
  String get pdfUnavailableTitle => 'No podemos abrir este documento';

  @override
  String get pdfUnavailableBody =>
      'Vuelve a la noticia y abre el adjunto de nuevo.';

  @override
  String get pdfBackToNews => 'Volver a noticias';

  @override
  String get eventDetailTitle => 'Evento';

  @override
  String get eventPastLabel => 'Finalizado';

  @override
  String get eventReminderSet => 'Avisarme';

  @override
  String get eventReminderActive => 'Aviso activado';

  @override
  String get eventReminderCancelled => 'Recordatorio cancelado';

  @override
  String get eventReminderConfirmed => 'Te avisaremos antes del evento';

  @override
  String eventReminderSemantic(String active, String title) {
    String _temp0 = intl.Intl.selectLogic(active, {
      'true': 'Recordatorio activado para $title',
      'other': 'Avisarme de $title',
    });
    return '$_temp0';
  }

  @override
  String get eventPickReminderTitle => '¿Cuándo quieres que te avisemos?';

  @override
  String eventLocationSemantic(String location) {
    return 'Lugar: $location';
  }

  @override
  String get emptyEventsTitle => 'Todavía no hay eventos';

  @override
  String get emptyEventsBody => 'El ayuntamiento los irá añadiendo aquí.';

  @override
  String get alertDetailTitle => 'Aviso';

  @override
  String alertSeverityLabel(String severity) {
    String _temp0 = intl.Intl.selectLogic(severity, {
      'rojo': 'Aviso rojo · Nivel 3',
      'naranja': 'Aviso naranja · Nivel 2',
      'other': 'Aviso amarillo · Nivel 1',
    });
    return '$_temp0';
  }

  @override
  String get alertSourceAemet => 'Fuente: AEMET';

  @override
  String get alertSourceManual => 'Fuente: Ayuntamiento';

  @override
  String get alertActiveLabel => 'Vigente';

  @override
  String get alertExpiredLabel => 'Finalizada';

  @override
  String get alertForcedNotice =>
      'Este aviso se muestra aunque tengas las alertas silenciadas';

  @override
  String get alertIncludeExpiredLabel => 'Ver avisos finalizados';

  @override
  String alertPhenomenonTypeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'incendio': 'Incendio',
      'evacuacion': 'Evacuación',
      'sanitario': 'Sanitario',
      'meteorologico': 'Meteorológico',
      'other': 'Otro',
    });
    return '$_temp0';
  }

  @override
  String get homeActiveRedAlertBannerLabel => 'Aviso rojo activo';

  @override
  String get emptyAlertsTitle => 'No hay avisos activos';

  @override
  String get emptyAlertsBody =>
      'Te avisaremos aquí si el ayuntamiento o AEMET publican algo.';

  @override
  String get incidentReportTitle => 'Reportar incidencia';

  @override
  String get incidentCategoryLabel => 'Categoría';

  @override
  String get incidentDescriptionLabel => 'Describe el problema';

  @override
  String get incidentDescriptionHint =>
      'Por ejemplo: farola fundida en el Carrer Major';

  @override
  String get incidentSubmit => 'Enviar incidencia';

  @override
  String get incidentSubmitted =>
      'Incidencia enviada. Te avisaremos de su seguimiento.';

  @override
  String get incidentPhotoAdd => 'Añadir foto';

  @override
  String get incidentPhotoRemove => 'Quitar foto';

  @override
  String get incidentPhotoSourceCamera => 'Hacer foto';

  @override
  String get incidentPhotoSourceGallery => 'Elegir de la galería';

  @override
  String get incidentDetailTitle => 'Incidencia';

  @override
  String get incidentHistoryHeading => 'Seguimiento';

  @override
  String get incidentStatusReceived => 'Recibida';

  @override
  String get incidentStatusInProgress => 'En curso';

  @override
  String get incidentStatusResolved => 'Resuelta';

  @override
  String get emptyIncidentsTitle => 'No has reportado ninguna incidencia';

  @override
  String get emptyIncidentsBody =>
      'Cuando reportes un problema en la vía pública, aparecerá aquí.';

  @override
  String get incidentCategoryAlumbrado => 'Alumbrado';

  @override
  String get incidentCategoryBaches => 'Baches y firme';

  @override
  String get incidentCategoryLimpieza => 'Limpieza';

  @override
  String get incidentCategoryJardines => 'Jardines y parques';

  @override
  String get incidentCategoryMobiliario => 'Mobiliario urbano';

  @override
  String get incidentCategoryAgua => 'Agua y saneamiento';

  @override
  String get incidentCategoryOtros => 'Otros';

  @override
  String get surveyDetailTitle => 'Encuesta';

  @override
  String get surveyNonBinding => 'Consulta no vinculante';

  @override
  String get surveyVote => 'Votar';

  @override
  String get surveyVoted => 'Voto registrado';

  @override
  String get surveyYourVote => 'Tu voto';

  @override
  String get surveyClosedLabel => 'Cerrada';

  @override
  String get surveyResultsHidden =>
      'Los resultados se verán al cerrarse la encuesta';

  @override
  String get surveyIncludeClosedLabel => 'Ver encuestas cerradas';

  @override
  String get emptySurveysTitle => 'No hay encuestas abiertas';

  @override
  String get emptySurveysBody =>
      'El ayuntamiento publicará aquí sus próximas consultas.';

  @override
  String get formDetailTitle => 'Formulario';

  @override
  String get formSubmit => 'Enviar';

  @override
  String get formSubmitted => 'Formulario enviado';

  @override
  String get formAlreadySubmitted => 'Ya has enviado este formulario';

  @override
  String get formRequiredLabel => 'obligatorio';

  @override
  String get formFieldRequiredError => 'Este campo es obligatorio.';

  @override
  String formDeadlineLabel(String date) {
    return 'Fecha límite: $date';
  }

  @override
  String get formIncludeClosedLabel => 'Ver formularios cerrados';

  @override
  String get formSelectPlaceholder => 'Elige una opción';

  @override
  String get formBooleanYes => 'Sí';

  @override
  String get formBooleanNo => 'No';

  @override
  String get formPickDate => 'Elegir fecha';

  @override
  String get emptyFormsTitle => 'No hay formularios abiertos';

  @override
  String get emptyFormsBody =>
      'El ayuntamiento publicará aquí sus próximas inscripciones y solicitudes.';

  @override
  String get pharmacyTodayTitle => 'Farmacia de guardia hoy';

  @override
  String get pharmacyUpcomingHeading => 'Próximos días';

  @override
  String get pharmacyNoneToday =>
      'No hay farmacia de guardia registrada para hoy';

  @override
  String get pharmacyCall => 'Llamar';

  @override
  String pharmacyCallSemantic(String name, String phone) {
    return 'Llamar a $name, $phone';
  }

  @override
  String get backSemantic => 'Volver';

  @override
  String get loading => 'Cargando';

  @override
  String get businessesTitle => 'Comercios';

  @override
  String get businessDetailTitle => 'Comercio';

  @override
  String businessCallSemantic(String name, String phone) {
    return 'Llamar a $name, $phone';
  }

  @override
  String businessEmailSemantic(String name, String email) {
    return 'Escribir a $name por correo, $email';
  }

  @override
  String businessWebsiteSemantic(String name) {
    return 'Abrir la web de $name';
  }

  @override
  String get businessCall => 'Llamar';

  @override
  String get businessEmail => 'Escribir';

  @override
  String get businessWebsite => 'Ver web';

  @override
  String get businessNoPhotos => 'Sin fotos';

  @override
  String get emptyBusinessesTitle => 'No hay comercios registrados';

  @override
  String get emptyBusinessesBody =>
      'El ayuntamiento irá añadiendo aquí los comercios del municipio.';

  @override
  String get galleryPrevious => 'Foto anterior';

  @override
  String get galleryNext => 'Foto siguiente';

  @override
  String galleryGoToPhoto(int index, int total) {
    return 'Ir a la foto $index de $total';
  }

  @override
  String galleryPhotoOfTotal(int index, int total) {
    return 'Foto $index de $total';
  }

  @override
  String get facilityDetailTitle => 'Instalación';

  @override
  String get myReservationsTitle => 'Mis reservas';

  @override
  String get emptyFacilitiesTitle => 'No hay instalaciones registradas';

  @override
  String get emptyFacilitiesBody =>
      'El ayuntamiento irá añadiendo aquí sus pistas y espacios reservables.';

  @override
  String get facilityFeeNoteHeading => 'Tarifa';

  @override
  String get facilityOpeningHoursHeading => 'Horario';

  @override
  String get facilityOpeningHoursClosed => 'Cerrado';

  @override
  String get facilitySelectDateHeading => 'Elige un día';

  @override
  String get facilitySlotsHeading => 'Huecos disponibles';

  @override
  String get emptyFacilitySlotsTitle => 'No hay huecos libres este día';

  @override
  String get emptyFacilitySlotsBody => 'Prueba a elegir otro día.';

  @override
  String facilitySlotSemantic(String start, String end) {
    return 'Hueco de $start a $end';
  }

  @override
  String get facilityBookConfirmTitle => '¿Reservar este hueco?';

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
  String get dialogCancel => 'Cancelar';

  @override
  String get emptyReservationsTitle => 'No tienes reservas';

  @override
  String get emptyReservationsBody =>
      'Cuando reserves una instalación, aparecerá aquí.';

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
  String get reservationCancelAction => 'Cancelar reserva';

  @override
  String reservationCancelSemantic(String facility, String date) {
    return 'Cancelar la reserva de $facility del $date';
  }

  @override
  String get reservationCancelConfirmTitle => '¿Cancelar esta reserva?';

  @override
  String get reservationCancelConfirmBody =>
      'Esta acción no se puede deshacer y el hueco quedará libre para otro vecino.';

  @override
  String get reservationCancelConfirmAction => 'Sí, cancelar';

  @override
  String get reservationCancelledSnackbar => 'Reserva cancelada';
}
