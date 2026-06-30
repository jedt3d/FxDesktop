# Milestone 5: Ribbon Toolbar And Visual Designer

Milestone 5 is delivered in `v0.5.0`. It adds an Office-style ribbon toolbar
and a visual ribbon designer to FxDesktop. The feature targets Flutter desktop
and Flutter web on large screens. It may work well on iPad-sized touch screens,
but it is not a mobile-phone component and must not introduce a phone-first
layout mode.

This document now serves as the delivered acceptance map plus the original
planning record. The first published surface intentionally focuses on a
dependency-light package core: reusable toolbar, shared model, icon registry,
theme extension, validator, embeddable designer, JSON export, localization, and
release screenshots.

Delivered implementation branch:

```bash
feature/m5-ribbon-toolbar-designer
```

Published release target:

```bash
v0.5.0
```

## Delivered In v0.5.0

- `FxRibbonToolbar`
- `FxRibbonDesigner`
- `FxRibbonDefinition`, `FxRibbonTab`, `FxRibbonGroup`, `FxRibbonItem`,
  `FxRibbonMenuItem`, and `FxRibbonSelection`
- `FxRibbonValidator`, validation issue codes, severities, and JSON validation
- `FxRibbonIconRegistry`, SVG string/asset support, PNG asset/bytes support,
  Material icon support, image-provider support, and placeholder icons
- `FxRibbonThemeData`, `FxRibbonDensity`, and `FxRibbonInteractionMode`
- Jaspr-style `.ribbon` JSON import compatibility for the shared model
- JSON export from the designer through `onExportRequested`
- localized command captions, tooltips, toolbar chrome, and designer chrome for
  English, Thai, Japanese, and Nepali
- `FxRibbonSamples.explorer()`, adapted from
  `jaspr-ribbon-toolbar/examples/explorer.ribbon`
- public exports, component registry entries, README usage, schema/designer
  docs, release screenshots, generated API signature, and PO/POT bridge updates

Deferred after the first release:

- file picker or browser download integration in package core
- drag/drop icon import
- visual reordering of tabs, groups, and items
- full dropdown menu item editor in the designer
- designer undo/redo snapshots
- Xojo code generation and Jaspr-compatible export mode
- separate unattended `tool/ribbon_cycle.dart` runner; the release uses the
  existing package harness plus focused ribbon, localization, screenshot, and
  pub.dev checks

## Source Material

The primary source of transferable implementation knowledge is:

- `https://github.com/jedt3d/jaspr-ribbon-toolbar`

Use it for:

- Dart model structure.
- `.ribbon` JSON schema.
- icon registry and embedded icon bundle ideas.
- control type vocabulary.
- layout and hit-test decisions.
- renderer and designer decomposition.
- tutorial/example expectations.
- report structure, milestone screenshots, and the single-command verification
  habit from the Jaspr work.

The design ancestor is:

- `https://github.com/jedt3d/XjRibbon`

Use it for:

- original Xojo component semantics.
- Desktop/Web parity decisions.
- keytip behavior.
- designer workflow.
- control type taxonomy.
- color and layout intent.

Do not modify either upstream repository from this work. Transfer only the
architecture, schema knowledge, and behavior decisions into FxDesktop.
Prefer the Jaspr repository over XjRibbon whenever Dart implementation details
conflict with original Xojo ancestry.

## Flutter Platform Direction

The Jaspr implementation renders to an HTML canvas. FxDesktop should not copy
that rendering strategy blindly. Flutter gives us better platform-native
building blocks for accessibility, focus, gestures, theming, menu overlays, and
tests.

Milestone 5 should be widget-first:

- use normal Flutter widgets for items, groups, tabs, menus, focus, semantics,
  and tooltips;
- use a small pure layout engine for deterministic sizing and tests;
- use `CustomPainter` only for visual effects that are awkward as widgets;
- use Flutter menu and overlay primitives instead of a hand-rolled canvas menu
  unless their behavior proves insufficient.

Useful Flutter APIs for this milestone:

- `FocusableActionDetector` for combining focus, shortcuts, actions, hover, and
  enabled state in custom controls.
- `Shortcuts`, `Actions`, and `Intent` for keytips and keyboard activation.
- `MenuAnchor`, `MenuItemButton`, `SubmenuButton`, and `MenuStyle` for ordinary
  dropdown menus.
- `OverlayPortal` or `OverlayEntry` for custom ribbon overlays that must align
  with split-button arrows or designer popovers.
- `Semantics` for tab, group, item, checked/toggled, menu, and disabled state.
- `Tooltip` for mouse hover and long-press affordances.
- `GestureDetector`, `Listener`, and `MouseRegion` for pointer-kind aware
  mouse, trackpad, stylus, and touch behavior.
- `ThemeExtension` or an FxDesktop theme extension for ribbon colors, density,
  and state layers.
- `ButtonStyle`, `MenuStyle`, `TooltipThemeData`, `ScrollbarThemeData`,
  `VisualDensity`, and `WidgetStateProperty` for a Flutter-native style-sheet
  surface instead of a CSS-like parallel system.

## Goals

Deliver two public feature families:

1. `FxRibbonToolbar`
   A reusable large-screen Flutter ribbon component for desktop and web.

2. `FxRibbonDesigner`
   A visual editor for ribbon definitions that can be embedded in an app or
   used in the example harness.

Both should share the same model and `.ribbon` import/export layer.

## Non-Goals

Do not include these in the first implementation milestone:

- mobile-phone adaptive drawer or bottom navigation replacement;
- full Microsoft Ribbon Framework clone;
- native OS menu bar replacement;
- formula/spreadsheet-style ribbon galleries;
- LSP server or VS Code extension;
- Xojo code generation as a required first release feature;
- file picker dependency in the package core;
- platform-specific native code;
- mutable global icon registry.

The designer may expose import/export callbacks and text download hooks without
owning file-system or browser-download dependencies.

## Public Naming

All public APIs must use the `Fx*` prefix.

Proposed public model and widget names:

- `FxRibbonToolbar`
- `FxRibbonDesigner`
- `FxRibbonDefinition`
- `FxRibbonTab`
- `FxRibbonGroup`
- `FxRibbonItem`
- `FxRibbonMenuItem`
- `FxRibbonItemType`
- `FxRibbonIconRegistry`
- `FxRibbonIconSource`
- `FxRibbonIconKind`
- `FxRibbonEvent`
- `FxRibbonItemPressedEvent`
- `FxRibbonMenuActionEvent`
- `FxRibbonTabChangedEvent`
- `FxRibbonCollapseChangedEvent`
- `FxRibbonSelection`
- `FxRibbonValidationResult`
- `FxRibbonDensity`
- `FxRibbonInteractionMode`
- `FxRibbonThemeData`
- `FxRibbonLocalizedText`

Avoid unprefixed names like `RibbonDefinition` in public FxDesktop exports.

## File Layout

Delivered implementation files:

```text
lib/src/fx_ribbon_models.dart
lib/src/fx_ribbon_icons.dart
lib/src/fx_ribbon_layout.dart
lib/src/fx_ribbon_toolbar.dart
lib/src/fx_ribbon_designer.dart
lib/src/fx_ribbon_theme.dart
```

Delivered tests:

```text
test/fx_ribbon_models_test.dart
test/fx_ribbon_layout_test.dart
test/fx_ribbon_toolbar_test.dart
test/fx_ribbon_designer_test.dart
test/release_screenshot_test.dart
```

Delivered examples and docs:

```text
doc/milestone-5-ribbon-toolbar-designer.md
doc/ribbon-schema.md
doc/ribbon-designer.md
doc/screenshots/v0.5.0/ribbon/
```

Release checks:

```bash
flutter analyze
flutter test test/fx_ribbon_models_test.dart test/fx_ribbon_layout_test.dart test/fx_ribbon_toolbar_test.dart test/fx_ribbon_designer_test.dart
dart run tool/fx_l10n.dart audit
flutter test --update-goldens test/release_screenshot_test.dart
dart run tool/agent_harness.dart --update-api
dart run tool/agent_harness.dart
```

`lib/fx_desktop.dart` exports the ribbon files in `v0.5.0`.

## Model Contract

The ribbon model must be pure Dart data. It should be serializable, diffable,
testable on the VM, and usable by renderer, designer, generators, and future
tooling.

### Definition

`FxRibbonDefinition` should contain:

- `version`
- `projectType`
- ordered `tabs`
- optional embedded icon bundle
- optional localization bundle for captions, tooltips, semantic labels, and
  designer-authored display text
- optional metadata such as name, description, createdBy, and updatedAt only if
  useful for the designer

Use schema versioning from day one. Prefer:

```text
version: "1.0"
projectType: "flutter"
```

The importer should understand the Jaspr `.ribbon` schema version `"2.0"` and
map it into FxDesktop types. The exporter may write the FxDesktop schema while
optionally providing a compatibility export for Jaspr/XjRibbon-inspired
bundles.

### Localized Text

The ribbon must support multi-language command definitions without forcing app
authors to rebuild widgets per locale. Keep the source model readable by
retaining simple fallback string fields and adding optional locale maps.

Proposed shape:

```dart
@immutable
class FxRibbonLocalizedText {
  const FxRibbonLocalizedText({
    required this.fallback,
    this.values = const {},
  });

  final String fallback;
  final Map<String, String> values;

  String resolve(Locale locale);
}
```

Use BCP-47-style locale keys such as `en`, `th`, `ja`, `zh-Hans`, and
`pt-BR`. Resolution order:

1. exact locale tag;
2. language-script tag when available;
3. language-only tag;
4. fallback/default string;
5. empty string only for optional text such as tooltips.

For schema compatibility and developer ergonomics:

- `caption`, `tooltipText`, and `semanticLabel` remain the default/fallback
  strings;
- optional maps such as `localizedCaptions`, `localizedTooltips`, and
  `localizedSemanticLabels` hold per-locale overrides;
- importers should map older Jaspr/XjRibbon captions to fallback strings;
- exporters should keep fallback strings even when locale maps exist;
- validation should warn when a locale map contains blank text, invalid locale
  keys, or a missing fallback caption.

The toolbar should resolve localized labels from `Localizations.localeOf(context)`
unless a widget-level locale override is provided for preview/testing.

### Tabs

`FxRibbonTab` should contain:

- `caption`
- `groups`
- `isContextual`
- `contextGroup`
- `accentColor`
- `keyTip`
- optional stable `id`

Contextual tabs are hidden until their context group is active. Standard tabs
are always visible.

### Groups

`FxRibbonGroup` should contain:

- `caption`
- `items`
- optional stable `id`
- optional overflow/collapse hints for future adaptive behavior

Groups are visual and semantic containers. They should expose a group label to
accessibility tools.

### Items

Support the seven source item kinds:

| Item kind | Behavior |
|---|---|
| `large` | Large icon with caption, primary command. |
| `small` | Small icon with caption, stacks three per column. |
| `dropdown` | Whole item opens menu. |
| `splitButton` | Main body fires command, arrow opens menu. |
| `toggle` | Command with persistent active state. |
| `checkBox` | Checkbox-style item with checked state. |
| `separator` | Non-interactive group divider. |

`FxRibbonItem` should contain:

- `caption`
- `tag`
- `itemType`
- `isEnabled`
- `isToggleActive`
- `tooltipText`
- `iconKey`
- `keyTip`
- `menuItems`
- optional `semanticLabel`

The `tag` is the stable command identifier and is what applications should
handle in events.

### Events

Prefer sealed event classes when the package SDK supports them cleanly:

- item command pressed
- dropdown menu item selected
- tab changed
- collapse state changed
- toggle/checkbox state requested
- designer selection changed
- designer model changed

Applications should receive semantic events rather than raw pointer
coordinates.

## Icon Strategy

The toolbar must support SVG icons when practical and PNG icons as a fallback.
Icons must be referenced by `iconKey` from the model, not by directly storing
Flutter widgets on `FxRibbonItem`.

### Required Icon Sources

Support these source types in the registry:

- `materialIcon`
  Runtime-only `IconData` for apps that want quick Material symbol mapping.
- `svgAsset`
  SVG from Flutter assets.
- `svgString`
  Embedded SVG text from `.ribbon` bundles.
- `pngAsset`
  PNG from Flutter assets.
- `pngBytes`
  Embedded PNG bytes or data URL from `.ribbon` bundles.
- `imageProvider`
  Runtime-only escape hatch for app-specific image sources.

### SVG Dependency Decision

Flutter does not provide full SVG widget rendering in the framework itself.
The preferred implementation path is to add `flutter_svg` only if the dependency
stays compatible with the package's Flutter SDK floor, web target, desktop
targets, pub.dev score, and license expectations.

If adding `flutter_svg` is not acceptable, Phase 4 should still ship:

- PNG icons;
- Material icon support;
- placeholder icons using the first caption letter;
- an icon renderer interface so SVG support can be added later without breaking
  public model APIs.

### Icon Acceptance Criteria

- Missing icons render a stable placeholder.
- Disabled icons visibly dim.
- SVG and PNG paths can both be tested.
- Embedded icon bundle round-trips through JSON.
- The designer can assign, replace, and remove icons by key.
- Icon rendering works in desktop widget tests and web smoke builds.

## Toolbar Rendering

`FxRibbonToolbar` should be a `StatefulWidget` unless all interaction state is
fully controlled by the caller. The first public API should support both
controlled and uncontrolled usage.

Proposed constructor shape:

```dart
FxRibbonToolbar({
  required FxRibbonDefinition definition,
  FxRibbonIconRegistry icons = const FxRibbonIconRegistry.empty(),
  int activeTabIndex = 0,
  bool collapsed = false,
  Set<String> visibleContextGroups = const {},
  FxRibbonDensity density = FxRibbonDensity.regular,
  FxRibbonInteractionMode interactionMode = FxRibbonInteractionMode.auto,
  ValueChanged<FxRibbonEvent>? onEvent,
  ValueChanged<int>? onTabChanged,
  ValueChanged<bool>? onCollapsedChanged,
})
```

### Visual Structure

Toolbar layout:

```text
tab strip
content band
  group
    item columns
    group caption
  group separator
collapse chevron
```

The renderer must preserve these source decisions:

- large icon target around 32 px in regular density;
- small icon target around 16 px in regular density;
- small and checkbox items stack three per column;
- split button has separate body and arrow hit regions;
- group caption is centered under controls;
- contextual tab accent is visible but not overpowering;
- active tab is obvious in both light and dark themes;
- collapsed mode leaves tab strip visible.

### Flutter Enhancements

Use Flutter to improve the port:

- Widget-based controls instead of a full canvas renderer so semantics,
  focus, hover, and hit testing are first-class.
- `MenuAnchor` for ordinary dropdown and split-button menus.
- `OverlayPortal` or `OverlayEntry` only where `MenuAnchor` cannot match
  ribbon positioning or designer popovers.
- `FocusableActionDetector` on each command item so mouse hover, focus rings,
  keyboard activation, and enabled state share one control path.
- `Semantics` labels for tab, group, command, checked/toggled state, disabled
  state, and menu availability.
- `Tooltip` for hover and long-press.
- `Theme.of(context)`, `ColorScheme`, high contrast, and text scale awareness.
- `MediaQuery` to adapt hit target size and collapse behavior without creating
  a mobile layout.
- `ScrollConfiguration` plus visible scroll affordances when the ribbon is
  wider than the viewport.

## Mouse, Touch, Keyboard

The ribbon must support both mouse click and touch screen interaction.

### Mouse

Required:

- hover states for tabs and items;
- pressed state;
- pointer cursor on enabled commands;
- tooltips;
- split-button body and arrow hit testing;
- menu dismissal when clicking outside;
- double-click or chevron collapse behavior.

### Touch

Required:

- tap activates commands;
- tap on split arrow opens menu;
- long press can expose tooltip/help where Flutter supports it;
- no required hover-only affordance;
- minimum touch hit target in touch mode should be 44 px where practical;
- dense desktop mode may remain compact, but touch mode must be selectable.

Add:

```dart
enum FxRibbonInteractionMode {
  auto,
  mouse,
  touch,
}
```

`auto` should track the most recent pointer kind and use larger hit targets for
touch without changing the visual grammar into a mobile toolbar.

### Keyboard

Required:

- Tab/Shift+Tab focus traversal into and out of the ribbon.
- Arrow navigation across tabs and visible items.
- Enter/Space activate command items.
- Escape closes menus or exits keytip mode.
- F6 activates keytip mode.

Keytips:

- support manual `keyTip` from the model;
- auto-generate missing keytips deterministically;
- show badges over tabs/items in a high-contrast style;
- support a two-level flow: first choose tab, then choose item;
- do not rely only on Alt because browsers and OSes often intercept Alt
  shortcuts.

## Localization

Milestone 5 must consume the suite-wide localization foundation from
`doc/milestone-4-localization.md`. Do not build a separate ribbon-only
translation system.

There are two ribbon localization surfaces:

1. User-authored ribbon definition text:
   tab captions, group captions, item captions, tooltips, semantic labels, menu
   item captions, sample template names, and contextual group labels.
2. Built-in FxDesktop text:
   designer buttons, inspector labels, validation messages, empty states,
   import/export actions, undo/redo labels, keytip announcements, collapse
   affordances, and accessibility descriptions.

Delivered public contract:

- `FxRibbonToolbar` and `FxRibbonDesigner` resolve built-in text through the
  shared `FxDesktopLocalizations` API.
- `FxRibbonDefinition` owns user-authored localized command text through
  fallback strings plus optional locale maps.
- `FxRibbonLocalizedText` is a public alias to suite-wide `FxLocalizedText`.
- `FxRibbonValidator` exposes stable error/warning codes and issue paths; the
  first release stores issue messages as developer-facing English diagnostics.
- Public callbacks and events carry stable tags/codes, not translated strings,
  so app logic remains locale-independent.

Locale behavior:

- follow `Localizations.localeOf(context)` by default;
- allow a widget-level locale override for designer preview and tests;
- respect `Directionality.of(context)` and avoid hardcoded left-to-right layout
  assumptions in text alignment, menu anchoring, and overflow indicators;
- keep command event tags stable across languages;
- avoid deriving keytips from translated text unless no explicit keytip exists,
  because translated captions may not map cleanly to Latin keyboard input;
- preserve context-specific localization keys so duplicate English words such
  as "Copy" or "Open" can be translated differently in toolbar, menu, designer,
  and validation contexts;
- cover English, Thai, Japanese, and Nepali consistently with the suite-wide
  localization milestone;
- keep ribbon/designer PO import/export examples context-specific through
  `msgctxt`.

Designer requirements:

- show and edit fallback/default text;
- show locale-specific text maps in the inspector or a localized-text editor;
- preview the ribbon in the selected locale without mutating the saved model;
- warn when a visible caption has no fallback;
- preserve localized text during import/export, copy/paste, undo/redo, and
  template creation.

Tests:

- resolve exact locale, language-only fallback, and default fallback;
- render toolbar command captions in a non-English locale;
- keep events stable when labels change by locale;
- localize designer action labels and validation messages;
- verify English, Thai, Japanese, and Nepali ribbon/designer labels;
- verify right-to-left text direction smoke behavior where practical;
- capture at least one localized screenshot in the release cycle.

## Designer

`FxRibbonDesigner` is an embeddable Flutter widget, not a separate app locked
to one shell. The example app or a product app can host it as a full-screen
page.

### Designer Layout

Preferred desktop layout:

```text
top command row
preview ribbon
main split
  left: hierarchy
  center: optional JSON/schema preview or canvas-free live preview
  right: inspector
bottom status/errors row
```

Use existing FxDesktop controls where they prove the suite:

- `FxListBox` or `FxGrid` for hierarchy/menu item editing;
- `FxTextField`, `FxTextArea`, `FxPopupMenu`, `FxCheckBox`, `FxColorPicker`;
- `FxSegmentedButton`, `FxTabPanel`, or `FxPagePanel` for inspector modes;
- `FxUndoController` for designer undo/redo snapshots.

### Designer MVP Features

Delivered in `v0.5.0`:

- create new definition;
- export definition to JSON string;
- add/delete tabs;
- add/delete groups;
- add/delete items;
- edit caption, tag, item type, enabled state, tooltip, keytip, icon key;
- edit localized captions;
- edit contextual tab fields;
- preview using a selected locale;
- live preview using `FxRibbonToolbar`;
- validation panel;
- status row.

Deferred after the first release:

- load definition from JSON string inside the package widget;
- reorder tabs, groups, and items;
- edit localized tooltips and semantic labels in the visual inspector;
- edit dropdown menu items visually;
- dirty state;
- undo/redo through snapshot or model-command history;
- copy JSON to clipboard where Flutter platform support exists;
- sample templates such as File Explorer-style Home/View tabs;
- icon manager with drag/drop upload in app shells that provide bytes;
- Xojo code generation;
- Jaspr-compatible export mode;
- command search;
- command palette for large definitions;
- designer keyboard shortcuts.

### Designer Import/Export

The package core should not depend on a file picker. Instead expose callbacks:

```dart
Future<String?> Function()? onRequestOpenJson;
Future<void> Function(String json)? onRequestSaveJson;
Future<FxRibbonIconSource?> Function()? onRequestIconImport;
```

The example app may implement simple text import/export. A product app can wire
real desktop file dialogs or web download/upload separately.

## Adaptive Large-Screen Behavior

The ribbon should work well at desktop and iPad-sized widths without becoming a
phone component.

Required:

- wide desktop: all groups visible when space allows;
- medium desktop/tablet: horizontal scroll or group overflow affordance;
- collapsed state: tab strip only;
- touch mode: larger item hit targets and more forgiving menu spacing;
- text scaling: preserve usability up to reasonable desktop accessibility text
  scale;
- minimum width: if the viewport is too narrow, scroll horizontally instead of
  switching to a mobile drawer.

Future adaptive ideas:

- group collapse priority;
- compact group buttons;
- overflow menu per group;
- remembered collapse state per window width.

## Flutter Theme And Style Sheet Strategy

Use Flutter's theme system as the ribbon style sheet. Do not introduce a
separate CSS-like format for the first release. The package should expose a
small ribbon theme object for ribbon-specific tokens, derive defaults from
`Theme.of(context)`, and let apps override the result through normal Flutter
theme composition.

Primary API:

```dart
@immutable
class FxRibbonThemeData extends ThemeExtension<FxRibbonThemeData> {
  const FxRibbonThemeData({
    this.density,
    this.interactionMode,
    this.backgroundColor,
    this.contentBandColor,
    this.activeTabColor,
    this.contextualAccentColor,
    this.groupSeparatorColor,
    this.itemStyle,
    this.tabStyle,
    this.menuStyle,
    this.keytipStyle,
    this.designerValidationStyle,
  });

  static FxRibbonThemeData fromColorScheme(ColorScheme colorScheme);
}
```

The toolbar and designer should resolve styles in this order:

1. widget-level override such as `FxRibbonToolbar(theme: ...)`;
2. inherited `ThemeExtension<FxRibbonThemeData>`;
3. defaults derived from `ColorScheme`, `TextTheme`, `VisualDensity`, and
   `MediaQuery`;
4. hard-coded fallback constants only for values that cannot be inferred.

Theme data should cover:

- background and content band colors;
- tab text, hover, active, and focus states;
- contextual tab accent wash;
- group caption text and separator;
- item hover, pressed, selected, toggled, disabled, and focus states;
- split-button body and arrow state colors;
- keytip badge foreground/background/border;
- menu surface, menu hover, menu disabled, and menu shadow;
- designer validation colors for warning/error/info states;
- designer selection, drag target, inspector field, and dirty-state accents.

Map as much as possible to Flutter-native style objects:

- `ColorScheme` for base surfaces, accents, disabled opacity, and error colors;
- `TextTheme` for tab labels, item captions, group captions, and inspector
  fields;
- `VisualDensity` plus `FxRibbonDensity` for compact, regular, and touch
  sizing;
- `ButtonStyle` or ribbon-local style slots backed by `WidgetStateProperty`
  for hover, focus, pressed, disabled, and selected states;
- `MenuStyle` for dropdown and split-button menus;
- `TooltipThemeData` for hover and long-press help;
- `ScrollbarThemeData` for horizontal overflow at 1024 px and medium widths.

Required modes:

- light;
- dark;
- high contrast, derived from `MediaQuery.highContrast` where available;
- compact density for dense desktop tools;
- regular density for the default 1280 px experience;
- touch density with hit targets near 44 px where practical.

Viewport requirements:

- 1280 px wide is the primary design target and should show a useful ribbon
  without immediate overflow for the bundled example definitions.
- 1024 px wide is the minimum supported target. The ribbon must remain usable
  through horizontal scroll, group overflow, or collapse behavior, not by
  switching into a phone navigation pattern.
- Wider desktop windows may expand whitespace and group spacing, but should not
  change the semantic model or command order.

Designer theming should reuse the same `FxRibbonThemeData` preview path so a
user can edit a definition and see the exact themed toolbar that an app would
render. The designer shell may add its own panel colors, selection outlines, and
validation styles through the same extension object.

## Accessibility

Acceptance criteria:

- Each visible tab is exposed as a tab or button-like semantic node.
- Each group has a label.
- Each command item has a label, enabled state, and activation action.
- Toggle and checkbox items expose checked/toggled state.
- Dropdown and split-button items expose menu availability.
- Collapsed state is announced.
- Keyboard-only operation can activate the same commands as mouse and touch.
- The designer's hierarchy and inspector fields have labels.
- Semantic labels resolve through the same locale fallback path as visible
  labels, while command tags remain locale-independent.

## Validation

Add `FxRibbonValidator`.

Validation should report:

- invalid JSON;
- unsupported schema version;
- missing tabs array;
- tab without caption;
- group without caption;
- item without tag when interactive;
- duplicate tags;
- unknown item type;
- dropdown/split-button without menu items if strict mode is enabled;
- contextual tab without context group;
- icon key not found in registry;
- menu item without tag;
- invalid color value.
- invalid locale key in localized text maps;
- localized caption map without fallback/default caption.

Expose warnings separately from errors so the designer can show soft guidance.

## Autonomous Development Cycles

This section records the original unattended-cycle plan. The delivered
`v0.5.0` release did not add a separate `tool/ribbon_cycle.dart`; instead it
uses the existing `tool/agent_harness.dart` plus focused ribbon tests,
localization audit, release screenshots, release-sync checks, Dartdoc, and
pub.dev dry-run. Keep the cycle notes below as the historical phase map and as
guidance for future automation, not as a list of files that must exist in
`v0.5.0`.

### One-Command Contract

Cycle 0 should add a dedicated runner:

```bash
dart run tool/ribbon_cycle.dart --all
```

The runner should also support targeted resumes:

```bash
dart run tool/ribbon_cycle.dart --cycle 3
dart run tool/ribbon_cycle.dart --from 4 --to 6
dart run tool/ribbon_cycle.dart --all --viewport=1280x720 --min-viewport=1024x768
```

Each successful cycle should:

- run the cycle's required format, analyze, test, build, and screenshot gates;
- append a dated entry to `doc/ribbon-cycle-log.md`;
- save screenshots under `doc/screenshots/v0.5.x/ribbon/` when the cycle has a
  visual gate;
- record the exact command output summary, not full noisy logs;
- leave a clear next-cycle command.

Each failed cycle should:

- stop immediately before starting later cycles;
- append the failing command and short diagnosis to `doc/ribbon-cycle-log.md`;
- keep diagnostic screenshots when a visual/browser check fails;
- avoid version bumps, tags, and release changes;
- leave the working tree in a reviewable state.

The runner should call the existing package harness instead of duplicating it.
Use `dart run tool/agent_harness.dart` as the full-package gate and add
ribbon-specific subcommands only where the existing harness does not cover
screenshots, web smoke routes, or cycle logging.

### Cycle 0: Harness, Fixtures, And Evidence Loop

Purpose: make the next three-hour unattended run controllable before building
feature code.

Deliver:

- `tool/ribbon_cycle.dart`;
- cycle report format in `doc/ribbon-cycle-log.md`;
- screenshot output directories;
- Jaspr fixture import locations, copied only into FxDesktop test fixtures;
- README or doc pointer for the one-command workflow.

Use Jaspr material:

- example `.ribbon` definitions;
- small SVG command icons such as copy, cut, paste, delete, details, hide,
  navigation, rename, and table where license-compatible;
- screenshot names and milestone cadence as evidence examples.

Gate:

```bash
dart format tool doc test lib example
dart run tool/check_release_sync.dart
dart run tool/agent_harness.dart
```

No screenshot is required yet unless the runner itself needs a diagnostic.

### Cycle 1: Pure Model, Schema, And Validator

Purpose: establish the Dart model shared by toolbar, designer, screenshots, and
future tooling.

Deliver:

- pure Dart ribbon model;
- `FxRibbonLocalizedText` and locale-map serialization;
- JSON import/export;
- Jaspr `.ribbon` compatibility importer;
- validator with stable warning/error codes and localizable arguments;
- schema docs draft.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 1
```

Required tests:

- round-trip FxDesktop schema;
- parse Jaspr fixture;
- duplicate command tags;
- invalid icon keys;
- localized caption fallback resolution;
- invalid locale key warnings;
- contextual tab validation;
- menu item validation.

No screenshot is required.

### Cycle 2: Theme, Icon, And Style Infrastructure

Purpose: make theme and icon decisions before the toolbar layout depends on
them.

Deliver:

- `FxRibbonThemeData` as a `ThemeExtension`;
- `FxRibbonDensity` and `FxRibbonInteractionMode`;
- shared `FxDesktopLocalizations` keys for toolbar and designer chrome plus
  sample non-English translations;
- icon registry with Material, SVG if accepted, PNG, embedded, and placeholder
  paths;
- disabled, hover, active, focus, keytip, menu, and validation style slots;
- dependency decision note for `flutter_svg`.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 2
```

Required tests:

- theme defaults from light and dark `ColorScheme`;
- compact, regular, and touch density resolution;
- built-in designer/toolbar strings resolve from `Localizations`;
- icon lookup and missing placeholder;
- SVG or documented PNG fallback behavior;
- disabled icon styling.

Screenshot:

- optional icon registry smoke screenshot if SVG/PNG rendering is implemented.

### Cycle 3: Toolbar MVP At 1280 px

Purpose: ship the first usable `FxRibbonToolbar` with ordinary commands.

Deliver:

- tab strip;
- content band;
- standard tabs;
- groups;
- large buttons;
- small stacked buttons;
- separators;
- command events;
- localized captions, tooltips, and semantic labels;
- hover, pressed, disabled, focus, tooltip, and semantics state;
- example route.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 3 --viewport=1280x720
```

Required tests:

- render seed definition;
- change active tab;
- activate enabled command;
- ignore disabled command;
- resolve command labels from a non-English locale while keeping event tags
  stable;
- focus and keyboard activation;
- semantics labels.

Required screenshot:

- `toolbar-mvp-1280-light.png`.

### Cycle 4: Menus, Split Buttons, Toggles, Contextual Tabs, Collapse

Purpose: complete the source toolbar behavior before polishing layout.

Deliver:

- dropdown menus;
- split-button primary and arrow regions;
- toggle and checkbox state events;
- contextual tabs and visible context groups;
- collapse/expand behavior;
- keytip MVP through F6.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 4 --viewport=1280x720
```

Required tests:

- dropdown opens and emits menu item tag;
- split body emits the primary tag;
- split arrow opens menu;
- toggle and checkbox events include next state;
- contextual tabs show/hide by context group;
- collapsed state keeps tab strip visible;
- Escape closes menus and exits keytip mode.

Required screenshots:

- `toolbar-dropdown-1280-light.png`;
- `toolbar-contextual-1280-dark.png`;
- `toolbar-keytips-1280-high-contrast.png`.

### Cycle 5: 1024 px, Touch, Text Scale, And Accessibility Polish

Purpose: verify the large-screen target boundary and pointer-kind behavior.

Deliver:

- 1024 px horizontal overflow or group overflow behavior;
- touch hit target policy;
- pointer-kind aware interaction mode;
- text scale review;
- high contrast pass;
- scroll affordances.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 5 --viewport=1024x768
```

Required tests:

- touch tap activates commands;
- touch split arrow opens menu;
- touch mode increases effective hit targets;
- mouse hover remains mouse-only;
- 1024 px layout stays usable without overlap;
- text scale does not overlap item labels or group captions;
- semantics include tab, group, menu, disabled, checked, and collapsed state.

Required screenshots:

- `toolbar-1024-regular-light.png`;
- `toolbar-1024-touch-light.png`;
- `toolbar-1280-dark.png`.

### Cycle 6: Designer MVP

Purpose: build the embeddable visual designer around the same model and toolbar
preview.

Deliver:

- `FxRibbonDesigner`;
- top command row;
- live preview;
- hierarchy editor;
- inspector;
- add/delete/reorder tabs, groups, items, and menu items;
- localized built-in designer labels;
- validation panel;
- dirty state;
- undo/redo;
- import/export callbacks.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 6 --viewport=1280x800
```

Required tests:

- render seed model;
- add tab/group/item;
- inspector edits update preview;
- locale switch updates preview text without changing command tags;
- reorder and delete;
- validation errors display through localized messages;
- undo/redo restores snapshots;
- export JSON parses back.

Required screenshot:

- `designer-mvp-1280-light.png`.

### Cycle 7: Designer Icon, Template, And Import/Export Polish

Purpose: bring the designer near feature parity with the Jaspr visual designer
without making it a separate product.

Deliver:

- icon assignment and removal;
- embedded icon preview;
- File Explorer-style sample template;
- localized text editor for captions, tooltips, and semantic labels;
- JSON preview or schema panel;
- copy-to-clipboard path where Flutter supports it;
- designer keyboard shortcuts;
- focus-preserving refresh after inspector edits.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 7 --viewport=1280x800
```

Required tests:

- assign SVG or PNG icon by key;
- missing icon warning appears;
- import/export preserves embedded icon bundle;
- import/export preserves localized text maps;
- template opens and validates;
- focus remains in edited inspector field after model refresh;
- keyboard shortcuts call the same commands as buttons.

Required screenshots:

- `designer-icons-1280-light.png`;
- `designer-validation-1280-dark.png`.

### Cycle 8: Docs, Screenshots, Pub Dry Run, And Release Candidate

Purpose: reconcile all public package surfaces before tagging a 0.5.x release.

Deliver:

- README ribbon section with component and designer screenshots;
- `doc/ribbon-schema.md`;
- `doc/ribbon-designer.md`;
- updated `doc/developer-guide.md`;
- updated `doc/xojo-component-map.md`;
- updated `AGENT.md`;
- changelog entry;
- public API signature update;
- release notes draft.

Gate:

```bash
dart run tool/ribbon_cycle.dart --cycle 8 --viewport=1280x720 --min-viewport=1024x768
```

Required validation:

- full package harness;
- web smoke test;
- screenshot capture;
- `flutter pub publish --dry-run`;
- release sync check;
- GitHub workflow review.

Required screenshots:

- `toolbar-release-1280-light.png`;
- `toolbar-release-1280-dark.png`;
- `toolbar-release-1024-light.png`;
- `designer-release-1280-light.png`;
- `designer-release-1280-dark.png`;
- `toolbar-release-1280-localized.png`.

No tag should be created by this cycle unless the user explicitly grants a
release/tagging step after reviewing the dry-run output.

### Screenshot Cadence

Capture screenshots only when they prove user-facing progress or diagnose a
failure. Required visual checkpoints:

| Cycle | Viewports | Screenshots |
|---|---|---|
| 3 | 1280x720 | toolbar MVP light |
| 4 | 1280x720 | dropdown, contextual dark, keytips high contrast |
| 5 | 1024x768, 1280x720 | minimum width, touch density, dark mode |
| 6 | 1280x800 | designer MVP |
| 7 | 1280x800 | designer icons, designer validation |
| 8 | 1024x768, 1280x720, 1280x800 | release toolbar, designer, and localized proof |

The 1280 px screenshots are the primary review target. The 1024 px screenshots
are minimum-width proof. Mobile-phone screenshots are out of scope.

### Unattended Run Policy

For a future three-hour autonomous implementation run, start with Cycle 0,
commit only after a cycle passes, and keep the branch reviewable between cycles.
If time expires mid-cycle, stop after the current failing or passing gate and
write the exact continuation command to `doc/ribbon-cycle-log.md`.

Allowed unattended actions:

- add implementation files in the planned locations;
- add tests and fixtures;
- add screenshots generated by the cycle runner;
- update docs named in this plan;
- commit passing cycles with focused messages.

Forbidden unattended actions without a fresh user grant:

- modify `~/jaspr-ribbon-toolbar` or `XjRibbon`;
- bump `pubspec.yaml` version;
- create or move Git tags;
- publish to pub.dev;
- change GitHub repository settings;
- add large binary assets beyond necessary screenshots or PNG fixture icons.

## Implementation Phases

### Phase 4.0: Planning And Branch Setup

Status: this document.

Deliver:

- milestone plan;
- source-material mapping;
- branch naming;
- test plan;
- documentation pointers.

No package version bump.

### Phase 4.1: Model, Schema, Validation

Deliver:

- `FxRibbonDefinition`, `FxRibbonTab`, `FxRibbonGroup`, `FxRibbonItem`,
  `FxRibbonMenuItem`;
- `FxRibbonLocalizedText` and localized caption/tooltip/semantic-label maps;
- JSON import/export;
- Jaspr `.ribbon` schema compatibility importer;
- `FxRibbonValidator`;
- model copy/replace helpers;
- event classes;
- public Dartdoc.

Tests:

- round-trip JSON;
- parse Jaspr example fixture;
- parse XjRibbon-style legacy fixture where practical;
- duplicate tag validation;
- localized text fallback and invalid locale validation;
- contextual tab validation;
- menu item validation;
- equality and copy helpers.

Acceptance:

- model tests pass on VM;
- no Flutter dependency types leak from model APIs;
- docs explain schema version, compatibility, localization fallback, and stable
  locale-independent command tags.

### Phase 4.2: Icon Registry

Deliver:

- `FxRibbonIconRegistry`;
- `FxRibbonIconSource`;
- PNG asset/bytes support;
- Material icon support;
- placeholder rendering contract;
- SVG support through `flutter_svg` if accepted after dependency check;
- fallback plan if SVG is deferred.

Tests:

- registry lookup;
- missing icon fallback;
- embedded PNG serialization;
- SVG serialization when enabled;
- disabled icon styling.

Acceptance:

- toolbar can render at least Material icons and PNG icons;
- SVG support is either implemented or explicitly documented as deferred with
  an unchanged public icon API.

### Phase 4.3: Toolbar MVP

Deliver:

- `FxRibbonToolbar`;
- tab strip;
- standard tabs;
- groups;
- large buttons;
- small buttons;
- separators;
- command events;
- hover/pressed/focus state;
- light/dark theme support;
- localized captions, tooltips, and semantic labels;
- example page.

Tests:

- renders tabs/groups/items;
- tap command emits tag;
- disabled item does not emit command;
- active tab changes;
- changing locale changes visible labels without changing emitted tags;
- keyboard activation works;
- semantics labels exist;
- local golden/release screenshot.

Acceptance:

- usable toolbar in example app on desktop;
- web build smoke test passes;
- no mobile-only behavior.

### Phase 4.4: Menus, Split Buttons, Toggles, Contextual Tabs

Deliver:

- dropdown menus;
- split-button body/arrow behavior;
- toggle buttons;
- checkbox items;
- contextual tabs;
- collapse/expand behavior;
- keytip MVP.

Tests:

- dropdown opens and emits menu item tag;
- split body emits primary command;
- split arrow opens menu;
- toggle/checkbox state event works;
- contextual group show/hide works;
- collapse changes height and emits event;
- F6 keytip activation;
- Escape exits keytip or closes menu.

Acceptance:

- all seven source control kinds work;
- mouse and keyboard paths produce the same semantic events.

### Phase 4.5: Touch And Large-Screen Polish

Deliver:

- `FxRibbonInteractionMode`;
- touch hit-target policy;
- pointer-kind tracking;
- medium-width horizontal scroll or overflow behavior;
- long-press tooltip/help behavior where available;
- high-contrast and text-scale review.

Tests:

- `WidgetTester` touch gesture activates command;
- mouse hover does not affect touch-only behavior;
- touch mode increases effective hit targets;
- medium-width layout remains usable;
- text scale does not overlap group captions or item labels.

Acceptance:

- toolbar works with mouse, trackpad, and touch;
- iPad-sized width is supported without adding phone UI.

### Phase 4.6: Designer MVP

Deliver:

- `FxRibbonDesigner`;
- live preview;
- hierarchy editor;
- inspector;
- add/delete/reorder tabs/groups/items;
- menu item editor;
- JSON import/export callbacks;
- validation panel;
- dirty state;
- undo/redo.

Tests:

- designer renders a seed model;
- add tab/group/item mutates model;
- inspector edits update preview;
- delete and reorder work;
- validation errors show;
- undo/redo restores snapshots;
- exported JSON parses back to equivalent model.

Acceptance:

- designer can build a complete toolbar with all seven item types;
- designer uses FxDesktop controls where appropriate;
- no file picker dependency in package core.

### Phase 4.7: Documentation, Screenshots, Release Candidate

Deliver:

- README section;
- `doc/ribbon-schema.md`;
- `doc/ribbon-designer.md`;
- `doc/xojo-component-map.md` update;
- `AGENT.md` update;
- example gallery screenshots;
- changelog entry;
- public API signature update;
- release screenshots.

Tests:

- full agent harness;
- `flutter pub publish --dry-run`;
- desktop widget tests;
- web smoke test;
- local golden screenshots;
- release-sync check.

Acceptance:

- ready for a `0.5.x` release after implementation is accepted.

## Test Matrix

### Unit

- schema parse and serialize;
- compatibility import;
- validation;
- layout measurement using fake text metrics;
- icon registry;
- keytip generation;
- reducer/copy helpers.

### Widget

- toolbar render;
- tab change;
- command activation;
- dropdown menu activation;
- split-button hit regions;
- toggle/checkbox state;
- collapsed state;
- contextual tabs;
- disabled state;
- semantics;
- focus and keyboard.

### Pointer

- mouse tap;
- mouse hover;
- touch tap;
- touch long press;
- split-button arrow tap;
- outside tap menu dismissal.

### Designer

- hierarchy editing;
- inspector editing;
- menu item editing;
- validation panel;
- undo/redo;
- import/export;
- live preview sync.

### Visual

- light toolbar;
- dark toolbar;
- contextual tabs;
- dropdown menu;
- designer full view;
- touch density;
- medium-width horizontal scroll.

Use local exact goldens where possible. In GitHub Actions, avoid brittle
cross-renderer exact pixel checks when the renderer differs, following the
existing release screenshot strategy.

### Web

At minimum:

```bash
flutter test --platform chrome test/fx_ribbon_toolbar_test.dart
```

When the example app includes the ribbon route:

```bash
cd example
flutter build web
```

If Flutter web/WASM is part of the release target for the phase, add the exact
supported build command to the harness after verifying it on the current stable
Flutter channel.

### Desktop

Run the normal package harness:

```bash
dart run tool/agent_harness.dart
```

For screenshot capture and manual verification, run the example app on macOS
and at least one additional desktop target when practical.

## Release And Versioning

Planning-only work does not bump `pubspec.yaml`.

Implementation releases should use the `0.5.x` line unless a broader versioning
decision changes that before coding begins.

Release surfaces to update:

- `pubspec.yaml`;
- README install snippet and badges;
- `CHANGELOG.md`;
- `doc/xojo-component-map.md`;
- `doc/developer-guide.md`;
- `AGENT.md`;
- example app;
- screenshots;
- public API signature;
- release notes.

Do not tag until:

- the full harness passes;
- web smoke test passes;
- release screenshots are captured;
- pub dry-run has 0 warnings;
- the tag matches `pubspec.yaml`.

## Risks And Mitigations

| Risk | Mitigation |
|---|---|
| Direct canvas port loses Flutter accessibility. | Use widget-first renderer and pure layout model. |
| SVG dependency adds weight or web issues. | Keep icon renderer strategy abstract; ship PNG/Material fallback. |
| Ribbon becomes too wide for medium screens. | Add horizontal scroll and future group overflow policy. |
| Keytips conflict with browser/OS shortcuts. | Use F6 as reliable activation and treat Alt as optional. |
| Designer becomes a separate product too early. | Ship embeddable widget first; example app hosts it. |
| Model changes break Jaspr compatibility. | Keep fixture import tests from Jaspr `.ribbon` examples. |
| Touch support degrades dense desktop layout. | Add explicit interaction mode and density instead of one-size layout. |
| Public API grows too quickly. | Keep future features reserved in schema but not implemented until tested. |

## Definition Of Done

Milestone 5 is done when:

- `FxRibbonToolbar` is exported from `package:fx_desktop/fx_desktop.dart`;
- all seven source item types are usable;
- SVG or the documented PNG fallback path works through an icon registry;
- mouse, keyboard, and touch activation are tested;
- contextual tabs and collapse behavior are implemented;
- `FxRibbonDesigner` can create, edit, validate, preview, import, and export a
  ribbon definition;
- docs and screenshots show the toolbar and designer;
- full local harness passes;
- GitHub CI passes;
- pub.dev dry-run has 0 warnings;
- release tag and package version are reconciled.
