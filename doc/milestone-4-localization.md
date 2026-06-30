# Milestone 4: Localization Foundation

Status: delivered in `v0.4.0`.

Milestone 4 adds a suite-wide localization foundation before the ribbon toolbar
and visual designer work begins. The goal is to make FxDesktop components,
examples, validation messages, semantics, and future designer surfaces
multi-language ready without creating a localization system that fights
Flutter.

The implementation guide is [Localization](localization.md). The delivered
surface includes `FxDesktopLocalizations`, `FxLocalizedText`,
`FxLocalizationGallery`, four ARB locales, PO/POT bridge tooling, PO examples,
and English, Thai, Japanese, Nepali, and RTL smoke screenshots.

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

## Flutter Integration Contract

Applications should be able to wire FxDesktop localization through the standard
Flutter app shape:

```dart
MaterialApp(
  localizationsDelegates: const [
    FxDesktopLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: FxDesktopLocalizations.supportedLocales,
  locale: selectedLocale,
  home: const FxLocalizationGallery(),
)
```

Implementation guidance:

- prefer generated lookup APIs over runtime map lookups for built-in strings;
- use `MaterialLocalizations.of(context)` for date/time formatting and stock
  Material text where possible;
- use `Localizations.override` only for previews/tests or nested examples, not
  as a replacement for app-level locale wiring;
- keep placeholders typed and documented in ARB metadata;
- keep plural/select messages in ARB/intl message syntax rather than manual
  string concatenation;
- respect `Directionality.of(context)` and `TextDirection` in component layout;
- verify that generated localization APIs remain part of the public package
  surface through the public API signature check.

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
lib/l10n/fx_desktop_ja.arb
lib/l10n/fx_desktop_ne.arb
l10n.yaml
tool/fx_l10n.dart
doc/localization.md
doc/localization/po-import-example-th.po
doc/localization/po-import-example-ja.po
doc/localization/po-import-example-ne.po
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

## PO Import Example

Milestone 4 must include example PO import files. Each file should represent one
target locale and round-trip back into the matching ARB file. The examples below
use Thai, but Japanese and Nepali fixtures must follow the same structure.

Expected command shape:

```bash
dart run tool/fx_l10n.dart import-po \
  --input doc/localization/po-import-example-th.po \
  --locale th \
  --output lib/l10n/fx_desktop_th.arb
```

Example PO content:

```po
msgid ""
msgstr ""
"Project-Id-Version: fx_desktop\\n"
"Language: th\\n"
"Content-Type: text/plain; charset=UTF-8\\n"

#. ARB key: gridContextMenuCopySelection
#. Description: Context menu action that copies the selected grid or list rows.
msgctxt "grid.context_menu.copy_selection"
msgid "Copy"
msgstr "คัดลอกส่วนที่เลือก"

#. ARB key: designerEditMenuCopyItem
#. Description: Designer edit-menu command that copies the selected component.
msgctxt "designer.edit_menu.copy_item"
msgid "Copy"
msgstr "คัดลอก"

#. ARB key: colorPickerNoColorButton
#. Description: Button that clears a nullable color value.
msgctxt "color_picker.no_color_button"
msgid "No color"
msgstr "ไม่มีสี"
```

The importer must treat `msgctxt` as part of the identity. Importing by `msgid`
alone is a bug because both `Copy` entries above are intentionally separate.
If an incoming PO file has a missing or unknown `msgctxt`, the importer should
report a warning and leave the existing ARB value unchanged unless an explicit
force flag is supplied.

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

- English ARB source file: `en`.
- Thai ARB source file: `th`.
- Japanese ARB source file: `ja`.
- Nepali ARB source file: `ne`.
- PO/POT export and import fixtures for Thai, Japanese, and Nepali.
- A right-to-left smoke fixture, even if Arabic or Hebrew is not bundled as a
  fully translated release locale yet.

The first translations may be seeded automatically or by developer judgment,
but the generated files must mark their review status clearly in
`doc/localization.md`. Release quality should not depend on one global
search-and-replace pass because context-specific entries may translate
differently.

Minimum seed vocabulary for examples and tests:

| Key context | English | Thai | Japanese | Nepali |
|---|---|---|---|---|
| `gallery.languageEnglish` | English | อังกฤษ | 英語 | अंग्रेजी |
| `gallery.languageThai` | Thai | ไทย | タイ語 | थाई |
| `gallery.languageJapanese` | Japanese | ญี่ปุ่น | 日本語 | जापानी |
| `gallery.languageNepali` | Nepali | เนปาล | ネパール語 | नेपाली |
| `colorPickerNoColorButton` | No color | ไม่มีสี | 色なし | रङ छैन |
| `datePickerEmptyHint` | Select date | เลือกวันที่ | 日付を選択 | मिति चयन गर्नुहोस् |
| `gridContextMenuCopySelection` | Copy | คัดลอกส่วนที่เลือก | 選択範囲をコピー | चयन प्रतिलिपि गर्नुहोस् |
| `designerEditMenuCopyItem` | Copy | คัดลอก | コピー | प्रतिलिपि गर्नुहोस् |

This table is a seed, not a release translation review. Its main purpose is to
prove that identical English strings can remain separate translations by
context.

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

## Localization Gallery

Milestone 4 must ship an example screen that shows the localization framework
working across the FxDesktop suite in one page or one desktop-sized window.
This screen is the main manual and screenshot target for localization.

Required behavior:

- expose a language switcher with English, Thai, Japanese, and Nepali;
- change locale using `Localizations.override` or the app-level
  `locale`/`supportedLocales` flow, matching Flutter guidance;
- keep all components visible in one scrollable desktop surface, not separate
  routes that hide most controls;
- show every existing component family at least once;
- include date/time, color picker, popup/combo, choice controls, navigation
  controls, progress/display controls, ListBox/Grid, lookup/dropdown states,
  validation/helper text, tooltips, and semantic labels where practical;
- include at least one duplicate English source word that changes differently
  by context;
- keep app-authored sample data separate from FxDesktop-owned labels so the
  demo proves both boundaries.

Suggested example layout:

```text
top toolbar
  language segmented control: English | ไทย | 日本語 | नेपाली
  locale code and text-direction indicator
main scroll
  form controls row
  choice controls row
  navigation controls row
  date/time and color row
  ListBox/Grid row
  validation and empty-state row
  PO import status row
```

Screenshot targets:

- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-en.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-th.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-ja.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-ne.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-rtl-smoke.png`.

The localized screenshots should be captured at a desktop width, preferably
1280 px wide, so the review proves this is a framework-wide desktop component
surface rather than a small isolated sample.

## Development Cycles

### Cycle 0: Flutter Native Path And Inventory

Deliver:

- confirm the package-compatible `gen_l10n` setup;
- add `l10n.yaml` plan and dependency decision;
- inventory hardcoded FxDesktop-owned strings;
- inventory component surfaces that already use `MaterialLocalizations`;
- define key naming conventions;
- define four-locale review status fields;
- create `doc/localization.md` draft.

Gate:

```bash
dart run tool/check_release_sync.dart
dart run tool/agent_harness.dart
```

### Cycle 1: ARB Source, Four Locales, And Generated Localizations

Deliver:

- English, Thai, Japanese, and Nepali ARB files;
- generated or package-compatible `FxDesktopLocalizations`;
- `supportedLocales`;
- `localizationsDelegates` integration guidance for app authors;
- lookup helpers and fallback behavior;
- `FxLocalizedText` JSON model;
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
- add the one-window localization gallery with the four-language switcher;
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
- Thai, Japanese, and Nepali PO import examples;
- context-preserving `msgctxt` output;
- duplicate-English tests proving separate context entries remain separate;
- importer warnings for missing/unknown `msgctxt`, placeholder mismatches, and
  untranslated entries.

Gate:

```bash
dart run tool/agent_harness.dart
```

### Cycle 4: Screenshots, RTL Smoke, And Docs

Deliver:

- localized full-suite gallery screenshots for English, Thai, Japanese, and
  Nepali;
- one right-to-left layout smoke screenshot or golden where practical;
- `doc/localization.md`;
- README localization note;
- `doc/developer-guide.md` update;
- `doc/xojo-component-map.md` update.

Screenshot targets:

- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-en.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-th.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-ja.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-ne.png`;
- `doc/screenshots/v0.4.x/localization/fxdesktop-localized-rtl-smoke.png`.

Gate:

```bash
dart run tool/agent_harness.dart
flutter pub publish --dry-run
```

### Cycle 5: Framework Audit And Release Candidate

Deliver:

- API review proving app integration follows Flutter's localization pattern;
- docs review for every localization entry point and PO workflow, including
  `README.md`, `AGENT.md`, `doc/developer-guide.md`,
  `doc/xojo-component-map.md`, `doc/testing.md`, `doc/release-versioning.md`,
  and component milestone docs that mention user-facing strings;
- component coverage report listing localized, app-owned, and deferred strings;
- `dart run tool/fx_l10n.dart audit` or equivalent coverage command;
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
- generated localization coverage for English, Thai, Japanese, and Nepali.

Widget:

- localized component labels;
- localized semantic labels;
- Thai non-Latin rendering;
- Japanese non-Latin rendering;
- Nepali Devanagari rendering;
- fallback when unsupported locale is requested;
- right-to-left direction smoke behavior;
- one-window full-suite localization gallery language switching.

Tooling:

- ARB to POT export;
- ARB to PO export;
- PO to ARB import;
- Thai, Japanese, and Nepali PO import fixtures;
- context-specific duplicate entries;
- placeholder preservation;
- missing/unknown `msgctxt` warnings;
- localization coverage audit.

Release:

- full agent harness;
- `flutter pub publish --dry-run`;
- screenshots for English, Thai, Japanese, Nepali, and RTL smoke;
- public API signature review;
- all-doc localization workflow review;
- component coverage report;
- release-sync check.

## Ribbon Handoff

Milestone 5 ribbon work must consume this foundation:

- user-authored ribbon command text can use `FxLocalizedText`;
- ribbon/designer built-in strings must use `FxDesktopLocalizations`;
- validation messages should expose stable codes and localizable arguments;
- ribbon screenshots should include English, Thai, Japanese, and Nepali proof
  views where practical;
- `.po` import/export should preserve ribbon contexts through `msgctxt`.

## References

- Flutter internationalization: `https://docs.flutter.dev/ui/internationalization`
- GNU gettext PO files: `https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html`

## Definition Of Done

Milestone 4 is done when:

- Flutter-native ARB localization is the package source of truth;
- English, Thai, Japanese, and Nepali localization files exist and are tested;
- `.po`/`.pot` bridge tooling preserves context-specific duplicate strings and
  includes import examples for Thai, Japanese, and Nepali;
- existing FxDesktop-owned component strings are localized or explicitly
  documented as app-owned;
- the one-window full-suite localization gallery can switch all four supported
  locales;
- localized widget and tooling tests pass;
- docs explain ARB-first, PO-bridge localization workflow and app integration;
- all active docs that mention user-facing text, examples, publishing, or
  component development are reconciled with the localization framework;
- API signatures are reviewed for framework-wide localization support;
- component coverage is reconciled across docs and source;
- screenshots prove English, Thai, Japanese, Nepali, and RTL smoke behavior;
- full local harness passes;
- pub.dev dry-run has zero warnings;
- no ribbon implementation is required for this milestone.
