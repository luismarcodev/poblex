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
  String get backofficeTitle => 'Gestió municipal';

  @override
  String get loginTitle => 'Accés de gestors';

  @override
  String get loginSubtitle => 'Entra amb el compte facilitat per Poblex.';

  @override
  String get emailLabel => 'Correu electrònic';

  @override
  String get invalidEmail => 'Introdueix un correu electrònic vàlid';

  @override
  String get passwordLabel => 'Contrasenya';

  @override
  String get showPassword => 'Mostrar contrasenya';

  @override
  String get hidePassword => 'Ocultar contrasenya';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginError =>
      'No hem pogut iniciar la sessió. Revisa les dades i torna-ho a provar.';

  @override
  String get forgotPasswordLink => 'He oblidat la contrasenya';

  @override
  String get forgotPasswordTitle => 'Recuperar la contrasenya';

  @override
  String get forgotPasswordSubtitle =>
      'Introdueix el correu i t\'enviarem un enllaç per a crear una contrasenya nova.';

  @override
  String get sendResetLinkButton => 'Enviar l\'enllaç';

  @override
  String get resetEmailSentTitle => 'Revisa el correu';

  @override
  String get resetEmailSentMessage =>
      'Si existeix un compte amb eixe correu, rebràs un enllaç de recuperació. Pot tardar uns minuts.';

  @override
  String get backToLoginButton => 'Tornar a l\'accés';

  @override
  String get resetPasswordTitle => 'Crear una contrasenya nova';

  @override
  String get resetPasswordSubtitle =>
      'La contrasenya ha de tindre almenys 8 caràcters.';

  @override
  String get newPasswordLabel => 'Contrasenya nova';

  @override
  String get confirmPasswordLabel => 'Repeteix la contrasenya';

  @override
  String get passwordMinLength =>
      'La contrasenya ha de tindre almenys 8 caràcters';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get resetPasswordButton => 'Guardar la contrasenya';

  @override
  String get passwordResetSuccessTitle => 'Contrasenya actualitzada';

  @override
  String get passwordResetSuccessMessage =>
      'Ja pots entrar amb la contrasenya nova.';

  @override
  String get invalidOrExpiredResetLink =>
      'L\'enllaç de recuperació no és vàlid o ha caducat.';

  @override
  String get loading => 'Carregant';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get logout => 'Tancar la sessió';

  @override
  String get newsTitle => 'Notícies';

  @override
  String get newNews => 'Notícia nova';

  @override
  String get municipalityLabel => 'Municipi';

  @override
  String get includeArchived => 'Mostrar arxivades';

  @override
  String get noNewsTitle => 'No hi ha notícies';

  @override
  String get noNewsBody => 'Publica la primera notícia per a este municipi.';

  @override
  String get loadMore => 'Carregar-ne més';

  @override
  String get edit => 'Editar';

  @override
  String get pin => 'Destacar';

  @override
  String get unpin => 'Llevar destacat';

  @override
  String get pinConfirmTitle => 'Vols destacar esta notícia?';

  @override
  String get pinConfirmBody =>
      'Es mostrarà immediatament a dalt de tot per a tots els veïns del municipi.';

  @override
  String get archive => 'Arxivar';

  @override
  String get restore => 'Restaurar';

  @override
  String get delete => 'Esborrar';

  @override
  String get deleteTitle => 'Vols esborrar esta notícia?';

  @override
  String get deleteBody => 'Esta acció no es pot desfer.';

  @override
  String get confirmDelete => 'Sí, esborrar';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get editorNewTitle => 'Notícia nova';

  @override
  String get editorEditTitle => 'Editar notícia';

  @override
  String get titleSpanish => 'Títol en castellà';

  @override
  String get titleValencian => 'Títol en valencià (opcional)';

  @override
  String get bodySpanish => 'Contingut en castellà';

  @override
  String get bodyValencian => 'Contingut en valencià (opcional)';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryHint => 'Per exemple: general, cultura, obres';

  @override
  String get imageUrlLabel => 'URL d\'imatge (opcional)';

  @override
  String get publishMunicipalities => 'Municipis on publicar';

  @override
  String get pinnedLabel => 'Publicar com a destacada';

  @override
  String get saveChanges => 'Guardar els canvis';

  @override
  String get publish => 'Publicar notícia';

  @override
  String get requiredField => 'Este camp és obligatori';

  @override
  String get invalidCategory => 'Usa minúscules, números i guionets';

  @override
  String get invalidUrl =>
      'Introdueix una URL vàlida que comence per http:// o https://';

  @override
  String get savedMessage => 'Canvis guardats';

  @override
  String get publishedMessage => 'Notícia publicada';

  @override
  String get newsAttachmentsTitle => 'Adjunts';

  @override
  String get newsAttachmentsHelp => 'PDF, JPG, PNG o WebP. Màxim 5 MB.';

  @override
  String get newsAttachmentAdd => 'Afegir adjunt';

  @override
  String get newsAttachmentUploading => 'Pujant l\'adjunt…';

  @override
  String get newsAttachmentPublishFirst =>
      'Publica la notícia abans d\'afegir adjunts.';

  @override
  String get newsAttachmentUploadSuccess => 'Adjunt afegit correctament.';

  @override
  String get newsAttachmentTooLarge => 'L\'arxiu supera el màxim de 5 MB.';

  @override
  String get newsAttachmentUnsupportedType =>
      'L\'arxiu no és un PDF, JPG, PNG o WebP vàlid.';

  @override
  String get newsAttachmentInvalidFile => 'No s\'ha pogut llegir l\'arxiu.';

  @override
  String get newsAttachmentUploadError => 'No s\'ha pogut pujar l\'adjunt.';

  @override
  String get newsAttachmentRetry => 'Tornar a intentar la pujada';

  @override
  String newsAttachmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adjunts',
      one: '1 adjunt',
    );
    return '$_temp0';
  }

  @override
  String get eventsTitle => 'Esdeveniments';

  @override
  String get newEvent => 'Esdeveniment nou';

  @override
  String get includePastEvents => 'Mostrar esdeveniments passats';

  @override
  String get noEventsTitle => 'No hi ha esdeveniments';

  @override
  String get noEventsBody =>
      'Publica el primer esdeveniment per a este municipi.';

  @override
  String get eventUpcomingStatus => 'Pròxim';

  @override
  String get eventOngoingStatus => 'En curs';

  @override
  String get eventPastStatus => 'Finalitzat';

  @override
  String eventStartsOn(String date) {
    return 'Comença el $date';
  }

  @override
  String eventEndsOn(String date) {
    return 'Acaba el $date';
  }

  @override
  String get deleteEventTitle => 'Vols esborrar este esdeveniment?';

  @override
  String get deleteEventBody => 'Esta acció no es pot desfer.';

  @override
  String get eventEditorNewTitle => 'Esdeveniment nou';

  @override
  String get eventEditorEditTitle => 'Editar esdeveniment';

  @override
  String get eventDescriptionSpanish => 'Descripció en castellà';

  @override
  String get eventDescriptionValencian => 'Descripció en valencià (opcional)';

  @override
  String get eventStartLabel => 'Inici';

  @override
  String get eventEndLabel => 'Final';

  @override
  String get eventChangeDate => 'Canviar data i hora';

  @override
  String get eventSetEndDate => 'Afegir data de finalització';

  @override
  String get eventRemoveEndDate => 'Llevar data de finalització';

  @override
  String get eventLocationLabel => 'Lloc';

  @override
  String get eventLatitudeLabel => 'Latitud (opcional)';

  @override
  String get eventLongitudeLabel => 'Longitud (opcional)';

  @override
  String get eventCoordinatePairRequired =>
      'Introdueix les dos coordenades o deixa-les buides';

  @override
  String get invalidLatitude => 'Introdueix una latitud entre -90 i 90';

  @override
  String get invalidLongitude => 'Introdueix una longitud entre -180 i 180';

  @override
  String get eventEndBeforeStart =>
      'La data de finalització no pot ser anterior a l\'inici';

  @override
  String get publishEvent => 'Publicar esdeveniment';

  @override
  String get eventPublishedMessage => 'Esdeveniment publicat';

  @override
  String get incidentsTitle => 'Incidències';

  @override
  String get incidentFiltersTitle => 'Filtres d\'incidències';

  @override
  String get incidentStatusLabel => 'Estat';

  @override
  String get incidentStatusAll => 'Tots els estats';

  @override
  String get incidentStatusReceived => 'Rebuda';

  @override
  String get incidentStatusInProgress => 'En tramitació';

  @override
  String get incidentStatusResolved => 'Resolta';

  @override
  String get incidentCategoryAll => 'Totes les categories';

  @override
  String get incidentCategoryHint => 'Categoria';

  @override
  String get applyFilters => 'Aplicar els filtres';

  @override
  String get clearFilters => 'Netejar els filtres';

  @override
  String get noIncidentsTitle => 'No hi ha incidències';

  @override
  String get noIncidentsBody =>
      'No hi ha incidències que coincidisquen amb els filtres seleccionats.';

  @override
  String incidentReportedOn(String date) {
    return 'Comunicada el $date';
  }

  @override
  String incidentUpdatedOn(String date) {
    return 'Actualitzada el $date';
  }

  @override
  String get incidentOpenDetails => 'Veure el detall de la incidència';

  @override
  String get incidentDetailTitle => 'Detall de la incidència';

  @override
  String get incidentDescriptionTitle => 'Descripció';

  @override
  String get incidentPhotoTitle => 'Fotografia';

  @override
  String get incidentPhotoSemanticLabel => 'Fotografia adjunta a la incidència';

  @override
  String get incidentLocationTitle => 'Ubicació';

  @override
  String incidentCoordinates(String lat, String lng) {
    return 'Latitud $lat, longitud $lng';
  }

  @override
  String get incidentHistoryTitle => 'Historial de canvis';

  @override
  String get incidentHistoryEmpty =>
      'Encara no hi ha canvis d\'estat registrats.';

  @override
  String get incidentStatusChangeTitle => 'Canviar l\'estat';

  @override
  String get incidentNewStatusLabel => 'Estat nou';

  @override
  String get incidentNoteLabel => 'Nota interna';

  @override
  String get incidentNoteHint => 'Explica breument el motiu del canvi';

  @override
  String get incidentNoteMaxLength =>
      'La nota no pot superar els 1.000 caràcters';

  @override
  String get incidentSaveStatus => 'Guardar l\'estat';

  @override
  String get incidentStatusSaved => 'Estat actualitzat';

  @override
  String get incidentInvalidTransition => 'Este canvi d\'estat no està permés.';

  @override
  String get close => 'Tancar';

  @override
  String get surveysTitle => 'Enquestes';

  @override
  String get surveysNonBindingLabel => 'Enquestes no vinculants';

  @override
  String get surveysNonBindingExplanation =>
      'Els resultats són orientatius i no verifiquen l\'empadronament de qui vota.';

  @override
  String get includeClosedSurveys => 'Mostrar enquestes tancades';

  @override
  String get newSurvey => 'Enquesta nova';

  @override
  String get noSurveysTitle => 'No hi ha enquestes';

  @override
  String get noSurveysBody =>
      'Publica la primera enquesta per a este municipi.';

  @override
  String get surveyOpenStatus => 'Oberta';

  @override
  String get surveyClosedStatus => 'Tancada';

  @override
  String surveyClosesOn(String date) {
    return 'Tanca el $date';
  }

  @override
  String surveyClosedOn(String date) {
    return 'Tancada el $date';
  }

  @override
  String surveyOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opcions',
      one: '1 opció',
    );
    return '$_temp0';
  }

  @override
  String get surveyViewResults => 'Veure els resultats';

  @override
  String get surveyClose => 'Tancar l\'enquesta';

  @override
  String get surveyCloseTitle => 'Vols tancar esta enquesta?';

  @override
  String get surveyCloseBody => 'Després de tancar-la no admetrà més vots.';

  @override
  String get surveyResultsTitle => 'Resultats';

  @override
  String get surveyResultsHidden => 'Els resultats estan ocults per als veïns.';

  @override
  String get surveyShowResults => 'Mostrar els resultats als veïns';

  @override
  String get surveyHideResults => 'Ocultar els resultats als veïns';

  @override
  String surveyVotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vots',
      one: '1 vot',
    );
    return '$_temp0';
  }

  @override
  String surveyTotalVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vots totals',
      one: '1 vot total',
    );
    return '$_temp0';
  }

  @override
  String get surveyExportCsv => 'Exportar CSV';

  @override
  String get surveyCsvDownloaded => 'CSV descarregat';

  @override
  String get surveyCreatedMessage => 'Enquesta publicada';

  @override
  String get surveyCreateTitle => 'Enquesta nova';

  @override
  String get surveyQuestionSpanish => 'Pregunta en castellà';

  @override
  String get surveyQuestionValencian => 'Pregunta en valencià (opcional)';

  @override
  String get surveyOptionsTitle => 'Opcions de resposta';

  @override
  String surveyOptionSpanish(int number) {
    return 'Opció $number en castellà';
  }

  @override
  String surveyOptionValencian(int number) {
    return 'Opció $number en valencià (opcional)';
  }

  @override
  String get surveyAddOption => 'Afegir opció';

  @override
  String surveyRemoveOption(int number) {
    return 'Eliminar l\'opció $number';
  }

  @override
  String get surveyMinimumOptions => 'Afig almenys dos opcions';

  @override
  String get surveyClosingDate => 'Data de tancament';

  @override
  String get surveyChangeClosingDate => 'Canviar la data de tancament';

  @override
  String get surveyResultsVisibleFromStart =>
      'Mostrar els resultats des del principi';

  @override
  String get publishSurvey => 'Publicar l\'enquesta';

  @override
  String get surveyFutureClosingRequired =>
      'La data de tancament ha de ser posterior a l\'actual';

  @override
  String get deleteSurveyTitle => 'Vols esborrar esta enquesta?';

  @override
  String get deleteSurveyBody =>
      'També s\'esborraran les opcions i els vots. Esta acció no es pot desfer.';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get newAlert => 'Alerta nova';

  @override
  String get includeExpiredAlerts => 'Mostrar alertes finalitzades';

  @override
  String get noAlertsTitle => 'No hi ha alertes';

  @override
  String get noAlertsBody => 'No hi ha alertes per a este municipi.';

  @override
  String get alertSourceManual => 'Manual';

  @override
  String get alertSourceAemet => 'AEMET';

  @override
  String get alertStatusScheduled => 'Programada';

  @override
  String get alertStatusActive => 'Activa';

  @override
  String get alertStatusExpired => 'Finalitzada';

  @override
  String get alertSeverityYellow => 'Avís groc · Nivell 1';

  @override
  String get alertSeverityOrange => 'Avís taronja · Nivell 2';

  @override
  String get alertSeverityRed => 'Avís roig · Nivell 3';

  @override
  String alertStartsAt(String date) {
    return 'Comença el $date';
  }

  @override
  String alertEndsAt(String date) {
    return 'Acaba el $date';
  }

  @override
  String get alertWithoutEnd => 'Sense data de finalització';

  @override
  String alertCardSemantics(String severity, String phenomenon) {
    return '$severity. $phenomenon';
  }

  @override
  String alertCreatedBy(String manager) {
    return 'Creada per $manager';
  }

  @override
  String alertUpdatedBy(String manager) {
    return 'Actualitzada per $manager';
  }

  @override
  String get deleteAlertTitle => 'Vols esborrar esta alerta?';

  @override
  String get deleteAlertBody => 'Esta acció no es pot desfer.';

  @override
  String get alertEditorNewTitle => 'Alerta manual nova';

  @override
  String get alertEditorEditTitle => 'Editar l\'alerta manual';

  @override
  String get alertPhenomenonLabel => 'Fenomen o motiu';

  @override
  String get alertPhenomenonTypeField => 'Tipus de fenomen';

  @override
  String get alertPhenomenonTypeIncendio => 'Incendi';

  @override
  String get alertPhenomenonTypeEvacuacion => 'Evacuació';

  @override
  String get alertPhenomenonTypeSanitario => 'Sanitari';

  @override
  String get alertPhenomenonTypeMeteorologico => 'Meteorològic';

  @override
  String get alertPhenomenonTypeOtro => 'Altre';

  @override
  String get alertSeverityField => 'Nivell de l\'avís';

  @override
  String get alertBodySpanish => 'Missatge en castellà';

  @override
  String get alertBodyValencian => 'Missatge en valencià (opcional)';

  @override
  String get chooseDateTime => 'Triar data';

  @override
  String get alertStartField => 'Inici';

  @override
  String get alertEndField => 'Final';

  @override
  String get clearAlertEnd => 'Llevar la data de finalització';

  @override
  String get publishAlert => 'Publicar l\'alerta';

  @override
  String get alertPublishedMessage => 'Alerta publicada';

  @override
  String get alertEndBeforeStart =>
      'La data de finalització no pot ser anterior a l\'inici';

  @override
  String get alertRedPushWarning =>
      'Les alertes roges enviaran una notificació obligatòria als veïns del municipi.';

  @override
  String get alertAemetReadOnly =>
      'Les alertes procedents d\'AEMET són només de lectura i no es poden modificar des del panell.';

  @override
  String get pharmaciesTitle => 'Farmàcies de guàrdia';

  @override
  String get pharmaciesSubtitle =>
      'Càrrega manual de les guàrdies del municipi';

  @override
  String get newDutyPharmacy => 'Afegir guàrdia';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes següent';

  @override
  String get currentMonth => 'Mes actual';

  @override
  String get noDutyPharmaciesTitle => 'No hi ha guàrdies carregades';

  @override
  String get noDutyPharmaciesBody =>
      'Afig les farmàcies de guàrdia per a este mes.';

  @override
  String get dutyPharmacyDateLabel => 'Data de guàrdia';

  @override
  String get dutyPharmacyNameLabel => 'Nom de la farmàcia';

  @override
  String get dutyPharmacyAddressLabel => 'Adreça';

  @override
  String get dutyPharmacyPhoneLabel => 'Telèfon';

  @override
  String get dutyPharmacyScheduleLabel => 'Horari';

  @override
  String get editDutyPharmacy => 'Editar la guàrdia';

  @override
  String get dutyPharmacyEditorNewTitle => 'Nova farmàcia de guàrdia';

  @override
  String get dutyPharmacyEditorEditTitle => 'Editar la farmàcia de guàrdia';

  @override
  String get saveDutyPharmacy => 'Guardar la guàrdia';

  @override
  String get dutyPharmacySavedMessage => 'Farmàcia de guàrdia guardada';

  @override
  String get dutyPharmacyDateExists =>
      'Ja existeix una farmàcia de guàrdia per a eixa data. Pots editar-la des del llistat.';

  @override
  String get selectDutyPharmacyDate => 'Seleccionar la data de guàrdia';

  @override
  String get formsTitle => 'Formularis';

  @override
  String get newForm => 'Formulari nou';

  @override
  String get includeClosedForms => 'Mostrar formularis tancats';

  @override
  String get formsEmpty => 'No hi ha formularis per a este municipi.';

  @override
  String get formOpenStatus => 'Obert';

  @override
  String get formClosedStatus => 'Tancat';

  @override
  String get formNoDeadline => 'Sense data límit';

  @override
  String formDeadline(String date) {
    return 'Data límit: $date';
  }

  @override
  String formFieldsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count camps',
      one: '1 camp',
    );
    return '$_temp0';
  }

  @override
  String get formNoEditNote =>
      'No es pot editar una vegada creat, per no alterar les respostes ja enviades. Pots tancar-lo o esborrar-lo.';

  @override
  String get formExportSubmissions => 'Exportar respostes CSV';

  @override
  String get formExportSuccess => 'Respostes descarregades';

  @override
  String get formExportUnsupported =>
      'La descàrrega només està disponible en la versió web del panell.';

  @override
  String get formDeleteTitle => 'Vols esborrar este formulari?';

  @override
  String get formDeleteBody =>
      'També s\'esborraran totes les respostes. Esta acció no es pot desfer.';

  @override
  String get formCreateTitle => 'Formulari nou';

  @override
  String get formTitleSpanish => 'Títol en castellà';

  @override
  String get formTitleValencian => 'Títol en valencià (opcional)';

  @override
  String get formDescriptionSpanish => 'Descripció en castellà';

  @override
  String get formDescriptionValencian => 'Descripció en valencià (opcional)';

  @override
  String get formOptionalDeadline => 'Data límit (opcional)';

  @override
  String get formChooseDeadline => 'Triar la data límit';

  @override
  String get formClearDeadline => 'Llevar la data límit';

  @override
  String get formFieldsTitle => 'Camps del formulari';

  @override
  String formFieldNumber(int number) {
    return 'Camp $number';
  }

  @override
  String get formFieldKey => 'Identificador intern';

  @override
  String get formFieldKeyHint => 'Per exemple: nom_complet';

  @override
  String get formFieldLabelSpanish => 'Etiqueta en castellà';

  @override
  String get formFieldLabelValencian => 'Etiqueta en valencià (opcional)';

  @override
  String get formFieldType => 'Tipus de camp';

  @override
  String get formFieldRequired => 'Resposta obligatòria';

  @override
  String get formFieldOptions => 'Opcions';

  @override
  String get formFieldOptionsHint => 'Una opció per línia';

  @override
  String get formAddField => 'Afegir camp';

  @override
  String get formRemoveField => 'Eliminar el camp';

  @override
  String get formMoveFieldUp => 'Pujar el camp';

  @override
  String get formMoveFieldDown => 'Baixar el camp';

  @override
  String get formCreated => 'Formulari publicat';

  @override
  String get formInvalidFieldKey =>
      'Usa minúscules, números i guions baixos, sense espais';

  @override
  String get formSelectNeedsOptions =>
      'Afig almenys dos opcions per al camp de selecció';

  @override
  String get formDuplicateFieldKeys =>
      'Cada camp ha de tindre un identificador intern diferent';

  @override
  String get formFutureDeadline =>
      'La data límit ha de ser posterior a l\'actual';

  @override
  String get formFieldTypeText => 'Text';

  @override
  String get formFieldTypeNumber => 'Número';

  @override
  String get formFieldTypeSelect => 'Selecció';

  @override
  String get formFieldTypeDate => 'Data';

  @override
  String get formFieldTypeBoolean => 'Sí o no';

  @override
  String get genericError => 'Alguna cosa ha fallat. Torna-ho a provar.';

  @override
  String get networkError => 'No es pot connectar amb el servidor.';

  @override
  String get unauthorizedError => 'La sessió ha caducat. Torna a entrar.';

  @override
  String get archivedLabel => 'Arxivada';

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
      'Este compte no té municipis assignats.';

  @override
  String get openMenu => 'Obrir menú';

  @override
  String get closeMenu => 'Tancar menú';

  @override
  String get businessesTitle => 'Comerços';

  @override
  String get newBusiness => 'Nou comerç';

  @override
  String get includeInactiveBusinesses => 'Mostrar inactius';

  @override
  String get noBusinessesTitle => 'No hi ha comerços';

  @override
  String get noBusinessesBody =>
      'Dona d\'alta el primer comerç d\'este municipi.';

  @override
  String get businessInactiveLabel => 'Inactiu';

  @override
  String get deleteBusinessTitle => 'Vols esborrar este comerç?';

  @override
  String get deleteBusinessBody => 'Esta acció no es pot desfer.';

  @override
  String get activate => 'Activar';

  @override
  String get deactivate => 'Desactivar';

  @override
  String get editorNewBusinessTitle => 'Nou comerç';

  @override
  String get editorEditBusinessTitle => 'Editar comerç';

  @override
  String get businessNameLabel => 'Nom';

  @override
  String get businessCategoryLabel => 'Categoria';

  @override
  String get businessCategoryHint =>
      'Per exemple: bar, alimentacio, perruqueria';

  @override
  String get businessAddressLabel => 'Adreça (opcional)';

  @override
  String get businessPhoneLabel => 'Telèfon (opcional)';

  @override
  String get businessEmailLabel => 'Correu electrònic (opcional)';

  @override
  String get businessWebsiteLabel => 'Web (opcional)';

  @override
  String get businessScheduleLabel => 'Horari (opcional)';

  @override
  String get businessDescriptionEsLabel => 'Descripció en castellà (opcional)';

  @override
  String get businessDescriptionVaLabel => 'Descripció en valencià (opcional)';

  @override
  String get businessActiveSwitchLabel => 'Comerç actiu';

  @override
  String get businessCreatedMessage => 'Comerç creat';

  @override
  String get businessSavedMessage => 'Canvis guardats';

  @override
  String get businessPhotosTitle => 'Fotos';

  @override
  String get businessPhotosHelp =>
      'JPG, PNG o WebP. Màxim 5 MB per foto, pots seleccionar-ne diverses alhora.';

  @override
  String get businessPhotosPublishFirst =>
      'Guarda el comerç abans d\'afegir fotos.';

  @override
  String get businessPhotoAdd => 'Afegir fotos';

  @override
  String businessPhotoUploading(int current, int total) {
    return 'Pujant foto $current de $total…';
  }

  @override
  String get businessPhotoUploadSuccess => 'Fotos afegides correctament.';

  @override
  String get businessPhotoTooLarge =>
      'Una de les fotos supera el màxim de 5 MB.';

  @override
  String get businessPhotoUnsupportedType =>
      'Una de les fotos no és un JPG, PNG o WebP vàlid.';

  @override
  String get businessPhotoInvalidFile =>
      'No s\'ha pogut llegir una de les fotos.';

  @override
  String get businessPhotoUploadError => 'No s\'ha pogut pujar alguna foto.';

  @override
  String get businessPhotoRetry => 'Reintentar pujada';

  @override
  String get businessPhotoDeleteTitle => 'Vols llevar esta foto?';

  @override
  String businessPhotoDeleteSemantic(int index) {
    return 'Llevar la foto $index';
  }

  @override
  String businessPhotoMoveLeftSemantic(int index) {
    return 'Moure la foto $index cap arrere';
  }

  @override
  String businessPhotoMoveRightSemantic(int index) {
    return 'Moure la foto $index cap avant';
  }

  @override
  String get socialConnectionsShortLabel => 'Xarxes socials';

  @override
  String get socialConnectionsTitle => 'Connexions amb xarxes socials';

  @override
  String get socialConnectionsSubtitle =>
      'Connecta els comptes d\'Instagram i Facebook de l\'ajuntament per a publicar notícies també ahí.';

  @override
  String get socialPlatformInstagram => 'Instagram';

  @override
  String get socialPlatformFacebook => 'Facebook';

  @override
  String get socialConnect => 'Connectar';

  @override
  String get socialDisconnect => 'Desconnectar';

  @override
  String get socialStatusConnected => 'Connectada';

  @override
  String get socialStatusExpired => 'Token caducat';

  @override
  String get socialStatusError => 'Amb errors';

  @override
  String get socialStatusRevoked => 'Revocada';

  @override
  String get socialNotConnected => 'Sense connectar';

  @override
  String get socialDisconnectConfirmTitle => 'Vols desconnectar este compte?';

  @override
  String get socialDisconnectConfirmBody =>
      'Deixarà de publicar-se contingut en este canal fins que es torne a connectar.';

  @override
  String get socialOAuthSuccess => 'Compte connectat correctament.';

  @override
  String get socialOAuthError =>
      'No s\'ha pogut connectar el compte. Torna-ho a intentar.';

  @override
  String get shareToInstagramLabel => 'Compartir en Instagram';

  @override
  String get shareToFacebookLabel => 'Compartir en Facebook';

  @override
  String get shareToChannelsHelp =>
      'El compte ha d\'estar connectat des de Connexions amb xarxes socials.';

  @override
  String get invalidNumber => 'Introdueix un número vàlid';

  @override
  String get facilitiesTitle => 'Instal·lacions';

  @override
  String get newFacility => 'Nova instal·lació';

  @override
  String get noFacilitiesTitle => 'No hi ha instal·lacions';

  @override
  String get noFacilitiesBody =>
      'Dona d\'alta la primera instal·lació reservable d\'este municipi.';

  @override
  String get facilityInactiveLabel => 'Inactiva';

  @override
  String facilitySlotDurationLabel(int minutes) {
    return 'Franges de $minutes minuts';
  }

  @override
  String get editorNewFacilityTitle => 'Nova instal·lació';

  @override
  String get editorEditFacilityTitle => 'Editar instal·lació';

  @override
  String get facilityNameEsLabel => 'Nom en castellà';

  @override
  String get facilityNameVaLabel => 'Nom en valencià (opcional)';

  @override
  String get facilityCategoryLabel => 'Categoria';

  @override
  String get facilityCategoryHint => 'Per exemple: Pàdel, Tennis, Barbacoa';

  @override
  String get facilityDescriptionEsLabel => 'Descripció en castellà (opcional)';

  @override
  String get facilityDescriptionVaLabel => 'Descripció en valencià (opcional)';

  @override
  String get facilitySlotDurationFieldLabel =>
      'Duració de cada franja (minuts)';

  @override
  String get facilityMaxAdvanceDaysLabel =>
      'Antelació màxima de reserva (dies)';

  @override
  String get facilityOpeningHoursSectionTitle => 'Horari setmanal';

  @override
  String get facilityOpeningHoursSectionHelp =>
      'Un únic tram per dia. Els veïns només podran reservar dins d\'este horari.';

  @override
  String get facilityClosedLabel => 'Tancat';

  @override
  String get facilityOpenLabel => 'Obert';

  @override
  String get facilityOpenTimeLabel => 'Obri';

  @override
  String get facilityCloseTimeLabel => 'Tanca';

  @override
  String facilityInvalidHoursForDay(String day) {
    return 'Revisa l\'horari del $day: l\'hora d\'obertura ha de ser anterior a la de tancament.';
  }

  @override
  String get facilityDayMon => 'Dilluns';

  @override
  String get facilityDayTue => 'Dimarts';

  @override
  String get facilityDayWed => 'Dimecres';

  @override
  String get facilityDayThu => 'Dijous';

  @override
  String get facilityDayFri => 'Divendres';

  @override
  String get facilityDaySat => 'Dissabte';

  @override
  String get facilityDaySun => 'Diumenge';

  @override
  String get facilityFeeNoteEsLabel => 'Nota de tarifa en castellà (opcional)';

  @override
  String get facilityFeeNoteVaLabel => 'Nota de tarifa en valencià (opcional)';

  @override
  String get facilityFeeNoteHint =>
      'Text informatiu, per exemple: 3€/hora, s\'abona a l\'ajuntament';

  @override
  String get facilityActiveSwitchLabel => 'Instal·lació activa';

  @override
  String get facilityCreatedMessage => 'Instal·lació creada';

  @override
  String get facilitySavedMessage => 'Canvis guardats';

  @override
  String get reservationsTitle => 'Reserves';

  @override
  String get reservationsFilterAll => 'Totes les instal·lacions';

  @override
  String get noReservationsTitle => 'No hi ha reserves';

  @override
  String get noReservationsBody =>
      'Les reserves que facen els veïns apareixeran ací.';

  @override
  String get reservationCancelAction => 'Cancel·lar reserva';

  @override
  String get reservationCancelledMessage =>
      'Reserva cancel·lada. S\'ha avisat al veí.';

  @override
  String get reservationCancelDialogTitle => 'Cancel·lar esta reserva';

  @override
  String get reservationCancelDialogBody =>
      'El veí rebrà un avís amb el motiu. Esta acció no es pot desfer.';

  @override
  String get reservationCancelNoteLabel => 'Motiu de la cancel·lació';

  @override
  String get reservationCancelConfirmAction => 'Cancel·lar reserva';
}
