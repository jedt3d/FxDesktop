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

  @override
  String get ribbonToolbarSemantics => 'रिबन उपकरणपट्टी';

  @override
  String get ribbonNoTabs => 'रिबन ट्याब छैन';

  @override
  String get ribbonCollapse => 'रिबन संक्षिप्त गर्नुहोस्';

  @override
  String get ribbonExpand => 'रिबन विस्तार गर्नुहोस्';

  @override
  String get ribbonOpenMenu => 'मेनु खोल्नुहोस्';

  @override
  String get ribbonMenuEmpty => 'मेनु वस्तु छैन';

  @override
  String ribbonGroupSemantics(String group) {
    return 'रिबन समूह $group';
  }

  @override
  String get ribbonDesignerTitle => 'रिबन डिजाइनर';

  @override
  String get ribbonDesignerNew => 'नयाँ';

  @override
  String get ribbonDesignerAddTab => 'ट्याब थप्नुहोस्';

  @override
  String get ribbonDesignerAddGroup => 'समूह थप्नुहोस्';

  @override
  String get ribbonDesignerAddItem => 'वस्तु थप्नुहोस्';

  @override
  String get ribbonDesignerDelete => 'मेटाउनुहोस्';

  @override
  String get ribbonDesignerExport => 'JSON निर्यात';

  @override
  String get ribbonDesignerExported => 'रिबन JSON निर्यात गरियो।';

  @override
  String get ribbonDesignerPreviewLocale => 'पूर्वावलोकन लोकेल';

  @override
  String get ribbonDesignerStructure => 'संरचना';

  @override
  String get ribbonDesignerJsonPreview => 'JSON पूर्वावलोकन';

  @override
  String get ribbonDesignerInspector => 'निरीक्षक';

  @override
  String get ribbonDesignerNoSelection =>
      'ट्याब, समूह, वा वस्तु चयन गर्नुहोस्।';

  @override
  String get ribbonDesignerStatusReady => 'तयार।';

  @override
  String get ribbonDesignerCaption => 'क्याप्सन';

  @override
  String get ribbonDesignerKeyTip => 'KeyTip';

  @override
  String get ribbonDesignerContextual => 'सान्दर्भिक ट्याब';

  @override
  String get ribbonDesignerContextGroup => 'सान्दर्भिक समूह';

  @override
  String get ribbonDesignerCommandTag => 'कमाण्ड ट्याग';

  @override
  String get ribbonDesignerItemType => 'वस्तु प्रकार';

  @override
  String get ribbonDesignerTooltip => 'टुलटिप';

  @override
  String get ribbonDesignerIconKey => 'आइकन कुञ्जी';

  @override
  String get ribbonDesignerEnabled => 'सक्षम';

  @override
  String get ribbonDesignerChecked => 'चेक गरिएको';

  @override
  String get ribbonDesignerLocalizedCaptions => 'स्थानीयकृत क्याप्सन';

  @override
  String get ribbonItemTypeLarge => 'ठूलो बटन';

  @override
  String get ribbonItemTypeSmall => 'सानो बटन';

  @override
  String get ribbonItemTypeMedium => 'मध्यम बटन';

  @override
  String get ribbonItemTypeDropdown => 'ड्रपडाउन';

  @override
  String get ribbonItemTypeSplitButton => 'स्प्लिट बटन';

  @override
  String get ribbonItemTypeMediumDropdown => 'मध्यम ड्रपडाउन';

  @override
  String get ribbonItemTypeMediumSplitButton => 'मध्यम स्प्लिट बटन';

  @override
  String get ribbonItemTypeGallery => 'ग्यालरी';

  @override
  String get ribbonItemTypeToggle => 'टगल';

  @override
  String get ribbonItemTypeCheckBox => 'चेकबक्स';

  @override
  String get ribbonItemTypeSeparator => 'विभाजक';

  @override
  String get ribbonItemTypeColumnBreak => 'स्तम्भ ब्रेक';

  @override
  String get ribbonDesignerLivePreview => 'प्रत्यक्ष पूर्वावलोकन';

  @override
  String get ribbonDesignerValidation => 'प्रमाणीकरण';

  @override
  String get ribbonDesignerValidationValid => 'परिभाषा मान्य छ';
}
