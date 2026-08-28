import '../../../l10n/app_localizations.dart';

/// Text contract for the forms feature.
///
/// The application layer must adapt generated ARB localizations to this
/// contract. Keeping this feature free of literal UI text lets it be developed
/// independently without bypassing the project's localization pipeline.
abstract interface class FormsCopy {
  String get title;
  String get newForm;
  String get includeClosed;
  String get empty;
  String get loading;
  String get retry;
  String get loadMore;
  String get openStatus;
  String get closedStatus;
  String get noDeadline;
  String deadline(String value);
  String fieldsCount(int count);
  String get exportSubmissions;
  String get exportSuccess;
  String get exportUnsupported;
  String get delete;
  String get deleteTitle;
  String get deleteBody;
  String get cancel;
  String get confirm;
  String get genericError;
  String get networkError;
  String get createTitle;
  String get titleSpanish;
  String get titleValencian;
  String get descriptionSpanish;
  String get descriptionValencian;
  String get optionalDeadline;
  String get chooseDeadline;
  String get clearDeadline;
  String get fieldsTitle;
  String fieldNumber(int number);
  String get fieldKey;
  String get fieldKeyHint;
  String get fieldLabelSpanish;
  String get fieldLabelValencian;
  String get fieldType;
  String get fieldRequired;
  String get fieldOptions;
  String get fieldOptionsHint;
  String get addField;
  String get removeField;
  String get moveFieldUp;
  String get moveFieldDown;
  String get save;
  String get created;
  String get requiredField;
  String get invalidFieldKey;
  String get selectNeedsOptions;
  String get duplicateFieldKeys;
  String get futureDeadline;
  String get fieldTypeText;
  String get fieldTypeNumber;
  String get fieldTypeSelect;
  String get fieldTypeDate;
  String get fieldTypeBoolean;
}

class AppFormsCopy implements FormsCopy {
  const AppFormsCopy(this._l10n);
  final AppLocalizations _l10n;

  @override
  String get title => _l10n.formsTitle;
  @override
  String get newForm => _l10n.newForm;
  @override
  String get includeClosed => _l10n.includeClosedForms;
  @override
  String get empty => _l10n.formsEmpty;
  @override
  String get loading => _l10n.loading;
  @override
  String get retry => _l10n.retry;
  @override
  String get loadMore => _l10n.loadMore;
  @override
  String get openStatus => _l10n.formOpenStatus;
  @override
  String get closedStatus => _l10n.formClosedStatus;
  @override
  String get noDeadline => _l10n.formNoDeadline;
  @override
  String deadline(String value) => _l10n.formDeadline(value);
  @override
  String fieldsCount(int count) => _l10n.formFieldsCount(count);
  @override
  String get exportSubmissions => _l10n.formExportSubmissions;
  @override
  String get exportSuccess => _l10n.formExportSuccess;
  @override
  String get exportUnsupported => _l10n.formExportUnsupported;
  @override
  String get delete => _l10n.delete;
  @override
  String get deleteTitle => _l10n.formDeleteTitle;
  @override
  String get deleteBody => _l10n.formDeleteBody;
  @override
  String get cancel => _l10n.cancel;
  @override
  String get confirm => _l10n.confirmDelete;
  @override
  String get genericError => _l10n.genericError;
  @override
  String get networkError => _l10n.networkError;
  @override
  String get createTitle => _l10n.formCreateTitle;
  @override
  String get titleSpanish => _l10n.formTitleSpanish;
  @override
  String get titleValencian => _l10n.formTitleValencian;
  @override
  String get descriptionSpanish => _l10n.formDescriptionSpanish;
  @override
  String get descriptionValencian => _l10n.formDescriptionValencian;
  @override
  String get optionalDeadline => _l10n.formOptionalDeadline;
  @override
  String get chooseDeadline => _l10n.formChooseDeadline;
  @override
  String get clearDeadline => _l10n.formClearDeadline;
  @override
  String get fieldsTitle => _l10n.formFieldsTitle;
  @override
  String fieldNumber(int number) => _l10n.formFieldNumber(number);
  @override
  String get fieldKey => _l10n.formFieldKey;
  @override
  String get fieldKeyHint => _l10n.formFieldKeyHint;
  @override
  String get fieldLabelSpanish => _l10n.formFieldLabelSpanish;
  @override
  String get fieldLabelValencian => _l10n.formFieldLabelValencian;
  @override
  String get fieldType => _l10n.formFieldType;
  @override
  String get fieldRequired => _l10n.formFieldRequired;
  @override
  String get fieldOptions => _l10n.formFieldOptions;
  @override
  String get fieldOptionsHint => _l10n.formFieldOptionsHint;
  @override
  String get addField => _l10n.formAddField;
  @override
  String get removeField => _l10n.formRemoveField;
  @override
  String get moveFieldUp => _l10n.formMoveFieldUp;
  @override
  String get moveFieldDown => _l10n.formMoveFieldDown;
  @override
  String get save => _l10n.saveChanges;
  @override
  String get created => _l10n.formCreated;
  @override
  String get requiredField => _l10n.requiredField;
  @override
  String get invalidFieldKey => _l10n.formInvalidFieldKey;
  @override
  String get selectNeedsOptions => _l10n.formSelectNeedsOptions;
  @override
  String get duplicateFieldKeys => _l10n.formDuplicateFieldKeys;
  @override
  String get futureDeadline => _l10n.formFutureDeadline;
  @override
  String get fieldTypeText => _l10n.formFieldTypeText;
  @override
  String get fieldTypeNumber => _l10n.formFieldTypeNumber;
  @override
  String get fieldTypeSelect => _l10n.formFieldTypeSelect;
  @override
  String get fieldTypeDate => _l10n.formFieldTypeDate;
  @override
  String get fieldTypeBoolean => _l10n.formFieldTypeBoolean;
}
