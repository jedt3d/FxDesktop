// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_desktop_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class FxDesktopLocalizationsNe extends FxDesktopLocalizations {
  FxDesktopLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get datePickerEmptyHint => 'मिति चयन गर्नुहोस्';

  @override
  String get timePickerEmptyHint => 'समय चयन गर्नुहोस्';

  @override
  String get dateTimePickerEmptyHint => 'मिति र समय चयन गर्नुहोस्';

  @override
  String get popupMenuNoOptions => 'विकल्प छैनन्';

  @override
  String get lookupNoOptionsFound => 'विकल्प फेला परेन';

  @override
  String get colorPickerNoColorButton => 'रङ छैन';

  @override
  String get colorPickerNoColorValue => 'रङ छैन';

  @override
  String colorPickerPreviewLabel(String color) {
    return 'पूर्वावलोकन: $color';
  }

  @override
  String get colorPickerHueLabel => 'ह्यु';

  @override
  String get colorPickerSaturationLabel => 'स्याचुरेसन';

  @override
  String get colorPickerValueLabel => 'मान';

  @override
  String get colorPickerRgbHexLabel => 'RGB #RRGGBB';

  @override
  String get colorPickerHexError => '#RRGGBB को रूपमा रङ प्रविष्ट गर्नुहोस्।';

  @override
  String get colorPickerCancelButton => 'रद्द गर्नुहोस्';

  @override
  String get colorPickerApplyButton => 'लागू गर्नुहोस्';

  @override
  String get tableNoRecords => 'देखाउन कुनै रेकर्ड छैन';

  @override
  String get tableLoadError => 'डेटा लोड गर्दा त्रुटि भयो';

  @override
  String tableEditUndoLabel(String column) {
    return '$column सम्पादन गर्नुहोस्';
  }

  @override
  String get tablePasteValuesUndoLabel => 'मान टाँस्नुहोस्';

  @override
  String tableAutoFitUndoLabel(String column) {
    return '$column स्वतः मिलाउनुहोस्';
  }

  @override
  String tableMovingRowFeedback(int row) {
    return 'पङ्क्ति $row सारिँदै';
  }

  @override
  String get tableBooleanChecked => 'चेक गरिएको';

  @override
  String get tableBooleanUnchecked => 'चेक नगरिएको';

  @override
  String tableCellSemantics(int row, String column, String value) {
    return 'पङ्क्ति $row, स्तम्भ $column: $value';
  }

  @override
  String tableValidationErrorSuffix(String error) {
    return 'प्रमाणीकरण त्रुटि: $error';
  }

  @override
  String get gridContextMenuCopySelection => 'चयन प्रतिलिपि गर्नुहोस्';

  @override
  String get designerEditMenuCopyItem => 'प्रतिलिपि गर्नुहोस्';

  @override
  String get galleryTitle => 'FxDesktop स्थानीयकरण ग्यालरी';

  @override
  String get gallerySubtitle =>
      'समर्थित भाषाहरूमा FxDesktop ले स्वामित्व लिएको कम्पोनेन्ट पाठ बदल्ने एउटै डेस्कटप सतह।';

  @override
  String get galleryLanguageEnglish => 'अंग्रेजी';

  @override
  String get galleryLanguageThai => 'थाई';

  @override
  String get galleryLanguageJapanese => 'जापानी';

  @override
  String get galleryLanguageNepali => 'नेपाली';

  @override
  String get galleryLocaleLabel => 'लोकेल';

  @override
  String get galleryDirectionLabel => 'दिशा';

  @override
  String get galleryFormSection => 'फर्म नियन्त्रणहरू';

  @override
  String get galleryChoiceSection => 'छनोट नियन्त्रणहरू';

  @override
  String get galleryNavigationSection => 'नेभिगेसन नियन्त्रणहरू';

  @override
  String get galleryDateTimeColorSection => 'मिति, समय र रङ';

  @override
  String get galleryTableSection => 'ListBox र Grid';

  @override
  String get galleryStateSection => 'अवस्था र प्रमाणीकरण';

  @override
  String get galleryPoSection => 'PO ब्रिज';

  @override
  String get galleryCustomerLabel => 'ग्राहक';

  @override
  String get galleryCustomerHint => 'कम्पनी वा व्यक्तिको नाम';

  @override
  String get galleryStatusLabel => 'अवस्था';

  @override
  String get galleryPriorityLabel => 'प्राथमिकता';

  @override
  String get galleryEnabledLabel => 'सक्षम';

  @override
  String get gallerySelectedLabel => 'चयन गरिएको';

  @override
  String get galleryCompactLabel => 'कम्प्याक्ट';

  @override
  String get galleryDetailedLabel => 'विस्तृत';

  @override
  String get gallerySummaryTab => 'सारांश';

  @override
  String get galleryAuditTab => 'अडिट';

  @override
  String get galleryStartDateLabel => 'सुरु मिति';

  @override
  String get galleryAccentColorLabel => 'एक्सेन्ट रङ';

  @override
  String get galleryOrderColumn => 'अर्डर';

  @override
  String get galleryOwnerColumn => 'मालिक';

  @override
  String get galleryStateColumn => 'अवस्था';

  @override
  String get galleryOpenStatus => 'खुला';

  @override
  String get galleryClosedStatus => 'बन्द';

  @override
  String get galleryPoStatus =>
      'ARB रनटाइम स्रोत नै रहन्छ; PO र POT अनुवादकका ब्रिज फाइलहरू हुन्।';
}
