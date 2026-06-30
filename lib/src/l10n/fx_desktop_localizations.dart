import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fx_desktop_localizations_en.dart';
import 'fx_desktop_localizations_ja.dart';
import 'fx_desktop_localizations_ne.dart';
import 'fx_desktop_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FxDesktopLocalizations
/// returned by `FxDesktopLocalizations.of(context)`.
///
/// Applications need to include `FxDesktopLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/fx_desktop_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
///   supportedLocales: FxDesktopLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FxDesktopLocalizations.supportedLocales
/// property.
abstract class FxDesktopLocalizations {
  FxDesktopLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FxDesktopLocalizations of(BuildContext context) {
    return Localizations.of<FxDesktopLocalizations>(
      context,
      FxDesktopLocalizations,
    )!;
  }

  static const LocalizationsDelegate<FxDesktopLocalizations> delegate =
      _FxDesktopLocalizationsDelegate();

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
    Locale('en'),
    Locale('ja'),
    Locale('ne'),
    Locale('th'),
  ];

  /// Empty prompt shown by FxDateTimePicker in date mode.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get datePickerEmptyHint;

  /// Empty prompt shown by FxDateTimePicker in time mode.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timePickerEmptyHint;

  /// Empty prompt shown by FxDateTimePicker in date-time mode.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get dateTimePickerEmptyHint;

  /// Fallback hint shown when FxPopupMenu has no selectable options.
  ///
  /// In en, this message translates to:
  /// **'No options'**
  String get popupMenuNoOptions;

  /// Empty result message shown by the hosted lookup combo overlay.
  ///
  /// In en, this message translates to:
  /// **'No options found'**
  String get lookupNoOptionsFound;

  /// Dialog action button that clears a nullable color value.
  ///
  /// In en, this message translates to:
  /// **'No Color'**
  String get colorPickerNoColorButton;

  /// Value text shown when a nullable color picker has no selected color.
  ///
  /// In en, this message translates to:
  /// **'No color'**
  String get colorPickerNoColorValue;

  /// Preview label in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Preview: {color}'**
  String colorPickerPreviewLabel(String color);

  /// Hue slider label in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get colorPickerHueLabel;

  /// Saturation slider label in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get colorPickerSaturationLabel;

  /// Brightness/value slider label in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get colorPickerValueLabel;

  /// Hex RGB input label in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'RGB #RRGGBB'**
  String get colorPickerRgbHexLabel;

  /// Validation error shown when the RGB hex value is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a color as #RRGGBB.'**
  String get colorPickerHexError;

  /// Cancel action in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get colorPickerCancelButton;

  /// Apply action in the color picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get colorPickerApplyButton;

  /// Empty state message shown by FxListBox and FxGrid.
  ///
  /// In en, this message translates to:
  /// **'No records to display'**
  String get tableNoRecords;

  /// Default error message shown by FxListBox and FxGrid when no custom error text is supplied.
  ///
  /// In en, this message translates to:
  /// **'An error occurred loading data'**
  String get tableLoadError;

  /// Undo stack label for editing one table cell.
  ///
  /// In en, this message translates to:
  /// **'Edit {column}'**
  String tableEditUndoLabel(String column);

  /// Undo stack label for a paste operation that edits several cells.
  ///
  /// In en, this message translates to:
  /// **'Paste Values'**
  String get tablePasteValuesUndoLabel;

  /// Undo stack label for auto-fitting a table column.
  ///
  /// In en, this message translates to:
  /// **'Auto-fit {column}'**
  String tableAutoFitUndoLabel(String column);

  /// Drag feedback shown while a table row is being reordered.
  ///
  /// In en, this message translates to:
  /// **'Moving Row {row}'**
  String tableMovingRowFeedback(int row);

  /// Accessible value for a checked boolean table cell.
  ///
  /// In en, this message translates to:
  /// **'checked'**
  String get tableBooleanChecked;

  /// Accessible value for an unchecked boolean table cell.
  ///
  /// In en, this message translates to:
  /// **'unchecked'**
  String get tableBooleanUnchecked;

  /// Accessible label for a table cell.
  ///
  /// In en, this message translates to:
  /// **'Row {row}, Column {column}: {value}'**
  String tableCellSemantics(int row, String column, String value);

  /// Accessible suffix appended to a table cell semantic label when the cell has a validation error.
  ///
  /// In en, this message translates to:
  /// **'validation error: {error}'**
  String tableValidationErrorSuffix(String error);

  /// Context menu action that copies the selected grid or list rows.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get gridContextMenuCopySelection;

  /// Designer edit-menu command that copies the selected component.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get designerEditMenuCopyItem;

  /// Title for the one-window localization gallery.
  ///
  /// In en, this message translates to:
  /// **'FxDesktop Localization Gallery'**
  String get galleryTitle;

  /// Subtitle for the one-window localization gallery.
  ///
  /// In en, this message translates to:
  /// **'One desktop surface for switching FxDesktop-owned component text across supported locales.'**
  String get gallerySubtitle;

  /// Language name shown in the gallery language switcher.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get galleryLanguageEnglish;

  /// Language name shown in the gallery language switcher.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get galleryLanguageThai;

  /// Language name shown in the gallery language switcher.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get galleryLanguageJapanese;

  /// Language name shown in the gallery language switcher.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get galleryLanguageNepali;

  /// Label for the active locale code in the localization gallery.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get galleryLocaleLabel;

  /// Label for the active text direction in the localization gallery.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get galleryDirectionLabel;

  /// Section heading for localized form control examples.
  ///
  /// In en, this message translates to:
  /// **'Form controls'**
  String get galleryFormSection;

  /// Section heading for localized choice control examples.
  ///
  /// In en, this message translates to:
  /// **'Choice controls'**
  String get galleryChoiceSection;

  /// Section heading for localized navigation control examples.
  ///
  /// In en, this message translates to:
  /// **'Navigation controls'**
  String get galleryNavigationSection;

  /// Section heading for localized date/time and color examples.
  ///
  /// In en, this message translates to:
  /// **'Date, time, and color'**
  String get galleryDateTimeColorSection;

  /// Section heading for localized table examples.
  ///
  /// In en, this message translates to:
  /// **'ListBox and Grid'**
  String get galleryTableSection;

  /// Section heading for localized component states.
  ///
  /// In en, this message translates to:
  /// **'States and validation'**
  String get galleryStateSection;

  /// Section heading for PO import/export proof in the gallery.
  ///
  /// In en, this message translates to:
  /// **'PO bridge'**
  String get galleryPoSection;

  /// Localized sample form field label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get galleryCustomerLabel;

  /// Localized sample form field hint in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Company or person name'**
  String get galleryCustomerHint;

  /// Localized sample status field label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get galleryStatusLabel;

  /// Localized sample priority field label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get galleryPriorityLabel;

  /// Localized enabled checkbox label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get galleryEnabledLabel;

  /// Localized selected radio button label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get gallerySelectedLabel;

  /// Localized compact segmented-control label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get galleryCompactLabel;

  /// Localized detailed segmented-control label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get galleryDetailedLabel;

  /// Localized summary tab label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get gallerySummaryTab;

  /// Localized audit tab label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get galleryAuditTab;

  /// Localized start date label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get galleryStartDateLabel;

  /// Localized color picker label in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get galleryAccentColorLabel;

  /// Localized order column caption in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get galleryOrderColumn;

  /// Localized owner column caption in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get galleryOwnerColumn;

  /// Localized state column caption in the gallery.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get galleryStateColumn;

  /// Localized sample status value in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get galleryOpenStatus;

  /// Localized sample status value in the gallery.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get galleryClosedStatus;

  /// Short proof text explaining PO bridge status in the localization gallery.
  ///
  /// In en, this message translates to:
  /// **'ARB remains the runtime source; PO and POT are translator bridge files.'**
  String get galleryPoStatus;

  /// Accessibility label for the ribbon toolbar container.
  ///
  /// In en, this message translates to:
  /// **'Ribbon toolbar'**
  String get ribbonToolbarSemantics;

  /// Empty state shown when a ribbon definition has no tabs.
  ///
  /// In en, this message translates to:
  /// **'No ribbon tabs'**
  String get ribbonNoTabs;

  /// Tooltip/action label for collapsing the ribbon content band.
  ///
  /// In en, this message translates to:
  /// **'Collapse ribbon'**
  String get ribbonCollapse;

  /// Tooltip/action label for expanding the ribbon content band.
  ///
  /// In en, this message translates to:
  /// **'Expand ribbon'**
  String get ribbonExpand;

  /// Accessibility hint for a ribbon command with a menu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get ribbonOpenMenu;

  /// Disabled menu row shown when a dropdown has no menu entries.
  ///
  /// In en, this message translates to:
  /// **'No menu items'**
  String get ribbonMenuEmpty;

  /// Accessibility label for a ribbon group.
  ///
  /// In en, this message translates to:
  /// **'Ribbon group {group}'**
  String ribbonGroupSemantics(String group);

  /// Title for the embeddable ribbon designer.
  ///
  /// In en, this message translates to:
  /// **'Ribbon Designer'**
  String get ribbonDesignerTitle;

  /// Designer command that creates a new ribbon definition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ribbonDesignerNew;

  /// Designer command that adds a tab.
  ///
  /// In en, this message translates to:
  /// **'Add tab'**
  String get ribbonDesignerAddTab;

  /// Designer command that adds a group.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get ribbonDesignerAddGroup;

  /// Designer command that adds an item.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get ribbonDesignerAddItem;

  /// Designer command that deletes the selected node.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ribbonDesignerDelete;

  /// Designer command that exports the current ribbon JSON.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get ribbonDesignerExport;

  /// Designer status shown after export is requested.
  ///
  /// In en, this message translates to:
  /// **'Ribbon JSON exported.'**
  String get ribbonDesignerExported;

  /// Label for the designer preview locale picker.
  ///
  /// In en, this message translates to:
  /// **'Preview locale'**
  String get ribbonDesignerPreviewLocale;

  /// Designer hierarchy pane title.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get ribbonDesignerStructure;

  /// Designer JSON pane title.
  ///
  /// In en, this message translates to:
  /// **'JSON preview'**
  String get ribbonDesignerJsonPreview;

  /// Designer inspector pane title.
  ///
  /// In en, this message translates to:
  /// **'Inspector'**
  String get ribbonDesignerInspector;

  /// Designer inspector empty state.
  ///
  /// In en, this message translates to:
  /// **'Select a tab, group, or item.'**
  String get ribbonDesignerNoSelection;

  /// Designer default status message.
  ///
  /// In en, this message translates to:
  /// **'Ready.'**
  String get ribbonDesignerStatusReady;

  /// Inspector label for fallback caption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get ribbonDesignerCaption;

  /// Inspector label for keytip.
  ///
  /// In en, this message translates to:
  /// **'KeyTip'**
  String get ribbonDesignerKeyTip;

  /// Inspector toggle for contextual tab state.
  ///
  /// In en, this message translates to:
  /// **'Contextual tab'**
  String get ribbonDesignerContextual;

  /// Inspector field for contextual tab group name.
  ///
  /// In en, this message translates to:
  /// **'Context group'**
  String get ribbonDesignerContextGroup;

  /// Inspector field for stable command tag.
  ///
  /// In en, this message translates to:
  /// **'Command tag'**
  String get ribbonDesignerCommandTag;

  /// Inspector field for ribbon item type.
  ///
  /// In en, this message translates to:
  /// **'Item type'**
  String get ribbonDesignerItemType;

  /// Inspector field for fallback tooltip.
  ///
  /// In en, this message translates to:
  /// **'Tooltip'**
  String get ribbonDesignerTooltip;

  /// Inspector field for icon registry key.
  ///
  /// In en, this message translates to:
  /// **'Icon key'**
  String get ribbonDesignerIconKey;

  /// Inspector toggle for enabled state.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get ribbonDesignerEnabled;

  /// Inspector toggle for toggle/checkbox active state.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get ribbonDesignerChecked;

  /// Inspector section title for per-locale captions.
  ///
  /// In en, this message translates to:
  /// **'Localized captions'**
  String get ribbonDesignerLocalizedCaptions;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Large button'**
  String get ribbonItemTypeLarge;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Small button'**
  String get ribbonItemTypeSmall;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Medium button'**
  String get ribbonItemTypeMedium;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Dropdown'**
  String get ribbonItemTypeDropdown;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Split button'**
  String get ribbonItemTypeSplitButton;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Medium dropdown'**
  String get ribbonItemTypeMediumDropdown;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Medium split button'**
  String get ribbonItemTypeMediumSplitButton;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get ribbonItemTypeGallery;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get ribbonItemTypeToggle;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get ribbonItemTypeCheckBox;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get ribbonItemTypeSeparator;

  /// Ribbon item type name.
  ///
  /// In en, this message translates to:
  /// **'Column break'**
  String get ribbonItemTypeColumnBreak;
}

class _FxDesktopLocalizationsDelegate
    extends LocalizationsDelegate<FxDesktopLocalizations> {
  const _FxDesktopLocalizationsDelegate();

  @override
  Future<FxDesktopLocalizations> load(Locale locale) {
    return SynchronousFuture<FxDesktopLocalizations>(
      lookupFxDesktopLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ne', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_FxDesktopLocalizationsDelegate old) => false;
}

FxDesktopLocalizations lookupFxDesktopLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return FxDesktopLocalizationsEn();
    case 'ja':
      return FxDesktopLocalizationsJa();
    case 'ne':
      return FxDesktopLocalizationsNe();
    case 'th':
      return FxDesktopLocalizationsTh();
  }

  throw FlutterError(
    'FxDesktopLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
