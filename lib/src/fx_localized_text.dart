import 'package:flutter/widgets.dart';

/// Serializable localized text used by FxDesktop component models.
///
/// Built-in FxDesktop widget chrome uses [FxDesktopLocalizations]. This value
/// object is for app-authored model text that needs to travel through JSON,
/// such as future designer or ribbon command captions.
@immutable
class FxLocalizedText {
  /// Creates localized text with a required fallback string.
  const FxLocalizedText({required this.fallback, this.values = const {}});

  /// Creates localized text from a JSON map.
  factory FxLocalizedText.fromJson(Map<String, Object?> json) {
    final values = json['values'] as Map<Object?, Object?>? ?? const {};
    return FxLocalizedText(
      fallback: json['fallback'] as String? ?? '',
      values: {
        for (final entry in values.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
      },
    );
  }

  /// Fallback string used when no locale-specific value exists.
  final String fallback;

  /// Localized values keyed by BCP-47-style locale tags.
  final Map<String, String> values;

  /// Resolves the best value for [locale].
  ///
  /// Lookup order is exact locale tag, language-script tag, language-region
  /// tag, language-only tag, then [fallback].
  String resolve(Locale locale) {
    final exact = _localeTag(locale);
    final script = locale.scriptCode == null
        ? null
        : '${locale.languageCode}-${locale.scriptCode}';
    final region = locale.countryCode == null
        ? null
        : '${locale.languageCode}-${locale.countryCode}';
    final language = locale.languageCode;

    for (final key in [exact, script, region, language]) {
      if (key == null) continue;
      final value = values[key];
      if (value != null) {
        return value;
      }
    }

    return fallback;
  }

  /// Converts this value to a deterministic JSON map.
  Map<String, Object?> toJson() {
    return {
      'fallback': fallback,
      'values': Map<String, String>.fromEntries(
        values.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      ),
    };
  }

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() => toJson();
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
