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

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Poblex'**
  String get appName;

  /// No description provided for @backofficeTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión municipal'**
  String get backofficeTitle;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso de gestores'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entra con la cuenta facilitada por Poblex.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo electrónico válido'**
  String get invalidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido iniciar sesión. Revisa tus datos e inténtalo de nuevo.'**
  String get loginError;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In es, this message translates to:
  /// **'He olvidado mi contraseña'**
  String get forgotPasswordLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu correo y te enviaremos un enlace para crear una contraseña nueva.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get sendResetLinkButton;

  /// No description provided for @resetEmailSentTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get resetEmailSentTitle;

  /// No description provided for @resetEmailSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Si existe una cuenta con ese correo, recibirás un enlace de recuperación. Puede tardar unos minutos.'**
  String get resetEmailSentMessage;

  /// No description provided for @backToLoginButton.
  ///
  /// In es, this message translates to:
  /// **'Volver al acceso'**
  String get backToLoginButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear una contraseña nueva'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPasswordButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get passwordResetSuccessTitle;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya puedes entrar con tu nueva contraseña.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @invalidOrExpiredResetLink.
  ///
  /// In es, this message translates to:
  /// **'El enlace de recuperación no es válido o ha caducado.'**
  String get invalidOrExpiredResetLink;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @newsTitle.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get newsTitle;

  /// No description provided for @newNews.
  ///
  /// In es, this message translates to:
  /// **'Nueva noticia'**
  String get newNews;

  /// No description provided for @municipalityLabel.
  ///
  /// In es, this message translates to:
  /// **'Municipio'**
  String get municipalityLabel;

  /// No description provided for @includeArchived.
  ///
  /// In es, this message translates to:
  /// **'Mostrar archivadas'**
  String get includeArchived;

  /// No description provided for @noNewsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay noticias'**
  String get noNewsTitle;

  /// No description provided for @noNewsBody.
  ///
  /// In es, this message translates to:
  /// **'Publica la primera noticia para este municipio.'**
  String get noNewsBody;

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @pin.
  ///
  /// In es, this message translates to:
  /// **'Destacar'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In es, this message translates to:
  /// **'Quitar destacado'**
  String get unpin;

  /// No description provided for @archive.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get delete;

  /// No description provided for @deleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta noticia?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get deleteBody;

  /// No description provided for @confirmDelete.
  ///
  /// In es, this message translates to:
  /// **'Sí, borrar'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @editorNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva noticia'**
  String get editorNewTitle;

  /// No description provided for @editorEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar noticia'**
  String get editorEditTitle;

  /// No description provided for @titleSpanish.
  ///
  /// In es, this message translates to:
  /// **'Título en castellano'**
  String get titleSpanish;

  /// No description provided for @titleValencian.
  ///
  /// In es, this message translates to:
  /// **'Título en valenciano (opcional)'**
  String get titleValencian;

  /// No description provided for @bodySpanish.
  ///
  /// In es, this message translates to:
  /// **'Contenido en castellano'**
  String get bodySpanish;

  /// No description provided for @bodyValencian.
  ///
  /// In es, this message translates to:
  /// **'Contenido en valenciano (opcional)'**
  String get bodyValencian;

  /// No description provided for @categoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryLabel;

  /// No description provided for @categoryHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: general, cultura, obras'**
  String get categoryHint;

  /// No description provided for @imageUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL de imagen (opcional)'**
  String get imageUrlLabel;

  /// No description provided for @publishMunicipalities.
  ///
  /// In es, this message translates to:
  /// **'Municipios donde publicar'**
  String get publishMunicipalities;

  /// No description provided for @pinnedLabel.
  ///
  /// In es, this message translates to:
  /// **'Publicar como destacada'**
  String get pinnedLabel;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @publish.
  ///
  /// In es, this message translates to:
  /// **'Publicar noticia'**
  String get publish;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get requiredField;

  /// No description provided for @invalidCategory.
  ///
  /// In es, this message translates to:
  /// **'Usa minúsculas, números y guiones medios'**
  String get invalidCategory;

  /// No description provided for @invalidUrl.
  ///
  /// In es, this message translates to:
  /// **'Introduce una URL válida que empiece por http:// o https://'**
  String get invalidUrl;

  /// No description provided for @savedMessage.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get savedMessage;

  /// No description provided for @publishedMessage.
  ///
  /// In es, this message translates to:
  /// **'Noticia publicada'**
  String get publishedMessage;

  /// No description provided for @newsAttachmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Adjuntos'**
  String get newsAttachmentsTitle;

  /// No description provided for @newsAttachmentsHelp.
  ///
  /// In es, this message translates to:
  /// **'PDF, JPG, PNG o WebP. Máximo 5 MB.'**
  String get newsAttachmentsHelp;

  /// No description provided for @newsAttachmentAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir adjunto'**
  String get newsAttachmentAdd;

  /// No description provided for @newsAttachmentUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo adjunto…'**
  String get newsAttachmentUploading;

  /// No description provided for @newsAttachmentPublishFirst.
  ///
  /// In es, this message translates to:
  /// **'Publica la noticia antes de añadir adjuntos.'**
  String get newsAttachmentPublishFirst;

  /// No description provided for @newsAttachmentUploadSuccess.
  ///
  /// In es, this message translates to:
  /// **'Adjunto añadido correctamente.'**
  String get newsAttachmentUploadSuccess;

  /// No description provided for @newsAttachmentTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El archivo supera el máximo de 5 MB.'**
  String get newsAttachmentTooLarge;

  /// No description provided for @newsAttachmentUnsupportedType.
  ///
  /// In es, this message translates to:
  /// **'El archivo no es un PDF, JPG, PNG o WebP válido.'**
  String get newsAttachmentUnsupportedType;

  /// No description provided for @newsAttachmentInvalidFile.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido leer el archivo.'**
  String get newsAttachmentInvalidFile;

  /// No description provided for @newsAttachmentUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido subir el adjunto.'**
  String get newsAttachmentUploadError;

  /// No description provided for @newsAttachmentRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar subida'**
  String get newsAttachmentRetry;

  /// No description provided for @newsAttachmentCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 adjunto} other{{count} adjuntos}}'**
  String newsAttachmentCount(int count);

  /// No description provided for @eventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get eventsTitle;

  /// No description provided for @newEvent.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento'**
  String get newEvent;

  /// No description provided for @includePastEvents.
  ///
  /// In es, this message translates to:
  /// **'Mostrar eventos pasados'**
  String get includePastEvents;

  /// No description provided for @noEventsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos'**
  String get noEventsTitle;

  /// No description provided for @noEventsBody.
  ///
  /// In es, this message translates to:
  /// **'Publica el primer evento para este municipio.'**
  String get noEventsBody;

  /// No description provided for @eventUpcomingStatus.
  ///
  /// In es, this message translates to:
  /// **'Próximo'**
  String get eventUpcomingStatus;

  /// No description provided for @eventOngoingStatus.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get eventOngoingStatus;

  /// No description provided for @eventPastStatus.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get eventPastStatus;

  /// No description provided for @eventStartsOn.
  ///
  /// In es, this message translates to:
  /// **'Empieza el {date}'**
  String eventStartsOn(String date);

  /// No description provided for @eventEndsOn.
  ///
  /// In es, this message translates to:
  /// **'Termina el {date}'**
  String eventEndsOn(String date);

  /// No description provided for @deleteEventTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar este evento?'**
  String get deleteEventTitle;

  /// No description provided for @deleteEventBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get deleteEventBody;

  /// No description provided for @eventEditorNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento'**
  String get eventEditorNewTitle;

  /// No description provided for @eventEditorEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar evento'**
  String get eventEditorEditTitle;

  /// No description provided for @eventDescriptionSpanish.
  ///
  /// In es, this message translates to:
  /// **'Descripción en castellano'**
  String get eventDescriptionSpanish;

  /// No description provided for @eventDescriptionValencian.
  ///
  /// In es, this message translates to:
  /// **'Descripción en valenciano (opcional)'**
  String get eventDescriptionValencian;

  /// No description provided for @eventStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get eventStartLabel;

  /// No description provided for @eventEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get eventEndLabel;

  /// No description provided for @eventChangeDate.
  ///
  /// In es, this message translates to:
  /// **'Cambiar fecha y hora'**
  String get eventChangeDate;

  /// No description provided for @eventSetEndDate.
  ///
  /// In es, this message translates to:
  /// **'Añadir fecha de fin'**
  String get eventSetEndDate;

  /// No description provided for @eventRemoveEndDate.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha de fin'**
  String get eventRemoveEndDate;

  /// No description provided for @eventLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get eventLocationLabel;

  /// No description provided for @eventLatitudeLabel.
  ///
  /// In es, this message translates to:
  /// **'Latitud (opcional)'**
  String get eventLatitudeLabel;

  /// No description provided for @eventLongitudeLabel.
  ///
  /// In es, this message translates to:
  /// **'Longitud (opcional)'**
  String get eventLongitudeLabel;

  /// No description provided for @eventCoordinatePairRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce las dos coordenadas o deja ambas vacías'**
  String get eventCoordinatePairRequired;

  /// No description provided for @invalidLatitude.
  ///
  /// In es, this message translates to:
  /// **'Introduce una latitud entre -90 y 90'**
  String get invalidLatitude;

  /// No description provided for @invalidLongitude.
  ///
  /// In es, this message translates to:
  /// **'Introduce una longitud entre -180 y 180'**
  String get invalidLongitude;

  /// No description provided for @eventEndBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior al inicio'**
  String get eventEndBeforeStart;

  /// No description provided for @publishEvent.
  ///
  /// In es, this message translates to:
  /// **'Publicar evento'**
  String get publishEvent;

  /// No description provided for @eventPublishedMessage.
  ///
  /// In es, this message translates to:
  /// **'Evento publicado'**
  String get eventPublishedMessage;

  /// No description provided for @incidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get incidentsTitle;

  /// No description provided for @incidentFiltersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros de incidencias'**
  String get incidentFiltersTitle;

  /// No description provided for @incidentStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get incidentStatusLabel;

  /// No description provided for @incidentStatusAll.
  ///
  /// In es, this message translates to:
  /// **'Todos los estados'**
  String get incidentStatusAll;

  /// No description provided for @incidentStatusReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get incidentStatusReceived;

  /// No description provided for @incidentStatusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En tramitación'**
  String get incidentStatusInProgress;

  /// No description provided for @incidentStatusResolved.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get incidentStatusResolved;

  /// No description provided for @incidentCategoryAll.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías'**
  String get incidentCategoryAll;

  /// No description provided for @incidentCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get incidentCategoryHint;

  /// No description provided for @applyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// No description provided for @noIncidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay incidencias'**
  String get noIncidentsTitle;

  /// No description provided for @noIncidentsBody.
  ///
  /// In es, this message translates to:
  /// **'No hay incidencias que coincidan con los filtros seleccionados.'**
  String get noIncidentsBody;

  /// No description provided for @incidentReportedOn.
  ///
  /// In es, this message translates to:
  /// **'Comunicada el {date}'**
  String incidentReportedOn(String date);

  /// No description provided for @incidentUpdatedOn.
  ///
  /// In es, this message translates to:
  /// **'Actualizada el {date}'**
  String incidentUpdatedOn(String date);

  /// No description provided for @incidentOpenDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle de la incidencia'**
  String get incidentOpenDetails;

  /// No description provided for @incidentDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de incidencia'**
  String get incidentDetailTitle;

  /// No description provided for @incidentDescriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get incidentDescriptionTitle;

  /// No description provided for @incidentPhotoTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotografía'**
  String get incidentPhotoTitle;

  /// No description provided for @incidentPhotoSemanticLabel.
  ///
  /// In es, this message translates to:
  /// **'Fotografía adjunta a la incidencia'**
  String get incidentPhotoSemanticLabel;

  /// No description provided for @incidentLocationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get incidentLocationTitle;

  /// No description provided for @incidentCoordinates.
  ///
  /// In es, this message translates to:
  /// **'Latitud {lat}, longitud {lng}'**
  String incidentCoordinates(String lat, String lng);

  /// No description provided for @incidentHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de cambios'**
  String get incidentHistoryTitle;

  /// No description provided for @incidentHistoryUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El historial detallado todavía no está disponible en este panel.'**
  String get incidentHistoryUnavailable;

  /// No description provided for @incidentStatusChangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get incidentStatusChangeTitle;

  /// No description provided for @incidentNewStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado nuevo'**
  String get incidentNewStatusLabel;

  /// No description provided for @incidentNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota interna'**
  String get incidentNoteLabel;

  /// No description provided for @incidentNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Explica brevemente el motivo del cambio'**
  String get incidentNoteHint;

  /// No description provided for @incidentNoteMaxLength.
  ///
  /// In es, this message translates to:
  /// **'La nota no puede superar los 1.000 caracteres'**
  String get incidentNoteMaxLength;

  /// No description provided for @incidentSaveStatus.
  ///
  /// In es, this message translates to:
  /// **'Guardar estado'**
  String get incidentSaveStatus;

  /// No description provided for @incidentStatusSaved.
  ///
  /// In es, this message translates to:
  /// **'Estado actualizado'**
  String get incidentStatusSaved;

  /// No description provided for @incidentInvalidTransition.
  ///
  /// In es, this message translates to:
  /// **'Ese cambio de estado no está permitido.'**
  String get incidentInvalidTransition;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @surveysTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuestas'**
  String get surveysTitle;

  /// No description provided for @surveysNonBindingLabel.
  ///
  /// In es, this message translates to:
  /// **'Encuestas no vinculantes'**
  String get surveysNonBindingLabel;

  /// No description provided for @surveysNonBindingExplanation.
  ///
  /// In es, this message translates to:
  /// **'Los resultados son orientativos y no verifican el empadronamiento de quien vota.'**
  String get surveysNonBindingExplanation;

  /// No description provided for @includeClosedSurveys.
  ///
  /// In es, this message translates to:
  /// **'Mostrar encuestas cerradas'**
  String get includeClosedSurveys;

  /// No description provided for @newSurvey.
  ///
  /// In es, this message translates to:
  /// **'Nueva encuesta'**
  String get newSurvey;

  /// No description provided for @noSurveysTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay encuestas'**
  String get noSurveysTitle;

  /// No description provided for @noSurveysBody.
  ///
  /// In es, this message translates to:
  /// **'Publica la primera encuesta para este municipio.'**
  String get noSurveysBody;

  /// No description provided for @surveyOpenStatus.
  ///
  /// In es, this message translates to:
  /// **'Abierta'**
  String get surveyOpenStatus;

  /// No description provided for @surveyClosedStatus.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get surveyClosedStatus;

  /// No description provided for @surveyClosesOn.
  ///
  /// In es, this message translates to:
  /// **'Cierra el {date}'**
  String surveyClosesOn(String date);

  /// No description provided for @surveyClosedOn.
  ///
  /// In es, this message translates to:
  /// **'Cerrada el {date}'**
  String surveyClosedOn(String date);

  /// No description provided for @surveyOptionsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 opción} other{{count} opciones}}'**
  String surveyOptionsCount(int count);

  /// No description provided for @surveyViewResults.
  ///
  /// In es, this message translates to:
  /// **'Ver resultados'**
  String get surveyViewResults;

  /// No description provided for @surveyClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar encuesta'**
  String get surveyClose;

  /// No description provided for @surveyCloseTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar esta encuesta?'**
  String get surveyCloseTitle;

  /// No description provided for @surveyCloseBody.
  ///
  /// In es, this message translates to:
  /// **'Después de cerrarla no admitirá más votos.'**
  String get surveyCloseBody;

  /// No description provided for @surveyResultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get surveyResultsTitle;

  /// No description provided for @surveyResultsHidden.
  ///
  /// In es, this message translates to:
  /// **'Los resultados están ocultos para los vecinos.'**
  String get surveyResultsHidden;

  /// No description provided for @surveyShowResults.
  ///
  /// In es, this message translates to:
  /// **'Mostrar resultados a los vecinos'**
  String get surveyShowResults;

  /// No description provided for @surveyHideResults.
  ///
  /// In es, this message translates to:
  /// **'Ocultar resultados a los vecinos'**
  String get surveyHideResults;

  /// No description provided for @surveyVotesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 voto} other{{count} votos}}'**
  String surveyVotesCount(int count);

  /// No description provided for @surveyTotalVotes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 voto total} other{{count} votos totales}}'**
  String surveyTotalVotes(int count);

  /// No description provided for @surveyExportCsv.
  ///
  /// In es, this message translates to:
  /// **'Exportar CSV'**
  String get surveyExportCsv;

  /// No description provided for @surveyCsvDownloaded.
  ///
  /// In es, this message translates to:
  /// **'CSV descargado'**
  String get surveyCsvDownloaded;

  /// No description provided for @surveyCreatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Encuesta publicada'**
  String get surveyCreatedMessage;

  /// No description provided for @surveyCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva encuesta'**
  String get surveyCreateTitle;

  /// No description provided for @surveyQuestionSpanish.
  ///
  /// In es, this message translates to:
  /// **'Pregunta en castellano'**
  String get surveyQuestionSpanish;

  /// No description provided for @surveyQuestionValencian.
  ///
  /// In es, this message translates to:
  /// **'Pregunta en valenciano (opcional)'**
  String get surveyQuestionValencian;

  /// No description provided for @surveyOptionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Opciones de respuesta'**
  String get surveyOptionsTitle;

  /// No description provided for @surveyOptionSpanish.
  ///
  /// In es, this message translates to:
  /// **'Opción {number} en castellano'**
  String surveyOptionSpanish(int number);

  /// No description provided for @surveyOptionValencian.
  ///
  /// In es, this message translates to:
  /// **'Opción {number} en valenciano (opcional)'**
  String surveyOptionValencian(int number);

  /// No description provided for @surveyAddOption.
  ///
  /// In es, this message translates to:
  /// **'Añadir opción'**
  String get surveyAddOption;

  /// No description provided for @surveyRemoveOption.
  ///
  /// In es, this message translates to:
  /// **'Eliminar la opción {number}'**
  String surveyRemoveOption(int number);

  /// No description provided for @surveyMinimumOptions.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos dos opciones'**
  String get surveyMinimumOptions;

  /// No description provided for @surveyClosingDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de cierre'**
  String get surveyClosingDate;

  /// No description provided for @surveyChangeClosingDate.
  ///
  /// In es, this message translates to:
  /// **'Cambiar fecha de cierre'**
  String get surveyChangeClosingDate;

  /// No description provided for @surveyResultsVisibleFromStart.
  ///
  /// In es, this message translates to:
  /// **'Mostrar resultados desde el principio'**
  String get surveyResultsVisibleFromStart;

  /// No description provided for @publishSurvey.
  ///
  /// In es, this message translates to:
  /// **'Publicar encuesta'**
  String get publishSurvey;

  /// No description provided for @surveyFutureClosingRequired.
  ///
  /// In es, this message translates to:
  /// **'La fecha de cierre debe ser posterior a la actual'**
  String get surveyFutureClosingRequired;

  /// No description provided for @deleteSurveyTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta encuesta?'**
  String get deleteSurveyTitle;

  /// No description provided for @deleteSurveyBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán también sus opciones y votos. Esta acción no se puede deshacer.'**
  String get deleteSurveyBody;

  /// No description provided for @alertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alertsTitle;

  /// No description provided for @newAlert.
  ///
  /// In es, this message translates to:
  /// **'Nueva alerta'**
  String get newAlert;

  /// No description provided for @includeExpiredAlerts.
  ///
  /// In es, this message translates to:
  /// **'Mostrar alertas finalizadas'**
  String get includeExpiredAlerts;

  /// No description provided for @noAlertsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay alertas'**
  String get noAlertsTitle;

  /// No description provided for @noAlertsBody.
  ///
  /// In es, this message translates to:
  /// **'No hay alertas para este municipio.'**
  String get noAlertsBody;

  /// No description provided for @alertSourceManual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get alertSourceManual;

  /// No description provided for @alertSourceAemet.
  ///
  /// In es, this message translates to:
  /// **'AEMET'**
  String get alertSourceAemet;

  /// No description provided for @alertStatusScheduled.
  ///
  /// In es, this message translates to:
  /// **'Programada'**
  String get alertStatusScheduled;

  /// No description provided for @alertStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get alertStatusActive;

  /// No description provided for @alertStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get alertStatusExpired;

  /// No description provided for @alertSeverityYellow.
  ///
  /// In es, this message translates to:
  /// **'Aviso amarillo · Nivel 1'**
  String get alertSeverityYellow;

  /// No description provided for @alertSeverityOrange.
  ///
  /// In es, this message translates to:
  /// **'Aviso naranja · Nivel 2'**
  String get alertSeverityOrange;

  /// No description provided for @alertSeverityRed.
  ///
  /// In es, this message translates to:
  /// **'Aviso rojo · Nivel 3'**
  String get alertSeverityRed;

  /// No description provided for @alertStartsAt.
  ///
  /// In es, this message translates to:
  /// **'Empieza el {date}'**
  String alertStartsAt(String date);

  /// No description provided for @alertEndsAt.
  ///
  /// In es, this message translates to:
  /// **'Termina el {date}'**
  String alertEndsAt(String date);

  /// No description provided for @alertWithoutEnd.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de finalización'**
  String get alertWithoutEnd;

  /// No description provided for @alertCardSemantics.
  ///
  /// In es, this message translates to:
  /// **'{severity}. {phenomenon}'**
  String alertCardSemantics(String severity, String phenomenon);

  /// No description provided for @alertCreatedBy.
  ///
  /// In es, this message translates to:
  /// **'Creada por {manager}'**
  String alertCreatedBy(String manager);

  /// No description provided for @alertUpdatedBy.
  ///
  /// In es, this message translates to:
  /// **'Actualizada por {manager}'**
  String alertUpdatedBy(String manager);

  /// No description provided for @deleteAlertTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta alerta?'**
  String get deleteAlertTitle;

  /// No description provided for @deleteAlertBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get deleteAlertBody;

  /// No description provided for @alertEditorNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva alerta manual'**
  String get alertEditorNewTitle;

  /// No description provided for @alertEditorEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar alerta manual'**
  String get alertEditorEditTitle;

  /// No description provided for @alertPhenomenonLabel.
  ///
  /// In es, this message translates to:
  /// **'Fenómeno o motivo'**
  String get alertPhenomenonLabel;

  /// No description provided for @alertPhenomenonTypeField.
  ///
  /// In es, this message translates to:
  /// **'Tipo de fenómeno'**
  String get alertPhenomenonTypeField;

  /// No description provided for @alertPhenomenonTypeIncendio.
  ///
  /// In es, this message translates to:
  /// **'Incendio'**
  String get alertPhenomenonTypeIncendio;

  /// No description provided for @alertPhenomenonTypeEvacuacion.
  ///
  /// In es, this message translates to:
  /// **'Evacuación'**
  String get alertPhenomenonTypeEvacuacion;

  /// No description provided for @alertPhenomenonTypeSanitario.
  ///
  /// In es, this message translates to:
  /// **'Sanitario'**
  String get alertPhenomenonTypeSanitario;

  /// No description provided for @alertPhenomenonTypeMeteorologico.
  ///
  /// In es, this message translates to:
  /// **'Meteorológico'**
  String get alertPhenomenonTypeMeteorologico;

  /// No description provided for @alertPhenomenonTypeOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get alertPhenomenonTypeOtro;

  /// No description provided for @alertSeverityField.
  ///
  /// In es, this message translates to:
  /// **'Nivel de aviso'**
  String get alertSeverityField;

  /// No description provided for @alertBodySpanish.
  ///
  /// In es, this message translates to:
  /// **'Mensaje en castellano'**
  String get alertBodySpanish;

  /// No description provided for @alertBodyValencian.
  ///
  /// In es, this message translates to:
  /// **'Mensaje en valenciano (opcional)'**
  String get alertBodyValencian;

  /// No description provided for @alertStartField.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get alertStartField;

  /// No description provided for @alertEndField.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get alertEndField;

  /// No description provided for @clearAlertEnd.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha de finalización'**
  String get clearAlertEnd;

  /// No description provided for @publishAlert.
  ///
  /// In es, this message translates to:
  /// **'Publicar alerta'**
  String get publishAlert;

  /// No description provided for @alertPublishedMessage.
  ///
  /// In es, this message translates to:
  /// **'Alerta publicada'**
  String get alertPublishedMessage;

  /// No description provided for @alertEndBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior al inicio'**
  String get alertEndBeforeStart;

  /// No description provided for @alertRedPushWarning.
  ///
  /// In es, this message translates to:
  /// **'Las alertas rojas enviarán una notificación obligatoria a los vecinos del municipio.'**
  String get alertRedPushWarning;

  /// No description provided for @alertAemetReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Las alertas procedentes de AEMET son de solo lectura y no se pueden modificar desde el panel.'**
  String get alertAemetReadOnly;

  /// No description provided for @pharmaciesTitle.
  ///
  /// In es, this message translates to:
  /// **'Farmacias de guardia'**
  String get pharmaciesTitle;

  /// No description provided for @pharmaciesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Carga manual de las guardias del municipio'**
  String get pharmaciesSubtitle;

  /// No description provided for @newDutyPharmacy.
  ///
  /// In es, this message translates to:
  /// **'Añadir guardia'**
  String get newDutyPharmacy;

  /// No description provided for @previousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get nextMonth;

  /// No description provided for @currentMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes actual'**
  String get currentMonth;

  /// No description provided for @noDutyPharmaciesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay guardias cargadas'**
  String get noDutyPharmaciesTitle;

  /// No description provided for @noDutyPharmaciesBody.
  ///
  /// In es, this message translates to:
  /// **'Añade las farmacias de guardia para este mes.'**
  String get noDutyPharmaciesBody;

  /// No description provided for @dutyPharmacyDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de guardia'**
  String get dutyPharmacyDateLabel;

  /// No description provided for @dutyPharmacyNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la farmacia'**
  String get dutyPharmacyNameLabel;

  /// No description provided for @dutyPharmacyAddressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get dutyPharmacyAddressLabel;

  /// No description provided for @dutyPharmacyPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get dutyPharmacyPhoneLabel;

  /// No description provided for @dutyPharmacyScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get dutyPharmacyScheduleLabel;

  /// No description provided for @editDutyPharmacy.
  ///
  /// In es, this message translates to:
  /// **'Editar guardia'**
  String get editDutyPharmacy;

  /// No description provided for @dutyPharmacyEditorNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva farmacia de guardia'**
  String get dutyPharmacyEditorNewTitle;

  /// No description provided for @dutyPharmacyEditorEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar farmacia de guardia'**
  String get dutyPharmacyEditorEditTitle;

  /// No description provided for @saveDutyPharmacy.
  ///
  /// In es, this message translates to:
  /// **'Guardar guardia'**
  String get saveDutyPharmacy;

  /// No description provided for @dutyPharmacySavedMessage.
  ///
  /// In es, this message translates to:
  /// **'Farmacia de guardia guardada'**
  String get dutyPharmacySavedMessage;

  /// No description provided for @dutyPharmacyDateExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una farmacia de guardia para esa fecha. Puedes editarla desde el listado.'**
  String get dutyPharmacyDateExists;

  /// No description provided for @selectDutyPharmacyDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha de guardia'**
  String get selectDutyPharmacyDate;

  /// No description provided for @formsTitle.
  ///
  /// In es, this message translates to:
  /// **'Formularios'**
  String get formsTitle;

  /// No description provided for @newForm.
  ///
  /// In es, this message translates to:
  /// **'Nuevo formulario'**
  String get newForm;

  /// No description provided for @includeClosedForms.
  ///
  /// In es, this message translates to:
  /// **'Mostrar formularios cerrados'**
  String get includeClosedForms;

  /// No description provided for @formsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay formularios para este municipio.'**
  String get formsEmpty;

  /// No description provided for @formOpenStatus.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get formOpenStatus;

  /// No description provided for @formClosedStatus.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get formClosedStatus;

  /// No description provided for @formNoDeadline.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get formNoDeadline;

  /// No description provided for @formDeadline.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite: {date}'**
  String formDeadline(String date);

  /// No description provided for @formFieldsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 campo} other{{count} campos}}'**
  String formFieldsCount(int count);

  /// No description provided for @formExportSubmissions.
  ///
  /// In es, this message translates to:
  /// **'Exportar respuestas CSV'**
  String get formExportSubmissions;

  /// No description provided for @formExportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Respuestas descargadas'**
  String get formExportSuccess;

  /// No description provided for @formExportUnsupported.
  ///
  /// In es, this message translates to:
  /// **'La descarga solo está disponible en la versión web del panel.'**
  String get formExportUnsupported;

  /// No description provided for @formDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar este formulario?'**
  String get formDeleteTitle;

  /// No description provided for @formDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán también todas sus respuestas. Esta acción no se puede deshacer.'**
  String get formDeleteBody;

  /// No description provided for @formCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo formulario'**
  String get formCreateTitle;

  /// No description provided for @formTitleSpanish.
  ///
  /// In es, this message translates to:
  /// **'Título en castellano'**
  String get formTitleSpanish;

  /// No description provided for @formTitleValencian.
  ///
  /// In es, this message translates to:
  /// **'Título en valenciano (opcional)'**
  String get formTitleValencian;

  /// No description provided for @formDescriptionSpanish.
  ///
  /// In es, this message translates to:
  /// **'Descripción en castellano'**
  String get formDescriptionSpanish;

  /// No description provided for @formDescriptionValencian.
  ///
  /// In es, this message translates to:
  /// **'Descripción en valenciano (opcional)'**
  String get formDescriptionValencian;

  /// No description provided for @formOptionalDeadline.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite (opcional)'**
  String get formOptionalDeadline;

  /// No description provided for @formChooseDeadline.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha límite'**
  String get formChooseDeadline;

  /// No description provided for @formClearDeadline.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha límite'**
  String get formClearDeadline;

  /// No description provided for @formFieldsTitle.
  ///
  /// In es, this message translates to:
  /// **'Campos del formulario'**
  String get formFieldsTitle;

  /// No description provided for @formFieldNumber.
  ///
  /// In es, this message translates to:
  /// **'Campo {number}'**
  String formFieldNumber(int number);

  /// No description provided for @formFieldKey.
  ///
  /// In es, this message translates to:
  /// **'Identificador interno'**
  String get formFieldKey;

  /// No description provided for @formFieldKeyHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: nombre_completo'**
  String get formFieldKeyHint;

  /// No description provided for @formFieldLabelSpanish.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta en castellano'**
  String get formFieldLabelSpanish;

  /// No description provided for @formFieldLabelValencian.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta en valenciano (opcional)'**
  String get formFieldLabelValencian;

  /// No description provided for @formFieldType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de campo'**
  String get formFieldType;

  /// No description provided for @formFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Respuesta obligatoria'**
  String get formFieldRequired;

  /// No description provided for @formFieldOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get formFieldOptions;

  /// No description provided for @formFieldOptionsHint.
  ///
  /// In es, this message translates to:
  /// **'Una opción por línea'**
  String get formFieldOptionsHint;

  /// No description provided for @formAddField.
  ///
  /// In es, this message translates to:
  /// **'Añadir campo'**
  String get formAddField;

  /// No description provided for @formRemoveField.
  ///
  /// In es, this message translates to:
  /// **'Eliminar campo'**
  String get formRemoveField;

  /// No description provided for @formMoveFieldUp.
  ///
  /// In es, this message translates to:
  /// **'Subir campo'**
  String get formMoveFieldUp;

  /// No description provided for @formMoveFieldDown.
  ///
  /// In es, this message translates to:
  /// **'Bajar campo'**
  String get formMoveFieldDown;

  /// No description provided for @formCreated.
  ///
  /// In es, this message translates to:
  /// **'Formulario publicado'**
  String get formCreated;

  /// No description provided for @formInvalidFieldKey.
  ///
  /// In es, this message translates to:
  /// **'Usa minúsculas, números y guiones bajos, sin espacios'**
  String get formInvalidFieldKey;

  /// No description provided for @formSelectNeedsOptions.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos dos opciones para el campo de selección'**
  String get formSelectNeedsOptions;

  /// No description provided for @formDuplicateFieldKeys.
  ///
  /// In es, this message translates to:
  /// **'Cada campo debe tener un identificador interno distinto'**
  String get formDuplicateFieldKeys;

  /// No description provided for @formFutureDeadline.
  ///
  /// In es, this message translates to:
  /// **'La fecha límite debe ser posterior a la actual'**
  String get formFutureDeadline;

  /// No description provided for @formFieldTypeText.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get formFieldTypeText;

  /// No description provided for @formFieldTypeNumber.
  ///
  /// In es, this message translates to:
  /// **'Número'**
  String get formFieldTypeNumber;

  /// No description provided for @formFieldTypeSelect.
  ///
  /// In es, this message translates to:
  /// **'Selección'**
  String get formFieldTypeSelect;

  /// No description provided for @formFieldTypeDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get formFieldTypeDate;

  /// No description provided for @formFieldTypeBoolean.
  ///
  /// In es, this message translates to:
  /// **'Sí o no'**
  String get formFieldTypeBoolean;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'Algo ha fallado. Inténtalo de nuevo.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In es, this message translates to:
  /// **'No se puede conectar con el servidor.'**
  String get networkError;

  /// No description provided for @unauthorizedError.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ha caducado. Vuelve a entrar.'**
  String get unauthorizedError;

  /// No description provided for @archivedLabel.
  ///
  /// In es, this message translates to:
  /// **'Archivada'**
  String get archivedLabel;

  /// No description provided for @pinnedStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Destacada'**
  String get pinnedStatusLabel;

  /// No description provided for @activeLabel.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get activeLabel;

  /// No description provided for @publishedOn.
  ///
  /// In es, this message translates to:
  /// **'Publicada el {date}'**
  String publishedOn(Object date);

  /// No description provided for @managerWithoutMunicipalities.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta no tiene municipios asignados.'**
  String get managerWithoutMunicipalities;

  /// No description provided for @openMenu.
  ///
  /// In es, this message translates to:
  /// **'Abrir menú'**
  String get openMenu;

  /// No description provided for @closeMenu.
  ///
  /// In es, this message translates to:
  /// **'Cerrar menú'**
  String get closeMenu;

  /// No description provided for @businessesTitle.
  ///
  /// In es, this message translates to:
  /// **'Comercios'**
  String get businessesTitle;

  /// No description provided for @newBusiness.
  ///
  /// In es, this message translates to:
  /// **'Nuevo comercio'**
  String get newBusiness;

  /// No description provided for @includeInactiveBusinesses.
  ///
  /// In es, this message translates to:
  /// **'Mostrar inactivos'**
  String get includeInactiveBusinesses;

  /// No description provided for @noBusinessesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay comercios'**
  String get noBusinessesTitle;

  /// No description provided for @noBusinessesBody.
  ///
  /// In es, this message translates to:
  /// **'Da de alta el primer comercio de este municipio.'**
  String get noBusinessesBody;

  /// No description provided for @businessInactiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get businessInactiveLabel;

  /// No description provided for @deleteBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar este comercio?'**
  String get deleteBusinessTitle;

  /// No description provided for @deleteBusinessBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get deleteBusinessBody;

  /// No description provided for @activate.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get deactivate;

  /// No description provided for @editorNewBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo comercio'**
  String get editorNewBusinessTitle;

  /// No description provided for @editorEditBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar comercio'**
  String get editorEditBusinessTitle;

  /// No description provided for @businessNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get businessNameLabel;

  /// No description provided for @businessCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get businessCategoryLabel;

  /// No description provided for @businessCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: bar, alimentacion, peluqueria'**
  String get businessCategoryHint;

  /// No description provided for @businessAddressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección (opcional)'**
  String get businessAddressLabel;

  /// No description provided for @businessPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get businessPhoneLabel;

  /// No description provided for @businessEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico (opcional)'**
  String get businessEmailLabel;

  /// No description provided for @businessWebsiteLabel.
  ///
  /// In es, this message translates to:
  /// **'Web (opcional)'**
  String get businessWebsiteLabel;

  /// No description provided for @businessScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario (opcional)'**
  String get businessScheduleLabel;

  /// No description provided for @businessDescriptionEsLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción en castellano (opcional)'**
  String get businessDescriptionEsLabel;

  /// No description provided for @businessDescriptionVaLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción en valenciano (opcional)'**
  String get businessDescriptionVaLabel;

  /// No description provided for @businessActiveSwitchLabel.
  ///
  /// In es, this message translates to:
  /// **'Comercio activo'**
  String get businessActiveSwitchLabel;

  /// No description provided for @businessCreatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Comercio creado'**
  String get businessCreatedMessage;

  /// No description provided for @businessSavedMessage.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get businessSavedMessage;

  /// No description provided for @businessPhotosTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get businessPhotosTitle;

  /// No description provided for @businessPhotosHelp.
  ///
  /// In es, this message translates to:
  /// **'JPG, PNG o WebP. Máximo 5 MB por foto, puedes seleccionar varias a la vez.'**
  String get businessPhotosHelp;

  /// No description provided for @businessPhotosPublishFirst.
  ///
  /// In es, this message translates to:
  /// **'Guarda el comercio antes de añadir fotos.'**
  String get businessPhotosPublishFirst;

  /// No description provided for @businessPhotoAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir fotos'**
  String get businessPhotoAdd;

  /// No description provided for @businessPhotoUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo foto {current} de {total}…'**
  String businessPhotoUploading(int current, int total);

  /// No description provided for @businessPhotoUploadSuccess.
  ///
  /// In es, this message translates to:
  /// **'Fotos añadidas correctamente.'**
  String get businessPhotoUploadSuccess;

  /// No description provided for @businessPhotoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'Una de las fotos supera el máximo de 5 MB.'**
  String get businessPhotoTooLarge;

  /// No description provided for @businessPhotoUnsupportedType.
  ///
  /// In es, this message translates to:
  /// **'Una de las fotos no es un JPG, PNG o WebP válido.'**
  String get businessPhotoUnsupportedType;

  /// No description provided for @businessPhotoInvalidFile.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido leer una de las fotos.'**
  String get businessPhotoInvalidFile;

  /// No description provided for @businessPhotoUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido subir alguna foto.'**
  String get businessPhotoUploadError;

  /// No description provided for @businessPhotoRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar subida'**
  String get businessPhotoRetry;

  /// No description provided for @businessPhotoDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar esta foto?'**
  String get businessPhotoDeleteTitle;

  /// No description provided for @businessPhotoDeleteSemantic.
  ///
  /// In es, this message translates to:
  /// **'Quitar la foto {index}'**
  String businessPhotoDeleteSemantic(int index);

  /// No description provided for @businessPhotoMoveLeftSemantic.
  ///
  /// In es, this message translates to:
  /// **'Mover la foto {index} hacia atrás'**
  String businessPhotoMoveLeftSemantic(int index);

  /// No description provided for @businessPhotoMoveRightSemantic.
  ///
  /// In es, this message translates to:
  /// **'Mover la foto {index} hacia delante'**
  String businessPhotoMoveRightSemantic(int index);

  /// No description provided for @socialConnectionsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Conexiones con redes sociales'**
  String get socialConnectionsTooltip;

  /// No description provided for @socialConnectionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Conexiones con redes sociales'**
  String get socialConnectionsTitle;

  /// No description provided for @socialConnectionsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Conecta las cuentas de Instagram y Facebook del ayuntamiento para publicar noticias también ahí.'**
  String get socialConnectionsSubtitle;

  /// No description provided for @socialPlatformInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram'**
  String get socialPlatformInstagram;

  /// No description provided for @socialPlatformFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook'**
  String get socialPlatformFacebook;

  /// No description provided for @socialConnect.
  ///
  /// In es, this message translates to:
  /// **'Conectar'**
  String get socialConnect;

  /// No description provided for @socialDisconnect.
  ///
  /// In es, this message translates to:
  /// **'Desconectar'**
  String get socialDisconnect;

  /// No description provided for @socialStatusConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectada'**
  String get socialStatusConnected;

  /// No description provided for @socialStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Token caducado'**
  String get socialStatusExpired;

  /// No description provided for @socialStatusError.
  ///
  /// In es, this message translates to:
  /// **'Con errores'**
  String get socialStatusError;

  /// No description provided for @socialStatusRevoked.
  ///
  /// In es, this message translates to:
  /// **'Revocada'**
  String get socialStatusRevoked;

  /// No description provided for @socialNotConnected.
  ///
  /// In es, this message translates to:
  /// **'Sin conectar'**
  String get socialNotConnected;

  /// No description provided for @socialDisconnectConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Desconectar esta cuenta?'**
  String get socialDisconnectConfirmTitle;

  /// No description provided for @socialDisconnectConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Dejará de publicarse contenido en este canal hasta que se vuelva a conectar.'**
  String get socialDisconnectConfirmBody;

  /// No description provided for @socialOAuthSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta conectada correctamente.'**
  String get socialOAuthSuccess;

  /// No description provided for @socialOAuthError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido conectar la cuenta. Inténtalo de nuevo.'**
  String get socialOAuthError;

  /// No description provided for @shareToInstagramLabel.
  ///
  /// In es, this message translates to:
  /// **'Compartir en Instagram'**
  String get shareToInstagramLabel;

  /// No description provided for @shareToFacebookLabel.
  ///
  /// In es, this message translates to:
  /// **'Compartir en Facebook'**
  String get shareToFacebookLabel;

  /// No description provided for @shareToChannelsHelp.
  ///
  /// In es, this message translates to:
  /// **'La cuenta debe estar conectada desde Conexiones con redes sociales.'**
  String get shareToChannelsHelp;

  /// No description provided for @invalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido'**
  String get invalidNumber;

  /// No description provided for @facilitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Instalaciones'**
  String get facilitiesTitle;

  /// No description provided for @newFacility.
  ///
  /// In es, this message translates to:
  /// **'Nueva instalación'**
  String get newFacility;

  /// No description provided for @noFacilitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay instalaciones'**
  String get noFacilitiesTitle;

  /// No description provided for @noFacilitiesBody.
  ///
  /// In es, this message translates to:
  /// **'Da de alta la primera instalación reservable de este municipio.'**
  String get noFacilitiesBody;

  /// No description provided for @facilityInactiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get facilityInactiveLabel;

  /// No description provided for @facilitySlotDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Franjas de {minutes} minutos'**
  String facilitySlotDurationLabel(int minutes);

  /// No description provided for @editorNewFacilityTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva instalación'**
  String get editorNewFacilityTitle;

  /// No description provided for @editorEditFacilityTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar instalación'**
  String get editorEditFacilityTitle;

  /// No description provided for @facilityNameEsLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre en castellano'**
  String get facilityNameEsLabel;

  /// No description provided for @facilityNameVaLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre en valenciano (opcional)'**
  String get facilityNameVaLabel;

  /// No description provided for @facilityCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get facilityCategoryLabel;

  /// No description provided for @facilityCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Pádel, Tenis, Barbacoa'**
  String get facilityCategoryHint;

  /// No description provided for @facilityDescriptionEsLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción en castellano (opcional)'**
  String get facilityDescriptionEsLabel;

  /// No description provided for @facilityDescriptionVaLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción en valenciano (opcional)'**
  String get facilityDescriptionVaLabel;

  /// No description provided for @facilitySlotDurationFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración de cada franja (minutos)'**
  String get facilitySlotDurationFieldLabel;

  /// No description provided for @facilityMaxAdvanceDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Antelación máxima de reserva (días)'**
  String get facilityMaxAdvanceDaysLabel;

  /// No description provided for @facilityOpeningHoursSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Horario semanal'**
  String get facilityOpeningHoursSectionTitle;

  /// No description provided for @facilityOpeningHoursSectionHelp.
  ///
  /// In es, this message translates to:
  /// **'Un único tramo por día. Los vecinos solo podrán reservar dentro de este horario.'**
  String get facilityOpeningHoursSectionHelp;

  /// No description provided for @facilityClosedLabel.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get facilityClosedLabel;

  /// No description provided for @facilityOpenLabel.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get facilityOpenLabel;

  /// No description provided for @facilityOpenTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Abre'**
  String get facilityOpenTimeLabel;

  /// No description provided for @facilityCloseTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Cierra'**
  String get facilityCloseTimeLabel;

  /// No description provided for @facilityInvalidHours.
  ///
  /// In es, this message translates to:
  /// **'Revisa el horario: la hora de apertura debe ser anterior a la de cierre, en formato HH:mm.'**
  String get facilityInvalidHours;

  /// No description provided for @facilityDayMon.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get facilityDayMon;

  /// No description provided for @facilityDayTue.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get facilityDayTue;

  /// No description provided for @facilityDayWed.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get facilityDayWed;

  /// No description provided for @facilityDayThu.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get facilityDayThu;

  /// No description provided for @facilityDayFri.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get facilityDayFri;

  /// No description provided for @facilityDaySat.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get facilityDaySat;

  /// No description provided for @facilityDaySun.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get facilityDaySun;

  /// No description provided for @facilityFeeNoteEsLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota de tarifa en castellano (opcional)'**
  String get facilityFeeNoteEsLabel;

  /// No description provided for @facilityFeeNoteVaLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota de tarifa en valenciano (opcional)'**
  String get facilityFeeNoteVaLabel;

  /// No description provided for @facilityFeeNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Texto informativo, por ejemplo: 3€/hora, se abona en el ayuntamiento'**
  String get facilityFeeNoteHint;

  /// No description provided for @facilityActiveSwitchLabel.
  ///
  /// In es, this message translates to:
  /// **'Instalación activa'**
  String get facilityActiveSwitchLabel;

  /// No description provided for @facilityCreatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Instalación creada'**
  String get facilityCreatedMessage;

  /// No description provided for @facilitySavedMessage.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get facilitySavedMessage;

  /// No description provided for @reservationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get reservationsTitle;

  /// No description provided for @reservationsFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas las instalaciones'**
  String get reservationsFilterAll;

  /// No description provided for @noReservationsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay reservas'**
  String get noReservationsTitle;

  /// No description provided for @noReservationsBody.
  ///
  /// In es, this message translates to:
  /// **'Las reservas que hagan los vecinos aparecerán aquí.'**
  String get noReservationsBody;

  /// No description provided for @reservationCancelAction.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get reservationCancelAction;

  /// No description provided for @reservationCancelledMessage.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada. Se ha avisado al vecino.'**
  String get reservationCancelledMessage;

  /// No description provided for @reservationCancelDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar esta reserva'**
  String get reservationCancelDialogTitle;

  /// No description provided for @reservationCancelDialogBody.
  ///
  /// In es, this message translates to:
  /// **'El vecino recibirá un aviso con el motivo. Esta acción no se puede deshacer.'**
  String get reservationCancelDialogBody;

  /// No description provided for @reservationCancelNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la cancelación'**
  String get reservationCancelNoteLabel;

  /// No description provided for @reservationCancelConfirmAction.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get reservationCancelConfirmAction;
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
