# Milestone 4: Localization Foundation

Milestone 4 adds a suite-wide localization foundation before the ribbon toolbar
and visual designer work begins. The goal is to make FxDesktop components,
examples, validation messages, semantics, and future designer surfaces
multi-language ready without creating a localization system that fights
Flutter.

Recommended implementation branch:

```bash
feature/m4-localization-foundation
```

Planning-only changes do not bump the package version. Implementation releases
should use the `0.4.x` line unless a broader versioning decision changes before
coding begins.

## Direction

Use Flutter's native localization stack as the primary path:

- `flutter_localizations` for Flutter-provided Material, Cupertino, and widget
  strings.
- `intl` and Flutter `gen_l10n` for generated package localizations.
- `.arb` files as the source-of-truth localization files.
- `l10n.yaml` for generation settings.
- `Localizations`, `LocalizationsDelegate`, `supportedLocales`, and
  `Localizations.override` for runtime behavior and tests.
- `Directionality` and locale-aware text alignment for right-to-left smoke
  coverage.

Support `.po` and `.pot` files as import/export tooling because they are common
in translator workflows, but do not make `.po` the runtime source of truth for
Flutter widgets. The package source should remain ARB-first, with PO as a
bridge format generated from and imported back into ARB.

## Public API Goals

Proposed public names:

- `FxDesktopLocalizations`
- `FxDesktopLocalizationsDelegate`
- `FxLocalizedText`
- `FxLocalizationKey`
- `FxLocalizationIssue`
- `FxLocalizationIssueCode`

Expected implementation files:

```text
lib/src/fx_localizations.dart
lib/src/fx_localized_text.dart
lib/l10n/fx_desktop_en.arb
lib/l10n/fx_desktop_th.arb
l10n.yaml
tool/fx_l10n.dart
test/fx_localizations_test.dart
test/fx_l10n_po_bridge_test.dart
```

If Flutter's generated localization workflow imposes package-specific limits,
Cycle 0 must document the exact constraint and keep the public contract the
same while using the closest Flutter-native package-compatible implementation.

## Text Ownership

There are two text classes:

1. App-authored text
   Component labels, table data, ribbon command captions, and business strings
   supplied by the host app. FxDesktop should render these but not translate
   them unless the model explicitly supports localized values.
2. FxDesktop-owned text
   Built-in button labels, empty states, validation messages, menu labels,
   semantic labels, tooltips, examples, designer chrome, and generated
   diagnostics.

Milestone 4 focuses on FxDesktop-owned text across existing components and the
shared model APIs that future components can reuse.

## Context-Specific Translation Rule

Do not deduplicate translations by English text.

The same English word may require different translations depending on where it
appears. Each user-facing string must have its own key when the context differs,
even if the English fallback is identical.

Examples:

```text
gridContextMenuCopySelection = "Copy"
ribbonClipboardCopyCommand = "Copy"
designerEditMenuCopyItem = "Copy"
colorPickerNoColorButton = "No color"
validationNoColorAllowed = "No color"
```

Search-and-replace can help create a first translation draft, but every
translated occurrence remains an individual copy with its own key, description,
and review path.

ARB requirements:

- use stable descriptive keys, not raw English strings as identifiers;
- include `description` metadata for translator context;
- include placeholder metadata for values such as counts, row numbers, command
  names, and component labels;
- avoid reusing one key only because the English fallback matches.

PO bridge requirements:

- export one PO entry per ARB key;
- write the ARB key and description into translator comments;
- use `msgctxt` to preserve component/context identity;
- keep duplicate `msgid` values as separate entries when `msgctxt` differs;
- import translations by key/context, not by matching only English `msgid`;
- preserve untranslated entries instead of deleting them.

## Localized Text Model

For model-owned text that may travel through JSON, add a small value object:

```dart
@immutable
class FxLocalizedText {
  const FxLocalizedText({
    required this.fallback,
    this.values = const {},
  });

  final String fallback;
  final Map<String, String> values;

  String resolve(Locale locale);
}
```

Use BCP-47-style locale keys such as `en`, `th`, `ja`, `zh-Hans`, and `pt-BR`.
Resolution order:

1. exact locale tag;
2. language-script tag when available;
3. language-only tag;
4. fallback/default string;
5. empty string only for optional text such as tooltips.

This value object is for serializable component models. Built-in FxDesktop UI
strings should use `FxDesktopLocalizations` instead.

## Initial Locale Scope

Required:

- English ARB source file.
- Thai ARB source file as the first non-English proof locale.
- PO/POT export for at least English source strings and Thai translations.
- A right-to-left smoke fixture, even if Arabic or Hebrew is not bundled as a
  fully translated release locale yet.

The Thai translation does not need to be perfect in Cycle 1, but the pipeline
must prove that non-Latin text renders, wraps, screenshots, and survives
package checks.

## Component Coverage

Audit and localize built-in strings in:

- date/time empty hints and picker-facing labels that are not already covered
  by `MaterialLocalizations`;
- color picker actions and null/no-color text;
- table empty/loading/error messages and context-menu labels;
- lookup/dropdown empty states and action labels;
- validation and helper text generated by FxDesktop itself;
- semantic labels and tooltips generated by FxDesktop itself;
- example harness labels that represent package-owned demo chrome.

Do not localize app-supplied table cells, option labels, form captions, or
business data unless a component model explicitly owns those strings.

## Development Cycles

### Cycle 0: Flutter Native Path And Inventory

Deliver:

- confirm the package-compatible `gen_l10n` setup;
- add `l10n.yaml` plan and dependency decision;
- inventory hardcoded FxDesktop-owned strings;
- define key naming conventions;
- create `doc/localization.md` draft.

Gate:

```bash
dart run tool/check_release_sync.dart
dart run tool/agent_harness.dart
```

### Cycle 1: ARB Source And Generated Localizations

Deliver:

- English and Thai ARB files;
- generated or package-compatible `FxDesktopLocalizations`;
- `supportedLocales`;
- lookup helpers and fallback behavior;
- unit tests for exact, language-only, and fallback locale resolution.

Gate:

```bash
dart run tool/agent_harness.dart
```

### Cycle 2: Component Adoption

Deliver:

- replace hardcoded FxDesktop-owned strings in existing controls;
- use `MaterialLocalizations` where Flutter already supplies the correct text
  or formatting;
- keep app-authored text as caller-owned;
- add widget tests for localized visible text and semantics.

Gate:

```bash
dart run tool/agent_harness.dart
```

### Cycle 3: PO/POT Bridge

Deliver:

- `dart run tool/fx_l10n.dart export-po`;
- `dart run tool/fx_l10n.dart import-po`;
- `.pot` template export;
- context-preserving `msgctxt` output;
- duplicate-English tests proving separate context entries remain separate.

Gate:

```bash
dart run tool/agent_harness.dart
```

### Cycle 4: Screenshots, RTL Smoke, And Docs

Deliver:

- localized example screenshots;
- one right-to-left layout smoke screenshot or golden where practical;
- `doc/localization.md`;
- README localization note;
- `doc/developer-guide.md` update;
- `doc/xojo-component-map.md` update.

Screenshot targets:

- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-th.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-rtl-smoke.png`.

Gate:

```bash
dart run tool/agent_harness.dart
flutter pub publish --dry-run
```

### Cycle 5: Release Candidate

Deliver:

- changelog update;
- public API signature update;
- release notes draft;
- final PO/ARB round-trip report;
- package dry-run with zero warnings.

Do not create a version tag until the user explicitly approves the release
candidate.

## Test Matrix

Unit:

- ARB key inventory;
- locale fallback;
- `FxLocalizedText` JSON round trip;
- invalid locale key diagnostics;
- duplicate English text with distinct keys.

Widget:

- localized component labels;
- localized semantic labels;
- Thai non-Latin rendering;
- fallback when unsupported locale is requested;
- right-to-left direction smoke behavior.

Tooling:

- ARB to POT export;
- ARB to PO export;
- PO to ARB import;
- context-specific duplicate entries;
- placeholder preservation.

Release:

- full agent harness;
- `flutter pub publish --dry-run`;
- screenshots for English, Thai, and RTL smoke;
- release-sync check.

## Ribbon Handoff

Milestone 5 ribbon work must consume this foundation:

- user-authored ribbon command text can use `FxLocalizedText`;
- ribbon/designer built-in strings must use `FxDesktopLocalizations`;
- validation messages should expose stable codes and localizable arguments;
- ribbon screenshots should include at least one localized view;
- `.po` import/export should preserve ribbon contexts through `msgctxt`.

## References

- Flutter internationalization: `https://docs.flutter.dev/ui/internationalization`
- GNU gettext PO files: `https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html`

## Definition Of Done

Milestone 4 is done when:

- Flutter-native ARB localization is the package source of truth;
- English and Thai localization files exist and are tested;
- `.po`/`.pot` bridge tooling preserves context-specific duplicate strings;
- existing FxDesktop-owned component strings are localized or explicitly
  documented as app-owned;
- localized widget and tooling tests pass;
- docs explain ARB-first, PO-bridge localization workflow;
- screenshots prove non-English and RTL smoke behavior;
- full local harness passes;
- pub.dev dry-run has zero warnings;
- no ribbon implementation is required for this milestone.
