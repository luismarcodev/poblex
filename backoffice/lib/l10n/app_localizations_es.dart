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
  String get backofficeTitle => 'Gestión municipal';

  @override
  String get loginTitle => 'Acceso de gestores';

  @override
  String get loginSubtitle => 'Entra con la cuenta facilitada por Poblex.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get invalidEmail => 'Introduce un correo electrónico válido';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginError =>
      'No hemos podido iniciar sesión. Revisa tus datos e inténtalo de nuevo.';

  @override
  String get forgotPasswordLink => 'He olvidado mi contraseña';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Introduce tu correo y te enviaremos un enlace para crear una contraseña nueva.';

  @override
  String get sendResetLinkButton => 'Enviar enlace';

  @override
  String get resetEmailSentTitle => 'Revisa tu correo';

  @override
  String get resetEmailSentMessage =>
      'Si existe una cuenta con ese correo, recibirás un enlace de recuperación. Puede tardar unos minutos.';

  @override
  String get backToLoginButton => 'Volver al acceso';

  @override
  String get resetPasswordTitle => 'Crear una contraseña nueva';

  @override
  String get resetPasswordSubtitle =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get newPasswordLabel => 'Contraseña nueva';

  @override
  String get confirmPasswordLabel => 'Repite la contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get resetPasswordButton => 'Guardar contraseña';

  @override
  String get passwordResetSuccessTitle => 'Contraseña actualizada';

  @override
  String get passwordResetSuccessMessage =>
      'Ya puedes entrar con tu nueva contraseña.';

  @override
  String get invalidOrExpiredResetLink =>
      'El enlace de recuperación no es válido o ha caducado.';

  @override
  String get loading => 'Cargando';

  @override
  String get retry => 'Reintentar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get newsTitle => 'Noticias';

  @override
  String get newNews => 'Nueva noticia';

  @override
  String get municipalityLabel => 'Municipio';

  @override
  String get includeArchived => 'Mostrar archivadas';

  @override
  String get noNewsTitle => 'No hay noticias';

  @override
  String get noNewsBody => 'Publica la primera noticia para este municipio.';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get edit => 'Editar';

  @override
  String get pin => 'Destacar';

  @override
  String get unpin => 'Quitar destacado';

  @override
  String get archive => 'Archivar';

  @override
  String get restore => 'Restaurar';

  @override
  String get delete => 'Borrar';

  @override
  String get deleteTitle => '¿Borrar esta noticia?';

  @override
  String get deleteBody => 'Esta acción no se puede deshacer.';

  @override
  String get confirmDelete => 'Sí, borrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get editorNewTitle => 'Nueva noticia';

  @override
  String get editorEditTitle => 'Editar noticia';

  @override
  String get titleSpanish => 'Título en castellano';

  @override
  String get titleValencian => 'Título en valenciano (opcional)';

  @override
  String get bodySpanish => 'Contenido en castellano';

  @override
  String get bodyValencian => 'Contenido en valenciano (opcional)';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryHint => 'Por ejemplo: general, cultura, obras';

  @override
  String get imageUrlLabel => 'URL de imagen (opcional)';

  @override
  String get publishMunicipalities => 'Municipios donde publicar';

  @override
  String get pinnedLabel => 'Publicar como destacada';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get publish => 'Publicar noticia';

  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get invalidCategory => 'Usa minúsculas, números y guiones medios';

  @override
  String get invalidUrl =>
      'Introduce una URL válida que empiece por http:// o https://';

  @override
  String get savedMessage => 'Cambios guardados';

  @override
  String get publishedMessage => 'Noticia publicada';

  @override
  String get newsAttachmentsTitle => 'Adjuntos';

  @override
  String get newsAttachmentsHelp => 'PDF, JPG, PNG o WebP. Máximo 5 MB.';

  @override
  String get newsAttachmentAdd => 'Añadir adjunto';

  @override
  String get newsAttachmentUploading => 'Subiendo adjunto…';

  @override
  String get newsAttachmentPublishFirst =>
      'Publica la noticia antes de añadir adjuntos.';

  @override
  String get newsAttachmentUploadSuccess => 'Adjunto añadido correctamente.';

  @override
  String get newsAttachmentTooLarge => 'El archivo supera el máximo de 5 MB.';

  @override
  String get newsAttachmentUnsupportedType =>
      'El archivo no es un PDF, JPG, PNG o WebP válido.';

  @override
  String get newsAttachmentInvalidFile => 'No se ha podido leer el archivo.';

  @override
  String get newsAttachmentUploadError => 'No se ha podido subir el adjunto.';

  @override
  String get newsAttachmentRetry => 'Reintentar subida';

  @override
  String newsAttachmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adjuntos',
      one: '1 adjunto',
    );
    return '$_temp0';
  }

  @override
  String get eventsTitle => 'Eventos';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get includePastEvents => 'Mostrar eventos pasados';

  @override
  String get noEventsTitle => 'No hay eventos';

  @override
  String get noEventsBody => 'Publica el primer evento para este municipio.';

  @override
  String get eventUpcomingStatus => 'Próximo';

  @override
  String get eventOngoingStatus => 'En curso';

  @override
  String get eventPastStatus => 'Finalizado';

  @override
  String eventStartsOn(String date) {
    return 'Empieza el $date';
  }

  @override
  String eventEndsOn(String date) {
    return 'Termina el $date';
  }

  @override
  String get deleteEventTitle => '¿Borrar este evento?';

  @override
  String get deleteEventBody => 'Esta acción no se puede deshacer.';

  @override
  String get eventEditorNewTitle => 'Nuevo evento';

  @override
  String get eventEditorEditTitle => 'Editar evento';

  @override
  String get eventDescriptionSpanish => 'Descripción en castellano';

  @override
  String get eventDescriptionValencian =>
      'Descripción en valenciano (opcional)';

  @override
  String get eventStartLabel => 'Inicio';

  @override
  String get eventEndLabel => 'Fin';

  @override
  String get eventChangeDate => 'Cambiar fecha y hora';

  @override
  String get eventSetEndDate => 'Añadir fecha de fin';

  @override
  String get eventRemoveEndDate => 'Quitar fecha de fin';

  @override
  String get eventLocationLabel => 'Lugar';

  @override
  String get eventLatitudeLabel => 'Latitud (opcional)';

  @override
  String get eventLongitudeLabel => 'Longitud (opcional)';

  @override
  String get eventCoordinatePairRequired =>
      'Introduce las dos coordenadas o deja ambas vacías';

  @override
  String get invalidLatitude => 'Introduce una latitud entre -90 y 90';

  @override
  String get invalidLongitude => 'Introduce una longitud entre -180 y 180';

  @override
  String get eventEndBeforeStart =>
      'La fecha de fin no puede ser anterior al inicio';

  @override
  String get publishEvent => 'Publicar evento';

  @override
  String get eventPublishedMessage => 'Evento publicado';

  @override
  String get incidentsTitle => 'Incidencias';

  @override
  String get incidentFiltersTitle => 'Filtros de incidencias';

  @override
  String get incidentStatusLabel => 'Estado';

  @override
  String get incidentStatusAll => 'Todos los estados';

  @override
  String get incidentStatusReceived => 'Recibida';

  @override
  String get incidentStatusInProgress => 'En tramitación';

  @override
  String get incidentStatusResolved => 'Resuelta';

  @override
  String get incidentCategoryAll => 'Todas las categorías';

  @override
  String get incidentCategoryHint => 'Categoría';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get noIncidentsTitle => 'No hay incidencias';

  @override
  String get noIncidentsBody =>
      'No hay incidencias que coincidan con los filtros seleccionados.';

  @override
  String incidentReportedOn(String date) {
    return 'Comunicada el $date';
  }

  @override
  String incidentUpdatedOn(String date) {
    return 'Actualizada el $date';
  }

  @override
  String get incidentOpenDetails => 'Ver detalle de la incidencia';

  @override
  String get incidentDetailTitle => 'Detalle de incidencia';

  @override
  String get incidentDescriptionTitle => 'Descripción';

  @override
  String get incidentPhotoTitle => 'Fotografía';

  @override
  String get incidentPhotoSemanticLabel => 'Fotografía adjunta a la incidencia';

  @override
  String get incidentLocationTitle => 'Ubicación';

  @override
  String incidentCoordinates(String lat, String lng) {
    return 'Latitud $lat, longitud $lng';
  }

  @override
  String get incidentHistoryTitle => 'Historial de cambios';

  @override
  String get incidentHistoryUnavailable =>
      'El historial detallado todavía no está disponible en este panel.';

  @override
  String get incidentStatusChangeTitle => 'Cambiar estado';

  @override
  String get incidentNewStatusLabel => 'Estado nuevo';

  @override
  String get incidentNoteLabel => 'Nota interna';

  @override
  String get incidentNoteHint => 'Explica brevemente el motivo del cambio';

  @override
  String get incidentNoteMaxLength =>
      'La nota no puede superar los 1.000 caracteres';

  @override
  String get incidentSaveStatus => 'Guardar estado';

  @override
  String get incidentStatusSaved => 'Estado actualizado';

  @override
  String get incidentInvalidTransition =>
      'Ese cambio de estado no está permitido.';

  @override
  String get close => 'Cerrar';

  @override
  String get surveysTitle => 'Encuestas';

  @override
  String get surveysNonBindingLabel => 'Encuestas no vinculantes';

  @override
  String get surveysNonBindingExplanation =>
      'Los resultados son orientativos y no verifican el empadronamiento de quien vota.';

  @override
  String get includeClosedSurveys => 'Mostrar encuestas cerradas';

  @override
  String get newSurvey => 'Nueva encuesta';

  @override
  String get noSurveysTitle => 'No hay encuestas';

  @override
  String get noSurveysBody =>
      'Publica la primera encuesta para este municipio.';

  @override
  String get surveyOpenStatus => 'Abierta';

  @override
  String get surveyClosedStatus => 'Cerrada';

  @override
  String surveyClosesOn(String date) {
    return 'Cierra el $date';
  }

  @override
  String surveyClosedOn(String date) {
    return 'Cerrada el $date';
  }

  @override
  String surveyOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opciones',
      one: '1 opción',
    );
    return '$_temp0';
  }

  @override
  String get surveyViewResults => 'Ver resultados';

  @override
  String get surveyClose => 'Cerrar encuesta';

  @override
  String get surveyCloseTitle => '¿Cerrar esta encuesta?';

  @override
  String get surveyCloseBody => 'Después de cerrarla no admitirá más votos.';

  @override
  String get surveyResultsTitle => 'Resultados';

  @override
  String get surveyResultsHidden =>
      'Los resultados están ocultos para los vecinos.';

  @override
  String get surveyShowResults => 'Mostrar resultados a los vecinos';

  @override
  String get surveyHideResults => 'Ocultar resultados a los vecinos';

  @override
  String surveyVotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String surveyTotalVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos totales',
      one: '1 voto total',
    );
    return '$_temp0';
  }

  @override
  String get surveyExportCsv => 'Exportar CSV';

  @override
  String get surveyCsvDownloaded => 'CSV descargado';

  @override
  String get surveyCreatedMessage => 'Encuesta publicada';

  @override
  String get surveyCreateTitle => 'Nueva encuesta';

  @override
  String get surveyQuestionSpanish => 'Pregunta en castellano';

  @override
  String get surveyQuestionValencian => 'Pregunta en valenciano (opcional)';

  @override
  String get surveyOptionsTitle => 'Opciones de respuesta';

  @override
  String surveyOptionSpanish(int number) {
    return 'Opción $number en castellano';
  }

  @override
  String surveyOptionValencian(int number) {
    return 'Opción $number en valenciano (opcional)';
  }

  @override
  String get surveyAddOption => 'Añadir opción';

  @override
  String surveyRemoveOption(int number) {
    return 'Eliminar la opción $number';
  }

  @override
  String get surveyMinimumOptions => 'Añade al menos dos opciones';

  @override
  String get surveyClosingDate => 'Fecha de cierre';

  @override
  String get surveyChangeClosingDate => 'Cambiar fecha de cierre';

  @override
  String get surveyResultsVisibleFromStart =>
      'Mostrar resultados desde el principio';

  @override
  String get publishSurvey => 'Publicar encuesta';

  @override
  String get surveyFutureClosingRequired =>
      'La fecha de cierre debe ser posterior a la actual';

  @override
  String get deleteSurveyTitle => '¿Borrar esta encuesta?';

  @override
  String get deleteSurveyBody =>
      'Se borrarán también sus opciones y votos. Esta acción no se puede deshacer.';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get newAlert => 'Nueva alerta';

  @override
  String get includeExpiredAlerts => 'Mostrar alertas finalizadas';

  @override
  String get noAlertsTitle => 'No hay alertas';

  @override
  String get noAlertsBody => 'No hay alertas para este municipio.';

  @override
  String get alertSourceManual => 'Manual';

  @override
  String get alertSourceAemet => 'AEMET';

  @override
  String get alertStatusScheduled => 'Programada';

  @override
  String get alertStatusActive => 'Activa';

  @override
  String get alertStatusExpired => 'Finalizada';

  @override
  String get alertSeverityYellow => 'Aviso amarillo · Nivel 1';

  @override
  String get alertSeverityOrange => 'Aviso naranja · Nivel 2';

  @override
  String get alertSeverityRed => 'Aviso rojo · Nivel 3';

  @override
  String alertStartsAt(String date) {
    return 'Empieza el $date';
  }

  @override
  String alertEndsAt(String date) {
    return 'Termina el $date';
  }

  @override
  String get alertWithoutEnd => 'Sin fecha de finalización';

  @override
  String alertCardSemantics(String severity, String phenomenon) {
    return '$severity. $phenomenon';
  }

  @override
  String alertCreatedBy(String manager) {
    return 'Creada por $manager';
  }

  @override
  String alertUpdatedBy(String manager) {
    return 'Actualizada por $manager';
  }

  @override
  String get deleteAlertTitle => '¿Borrar esta alerta?';

  @override
  String get deleteAlertBody => 'Esta acción no se puede deshacer.';

  @override
  String get alertEditorNewTitle => 'Nueva alerta manual';

  @override
  String get alertEditorEditTitle => 'Editar alerta manual';

  @override
  String get alertPhenomenonLabel => 'Fenómeno o motivo';

  @override
  String get alertPhenomenonTypeField => 'Tipo de fenómeno';

  @override
  String get alertPhenomenonTypeIncendio => 'Incendio';

  @override
  String get alertPhenomenonTypeEvacuacion => 'Evacuación';

  @override
  String get alertPhenomenonTypeSanitario => 'Sanitario';

  @override
  String get alertPhenomenonTypeMeteorologico => 'Meteorológico';

  @override
  String get alertPhenomenonTypeOtro => 'Otro';

  @override
  String get alertSeverityField => 'Nivel de aviso';

  @override
  String get alertBodySpanish => 'Mensaje en castellano';

  @override
  String get alertBodyValencian => 'Mensaje en valenciano (opcional)';

  @override
  String get alertStartField => 'Inicio';

  @override
  String get alertEndField => 'Fin';

  @override
  String get clearAlertEnd => 'Quitar fecha de finalización';

  @override
  String get publishAlert => 'Publicar alerta';

  @override
  String get alertPublishedMessage => 'Alerta publicada';

  @override
  String get alertEndBeforeStart =>
      'La fecha de fin no puede ser anterior al inicio';

  @override
  String get alertRedPushWarning =>
      'Las alertas rojas enviarán una notificación obligatoria a los vecinos del municipio.';

  @override
  String get alertAemetReadOnly =>
      'Las alertas procedentes de AEMET son de solo lectura y no se pueden modificar desde el panel.';

  @override
  String get pharmaciesTitle => 'Farmacias de guardia';

  @override
  String get pharmaciesSubtitle => 'Carga manual de las guardias del municipio';

  @override
  String get newDutyPharmacy => 'Añadir guardia';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get currentMonth => 'Mes actual';

  @override
  String get noDutyPharmaciesTitle => 'No hay guardias cargadas';

  @override
  String get noDutyPharmaciesBody =>
      'Añade las farmacias de guardia para este mes.';

  @override
  String get dutyPharmacyDateLabel => 'Fecha de guardia';

  @override
  String get dutyPharmacyNameLabel => 'Nombre de la farmacia';

  @override
  String get dutyPharmacyAddressLabel => 'Dirección';

  @override
  String get dutyPharmacyPhoneLabel => 'Teléfono';

  @override
  String get dutyPharmacyScheduleLabel => 'Horario';

  @override
  String get editDutyPharmacy => 'Editar guardia';

  @override
  String get dutyPharmacyEditorNewTitle => 'Nueva farmacia de guardia';

  @override
  String get dutyPharmacyEditorEditTitle => 'Editar farmacia de guardia';

  @override
  String get saveDutyPharmacy => 'Guardar guardia';

  @override
  String get dutyPharmacySavedMessage => 'Farmacia de guardia guardada';

  @override
  String get dutyPharmacyDateExists =>
      'Ya existe una farmacia de guardia para esa fecha. Puedes editarla desde el listado.';

  @override
  String get selectDutyPharmacyDate => 'Seleccionar fecha de guardia';

  @override
  String get formsTitle => 'Formularios';

  @override
  String get newForm => 'Nuevo formulario';

  @override
  String get includeClosedForms => 'Mostrar formularios cerrados';

  @override
  String get formsEmpty => 'No hay formularios para este municipio.';

  @override
  String get formOpenStatus => 'Abierto';

  @override
  String get formClosedStatus => 'Cerrado';

  @override
  String get formNoDeadline => 'Sin fecha límite';

  @override
  String formDeadline(String date) {
    return 'Fecha límite: $date';
  }

  @override
  String formFieldsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos',
      one: '1 campo',
    );
    return '$_temp0';
  }

  @override
  String get formExportSubmissions => 'Exportar respuestas CSV';

  @override
  String get formExportSuccess => 'Respuestas descargadas';

  @override
  String get formExportUnsupported =>
      'La descarga solo está disponible en la versión web del panel.';

  @override
  String get formDeleteTitle => '¿Borrar este formulario?';

  @override
  String get formDeleteBody =>
      'Se borrarán también todas sus respuestas. Esta acción no se puede deshacer.';

  @override
  String get formCreateTitle => 'Nuevo formulario';

  @override
  String get formTitleSpanish => 'Título en castellano';

  @override
  String get formTitleValencian => 'Título en valenciano (opcional)';

  @override
  String get formDescriptionSpanish => 'Descripción en castellano';

  @override
  String get formDescriptionValencian => 'Descripción en valenciano (opcional)';

  @override
  String get formOptionalDeadline => 'Fecha límite (opcional)';

  @override
  String get formChooseDeadline => 'Elegir fecha límite';

  @override
  String get formClearDeadline => 'Quitar fecha límite';

  @override
  String get formFieldsTitle => 'Campos del formulario';

  @override
  String formFieldNumber(int number) {
    return 'Campo $number';
  }

  @override
  String get formFieldKey => 'Identificador interno';

  @override
  String get formFieldKeyHint => 'Por ejemplo: nombre_completo';

  @override
  String get formFieldLabelSpanish => 'Etiqueta en castellano';

  @override
  String get formFieldLabelValencian => 'Etiqueta en valenciano (opcional)';

  @override
  String get formFieldType => 'Tipo de campo';

  @override
  String get formFieldRequired => 'Respuesta obligatoria';

  @override
  String get formFieldOptions => 'Opciones';

  @override
  String get formFieldOptionsHint => 'Una opción por línea';

  @override
  String get formAddField => 'Añadir campo';

  @override
  String get formRemoveField => 'Eliminar campo';

  @override
  String get formMoveFieldUp => 'Subir campo';

  @override
  String get formMoveFieldDown => 'Bajar campo';

  @override
  String get formCreated => 'Formulario publicado';

  @override
  String get formInvalidFieldKey =>
      'Usa minúsculas, números y guiones bajos, sin espacios';

  @override
  String get formSelectNeedsOptions =>
      'Añade al menos dos opciones para el campo de selección';

  @override
  String get formDuplicateFieldKeys =>
      'Cada campo debe tener un identificador interno distinto';

  @override
  String get formFutureDeadline =>
      'La fecha límite debe ser posterior a la actual';

  @override
  String get formFieldTypeText => 'Texto';

  @override
  String get formFieldTypeNumber => 'Número';

  @override
  String get formFieldTypeSelect => 'Selección';

  @override
  String get formFieldTypeDate => 'Fecha';

  @override
  String get formFieldTypeBoolean => 'Sí o no';

  @override
  String get genericError => 'Algo ha fallado. Inténtalo de nuevo.';

  @override
  String get networkError => 'No se puede conectar con el servidor.';

  @override
  String get unauthorizedError => 'Tu sesión ha caducado. Vuelve a entrar.';

  @override
  String get archivedLabel => 'Archivada';

  @override
  String get pinnedStatusLabel => 'Destacada';

  @override
  String get activeLabel => 'Activa';

  @override
  String publishedOn(Object date) {
    return 'Publicada el $date';
  }

  @override
  String get managerWithoutMunicipalities =>
      'Esta cuenta no tiene municipios asignados.';

  @override
  String get openMenu => 'Abrir menú';

  @override
  String get closeMenu => 'Cerrar menú';

  @override
  String get businessesTitle => 'Comercios';

  @override
  String get newBusiness => 'Nuevo comercio';

  @override
  String get includeInactiveBusinesses => 'Mostrar inactivos';

  @override
  String get noBusinessesTitle => 'No hay comercios';

  @override
  String get noBusinessesBody =>
      'Da de alta el primer comercio de este municipio.';

  @override
  String get businessInactiveLabel => 'Inactivo';

  @override
  String get deleteBusinessTitle => '¿Borrar este comercio?';

  @override
  String get deleteBusinessBody => 'Esta acción no se puede deshacer.';

  @override
  String get activate => 'Activar';

  @override
  String get deactivate => 'Desactivar';

  @override
  String get editorNewBusinessTitle => 'Nuevo comercio';

  @override
  String get editorEditBusinessTitle => 'Editar comercio';

  @override
  String get businessNameLabel => 'Nombre';

  @override
  String get businessCategoryLabel => 'Categoría';

  @override
  String get businessCategoryHint =>
      'Por ejemplo: bar, alimentacion, peluqueria';

  @override
  String get businessAddressLabel => 'Dirección (opcional)';

  @override
  String get businessPhoneLabel => 'Teléfono (opcional)';

  @override
  String get businessEmailLabel => 'Correo electrónico (opcional)';

  @override
  String get businessWebsiteLabel => 'Web (opcional)';

  @override
  String get businessScheduleLabel => 'Horario (opcional)';

  @override
  String get businessDescriptionEsLabel =>
      'Descripción en castellano (opcional)';

  @override
  String get businessDescriptionVaLabel =>
      'Descripción en valenciano (opcional)';

  @override
  String get businessActiveSwitchLabel => 'Comercio activo';

  @override
  String get businessCreatedMessage => 'Comercio creado';

  @override
  String get businessSavedMessage => 'Cambios guardados';

  @override
  String get businessPhotosTitle => 'Fotos';

  @override
  String get businessPhotosHelp =>
      'JPG, PNG o WebP. Máximo 5 MB por foto, puedes seleccionar varias a la vez.';

  @override
  String get businessPhotosPublishFirst =>
      'Guarda el comercio antes de añadir fotos.';

  @override
  String get businessPhotoAdd => 'Añadir fotos';

  @override
  String businessPhotoUploading(int current, int total) {
    return 'Subiendo foto $current de $total…';
  }

  @override
  String get businessPhotoUploadSuccess => 'Fotos añadidas correctamente.';

  @override
  String get businessPhotoTooLarge =>
      'Una de las fotos supera el máximo de 5 MB.';

  @override
  String get businessPhotoUnsupportedType =>
      'Una de las fotos no es un JPG, PNG o WebP válido.';

  @override
  String get businessPhotoInvalidFile =>
      'No se ha podido leer una de las fotos.';

  @override
  String get businessPhotoUploadError => 'No se ha podido subir alguna foto.';

  @override
  String get businessPhotoRetry => 'Reintentar subida';

  @override
  String get businessPhotoDeleteTitle => '¿Quitar esta foto?';

  @override
  String businessPhotoDeleteSemantic(int index) {
    return 'Quitar la foto $index';
  }

  @override
  String businessPhotoMoveLeftSemantic(int index) {
    return 'Mover la foto $index hacia atrás';
  }

  @override
  String businessPhotoMoveRightSemantic(int index) {
    return 'Mover la foto $index hacia delante';
  }

  @override
  String get socialConnectionsTooltip => 'Conexiones con redes sociales';

  @override
  String get socialConnectionsTitle => 'Conexiones con redes sociales';

  @override
  String get socialConnectionsSubtitle =>
      'Conecta las cuentas de Instagram y Facebook del ayuntamiento para publicar noticias también ahí.';

  @override
  String get socialPlatformInstagram => 'Instagram';

  @override
  String get socialPlatformFacebook => 'Facebook';

  @override
  String get socialConnect => 'Conectar';

  @override
  String get socialDisconnect => 'Desconectar';

  @override
  String get socialStatusConnected => 'Conectada';

  @override
  String get socialStatusExpired => 'Token caducado';

  @override
  String get socialStatusError => 'Con errores';

  @override
  String get socialStatusRevoked => 'Revocada';

  @override
  String get socialNotConnected => 'Sin conectar';

  @override
  String get socialDisconnectConfirmTitle => '¿Desconectar esta cuenta?';

  @override
  String get socialDisconnectConfirmBody =>
      'Dejará de publicarse contenido en este canal hasta que se vuelva a conectar.';

  @override
  String get socialOAuthSuccess => 'Cuenta conectada correctamente.';

  @override
  String get socialOAuthError =>
      'No se ha podido conectar la cuenta. Inténtalo de nuevo.';

  @override
  String get shareToInstagramLabel => 'Compartir en Instagram';

  @override
  String get shareToFacebookLabel => 'Compartir en Facebook';

  @override
  String get shareToChannelsHelp =>
      'La cuenta debe estar conectada desde Conexiones con redes sociales.';

  @override
  String get invalidNumber => 'Introduce un número válido';

  @override
  String get facilitiesTitle => 'Instalaciones';

  @override
  String get newFacility => 'Nueva instalación';

  @override
  String get noFacilitiesTitle => 'No hay instalaciones';

  @override
  String get noFacilitiesBody =>
      'Da de alta la primera instalación reservable de este municipio.';

  @override
  String get facilityInactiveLabel => 'Inactiva';

  @override
  String facilitySlotDurationLabel(int minutes) {
    return 'Franjas de $minutes minutos';
  }

  @override
  String get editorNewFacilityTitle => 'Nueva instalación';

  @override
  String get editorEditFacilityTitle => 'Editar instalación';

  @override
  String get facilityNameEsLabel => 'Nombre en castellano';

  @override
  String get facilityNameVaLabel => 'Nombre en valenciano (opcional)';

  @override
  String get facilityCategoryLabel => 'Categoría';

  @override
  String get facilityCategoryHint => 'Por ejemplo: Pádel, Tenis, Barbacoa';

  @override
  String get facilityDescriptionEsLabel =>
      'Descripción en castellano (opcional)';

  @override
  String get facilityDescriptionVaLabel =>
      'Descripción en valenciano (opcional)';

  @override
  String get facilitySlotDurationFieldLabel =>
      'Duración de cada franja (minutos)';

  @override
  String get facilityMaxAdvanceDaysLabel =>
      'Antelación máxima de reserva (días)';

  @override
  String get facilityOpeningHoursSectionTitle => 'Horario semanal';

  @override
  String get facilityOpeningHoursSectionHelp =>
      'Un único tramo por día. Los vecinos solo podrán reservar dentro de este horario.';

  @override
  String get facilityClosedLabel => 'Cerrado';

  @override
  String get facilityOpenLabel => 'Abierto';

  @override
  String get facilityOpenTimeLabel => 'Abre';

  @override
  String get facilityCloseTimeLabel => 'Cierra';

  @override
  String get facilityInvalidHours =>
      'Revisa el horario: la hora de apertura debe ser anterior a la de cierre, en formato HH:mm.';

  @override
  String get facilityDayMon => 'Lunes';

  @override
  String get facilityDayTue => 'Martes';

  @override
  String get facilityDayWed => 'Miércoles';

  @override
  String get facilityDayThu => 'Jueves';

  @override
  String get facilityDayFri => 'Viernes';

  @override
  String get facilityDaySat => 'Sábado';

  @override
  String get facilityDaySun => 'Domingo';

  @override
  String get facilityFeeNoteEsLabel =>
      'Nota de tarifa en castellano (opcional)';

  @override
  String get facilityFeeNoteVaLabel =>
      'Nota de tarifa en valenciano (opcional)';

  @override
  String get facilityFeeNoteHint =>
      'Texto informativo, por ejemplo: 3€/hora, se abona en el ayuntamiento';

  @override
  String get facilityActiveSwitchLabel => 'Instalación activa';

  @override
  String get facilityCreatedMessage => 'Instalación creada';

  @override
  String get facilitySavedMessage => 'Cambios guardados';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get reservationsFilterAll => 'Todas las instalaciones';

  @override
  String get noReservationsTitle => 'No hay reservas';

  @override
  String get noReservationsBody =>
      'Las reservas que hagan los vecinos aparecerán aquí.';

  @override
  String get reservationCancelAction => 'Cancelar reserva';

  @override
  String get reservationCancelledMessage =>
      'Reserva cancelada. Se ha avisado al vecino.';

  @override
  String get reservationCancelDialogTitle => 'Cancelar esta reserva';

  @override
  String get reservationCancelDialogBody =>
      'El vecino recibirá un aviso con el motivo. Esta acción no se puede deshacer.';

  @override
  String get reservationCancelNoteLabel => 'Motivo de la cancelación';

  @override
  String get reservationCancelConfirmAction => 'Cancelar reserva';
}
