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
