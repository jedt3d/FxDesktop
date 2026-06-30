import 'package:flutter/widgets.dart';

import 'l10n/fx_desktop_localizations.dart';

/// Resolves FxDesktop localizations from [context], falling back to English.
///
/// Apps should still register [FxDesktopLocalizations.delegate] in
/// `MaterialApp.localizationsDelegates`. The fallback keeps legacy tests,
/// isolated widget previews, and partial host integrations from crashing before
/// app-level localization wiring is added.
FxDesktopLocalizations fxDesktopLocalizationsOf(BuildContext context) {
  final localizations = Localizations.of<FxDesktopLocalizations>(
    context,
    FxDesktopLocalizations,
  );
  if (localizations != null) {
    return localizations;
  }

  return lookupFxDesktopLocalizations(
    Localizations.maybeLocaleOf(context) ?? const Locale('en'),
  );
}

/// Public delegate type used by FxDesktop localization integrations.
typedef FxDesktopLocalizationsDelegate =
    LocalizationsDelegate<FxDesktopLocalizations>;

/// Stable localization key metadata for tools and diagnostics.
class FxLocalizationKey {
  /// Creates a localization key with an optional translator context.
  const FxLocalizationKey(this.name, {this.context});

  /// ARB key name.
  final String name;

  /// Translator context, normally exported as PO `msgctxt`.
  final String? context;

  /// Stable map for diagnostics, docs, and generators.
  Map<String, Object?> toTemplateMap() {
    return {'name': name, if (context != null) 'context': context};
  }
}

/// Localization issue categories emitted by FxDesktop tools.
enum FxLocalizationIssueCode {
  /// A locale is missing from one or more source files.
  missingLocale,

  /// A locale file is missing an ARB key.
  missingKey,

  /// Two ARB keys share the same PO context.
  duplicateContext,

  /// A locale tag is invalid or unsupported.
  invalidLocaleTag,

  /// A translation does not preserve all placeholders from the template.
  placeholderMismatch,

  /// A PO import entry used a context that is not known to the ARB template.
  unknownPoContext,

  /// A PO import entry has no translated value.
  untranslatedEntry,
}

/// A structured localization diagnostic.
class FxLocalizationIssue {
  /// Creates a localization diagnostic.
  const FxLocalizationIssue({
    required this.code,
    required this.message,
    this.locale,
    this.key,
  });

  /// Diagnostic category.
  final FxLocalizationIssueCode code;

  /// Human-readable diagnostic text.
  final String message;

  /// Locale associated with the issue, when known.
  final Locale? locale;

  /// Localization key associated with the issue, when known.
  final FxLocalizationKey? key;

  /// Stable map for diagnostics, docs, and generators.
  Map<String, Object?> toTemplateMap() {
    return {
      'code': code.name,
      'message': message,
      if (locale != null) 'locale': _localeTag(locale!),
      if (key != null) 'key': key!.toTemplateMap(),
    };
  }
}

String _localeTag(Locale locale) {
  final parts = [
    locale.languageCode,
    if (locale.scriptCode != null && locale.scriptCode!.isNotEmpty)
      locale.scriptCode!,
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty)
      locale.countryCode!,
  ];
  return parts.join('-');
}
