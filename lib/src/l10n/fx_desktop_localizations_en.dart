// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_desktop_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FxDesktopLocalizationsEn extends FxDesktopLocalizations {
  FxDesktopLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get datePickerEmptyHint => 'Select date';

  @override
  String get timePickerEmptyHint => 'Select time';

  @override
  String get dateTimePickerEmptyHint => 'Select date and time';

  @override
  String get popupMenuNoOptions => 'No options';

  @override
  String get lookupNoOptionsFound => 'No options found';

  @override
  String get colorPickerNoColorButton => 'No Color';

  @override
  String get colorPickerNoColorValue => 'No color';

  @override
  String colorPickerPreviewLabel(String color) {
    return 'Preview: $color';
  }

  @override
  String get colorPickerHueLabel => 'Hue';

  @override
  String get colorPickerSaturationLabel => 'Saturation';

  @override
  String get colorPickerValueLabel => 'Value';

  @override
  String get colorPickerRgbHexLabel => 'RGB #RRGGBB';

  @override
  String get colorPickerHexError => 'Enter a color as #RRGGBB.';

  @override
  String get colorPickerCancelButton => 'Cancel';

  @override
  String get colorPickerApplyButton => 'Apply';

  @override
  String get tableNoRecords => 'No records to display';

  @override
  String get tableLoadError => 'An error occurred loading data';

  @override
  String tableEditUndoLabel(String column) {
    return 'Edit $column';
  }

  @override
  String get tablePasteValuesUndoLabel => 'Paste Values';

  @override
  String tableAutoFitUndoLabel(String column) {
    return 'Auto-fit $column';
  }

  @override
  String tableMovingRowFeedback(int row) {
    return 'Moving Row $row';
  }

  @override
  String get tableBooleanChecked => 'checked';

  @override
  String get tableBooleanUnchecked => 'unchecked';

  @override
  String tableCellSemantics(int row, String column, String value) {
    return 'Row $row, Column $column: $value';
  }

  @override
  String tableValidationErrorSuffix(String error) {
    return 'validation error: $error';
  }

  @override
  String get gridContextMenuCopySelection => 'Copy';

  @override
  String get designerEditMenuCopyItem => 'Copy';

  @override
  String get galleryTitle => 'FxDesktop Localization Gallery';

  @override
  String get gallerySubtitle =>
      'One desktop surface for switching FxDesktop-owned component text across supported locales.';

  @override
  String get galleryLanguageEnglish => 'English';

  @override
  String get galleryLanguageThai => 'Thai';

  @override
  String get galleryLanguageJapanese => 'Japanese';

  @override
  String get galleryLanguageNepali => 'Nepali';

  @override
  String get galleryLocaleLabel => 'Locale';

  @override
  String get galleryDirectionLabel => 'Direction';

  @override
  String get galleryFormSection => 'Form controls';

  @override
  String get galleryChoiceSection => 'Choice controls';

  @override
  String get galleryNavigationSection => 'Navigation controls';

  @override
  String get galleryDateTimeColorSection => 'Date, time, and color';

  @override
  String get galleryTableSection => 'ListBox and Grid';

  @override
  String get galleryStateSection => 'States and validation';

  @override
  String get galleryPoSection => 'PO bridge';

  @override
  String get galleryCustomerLabel => 'Customer';

  @override
  String get galleryCustomerHint => 'Company or person name';

  @override
  String get galleryStatusLabel => 'Status';

  @override
  String get galleryPriorityLabel => 'Priority';

  @override
  String get galleryEnabledLabel => 'Enabled';

  @override
  String get gallerySelectedLabel => 'Selected';

  @override
  String get galleryCompactLabel => 'Compact';

  @override
  String get galleryDetailedLabel => 'Detailed';

  @override
  String get gallerySummaryTab => 'Summary';

  @override
  String get galleryAuditTab => 'Audit';

  @override
  String get galleryStartDateLabel => 'Start date';

  @override
  String get galleryAccentColorLabel => 'Accent color';

  @override
  String get galleryOrderColumn => 'Order';

  @override
  String get galleryOwnerColumn => 'Owner';

  @override
  String get galleryStateColumn => 'State';

  @override
  String get galleryOpenStatus => 'Open';

  @override
  String get galleryClosedStatus => 'Closed';

  @override
  String get galleryPoStatus =>
      'ARB remains the runtime source; PO and POT are translator bridge files.';
}
