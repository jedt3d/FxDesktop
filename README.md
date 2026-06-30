# FxDesktop

[![Pub](https://img.shields.io/badge/pub-0.5.1-blue)](https://pub.dev/packages/fx_desktop)
[![Release](https://img.shields.io/badge/release-v0.5.1-blue)](https://github.com/jedt3d/FxDesktop/releases/tag/v0.5.1)
[![CI](https://github.com/jedt3d/FxDesktop/actions/workflows/ci.yml/badge.svg)](https://github.com/jedt3d/FxDesktop/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](https://github.com/jedt3d/FxDesktop/blob/main/LICENSE)

FxDesktop is a desktop-first Flutter component and layout library for building
Xojo-style UI design tools, previews, and generators.

It provides:

- CSS-like layout widgets: `FxFlexLayout` and `FxGridLayout`
- Xojo-comparable desktop components such as `FxButton`, `FxTextField`, and
  `FxGroupBox`
- Xojo-first custom controls such as `FxListBox` and `FxGrid`
- A Flutter-native `FxRibbonToolbar` plus embeddable `FxRibbonDesigner`
- Serializable layout contracts for AI agents, JinjaX, and Xojo generation
- App-level semantic undo primitives for desktop workflows
- Flutter-native localization with ARB source files, four bundled locales, and
  `.po`/`.pot` translator bridge tooling, including ribbon/designer strings

FxDesktop is not a mobile design-system wrapper. Flutter already has strong
mobile and tablet layout primitives. Responsive features are added here only
when they help desktop windows, Flutter Web/WASM, split panes, inspectors, or
multi-size desktop workflows.

## Install

```yaml
dependencies:
  fx_desktop: ^0.5.1
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:fx_desktop/fx_desktop.dart';

class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return FxFlexLayout(
      direction: FxFlexDirection.column,
      gap: 12,
      padding: const EdgeInsets.all(16),
      children: [
        const FxFlexItem(
          child: FxTextField(
            label: 'Customer',
            hintText: 'Company or person name',
            requiredInput: true,
            constraints: FxTextInputConstraints(
              maxLength: 80,
              showCharacterCount: true,
            ),
          ),
        ),
        FxFlexItem(
          grow: 1,
          child: FxListBox(
            columns: const [
              FxListBoxColumn(id: 'number', caption: 'Order', width: 100),
              FxListBoxColumn(id: 'status', caption: 'Status', width: 120),
            ],
            rows: const [
              FxListBoxRow(
                id: 'order-1',
                cells: {'number': '1001', 'status': 'Open'},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

## Xojo Mapping

| FxDesktop | Xojo Desktop | Xojo Web |
|---|---|---|
| `FxFlexLayout` | `DesktopFlexLayoutManager` | `WebFlexLayoutManager` |
| `FxGridLayout` | generation/layout contract | generation/layout contract |
| `FxListBox` | `DesktopListBox` | `WebListBox` |
| `FxGrid` | `DesktopGrid` | future/custom |
| `FxLabel` | `DesktopLabel` | `WebLabel` |
| `FxTextField` | `DesktopTextField` | `WebTextField` |
| `FxPopupMenu` | `DesktopPopupMenu` | `WebPopupMenu` |
| `FxComboBox` | `DesktopComboBox` | `WebComboBox` |
| `FxRadioButton` | `DesktopRadioButton` | `WebRadioButton` |
| `FxRadioGroup` | `DesktopRadioGroup` | `WebRadioGroup` |
| `FxDateTimePicker` | `DesktopDateTimePicker` | `WebDatePicker` |
| `FxSlider` | `DesktopSlider` | `WebSlider` |
| `FxSegmentedButton` | `DesktopSegmentedButton` | generation/custom |
| `FxTabPanel` | `DesktopTabPanel` | generation/custom |
| `FxPagePanel` | `DesktopPagePanel` | generation/custom |
| `FxCardContainer` | PagePanel/container-stack pattern | generation/custom |
| `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | generation/custom |
| `FxColorPicker` | `DesktopColorPicker` | generation/custom |
| `FxProgressBar` | `DesktopProgressBar` | generation/custom |
| `FxProgressWheel` | `DesktopProgressWheel` | generation/custom |
| `FxSeparator` | `DesktopSeparator` | generation/custom |
| `FxStyledLabel` | styled label pattern | generation/custom |
| `FxGroupBox` | `DesktopGroupBox` | custom/group container |
| `FxLocalizationGallery` | localization preview window | generation/custom |
| `FxRibbonToolbar` | `XjRibbon` / custom ribbon | custom Flutter widget |
| `FxRibbonDesigner` | `XjRibbon Designer` | embeddable designer |

`FxGridLayout` is a CSS Grid-like layout manager. `FxGrid` is a data/cell grid
control comparable to Xojo `DesktopGrid`.

Milestone 3 introduces deep `FxListBox` and `FxGrid` controls (refined in `v0.3.3` through `v0.3.6`). This includes selection models, keyboard navigation/traversal, sorting, column sizing/visibility policies, capped auto-fit resizing, editable cell types (text, number, boolean, options) with validation, database-grade multi-column lookups, input masking, ellipsis cell action buttons, background-saturation row/column highlights, clipboard operations (TSV copy/paste), layout undo/redo integration, performance virtualization (up to 10k+ rows and 100+ columns), and rich accessibility support via `Semantics`.
Milestone 3 is delivered through `v0.3.6`; the original plan remains in the
milestone document as the acceptance map, and the delivered release history is
now tracked there. See [Milestone 3: ListBox And Grid Depth](https://github.com/jedt3d/FxDesktop/blob/main/doc/milestone-3-listbox-grid.md)
and [Advanced Grid Features (v0.3.6)](https://github.com/jedt3d/FxDesktop/blob/main/doc/milestone-6-advanced-grid-features.md).

## Ribbon Toolbar And Designer

`FxRibbonToolbar` is a widget-native ribbon for Flutter desktop and web. It
uses a serializable `FxRibbonDefinition` model with tabs, groups, large,
medium, and small commands, dropdowns, split buttons, embedded galleries,
column breaks, toggles, checkboxes, contextual tabs, collapse behavior,
SVG/PNG/Material icon sources, keytips, mouse interaction, keyboard shortcuts,
touch hit targets, and localized command text. The default Explorer sample is
organized as an application-button ribbon with divider-separated groups and
equal-width command columns for large desktop and web windows.

`FxRibbonDesigner` is an embeddable visual designer for the same model. It
shows a live toolbar preview, structure tree, JSON preview, inspector, localized
caption editor, validation status, and export callback.

```dart
MaterialApp(
  localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
  supportedLocales: FxDesktopLocalizations.supportedLocales,
  home: Scaffold(
    body: FxRibbonToolbar(definition: FxRibbonSamples.explorer()),
  ),
);
```

![FxDesktop Explorer-style ribbon toolbar](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-explorer.png)

![FxDesktop ribbon dropdown menu](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-menu-en.png)

![FxDesktop ribbon designer](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-designer-ja.png)

See [Ribbon Schema](https://github.com/jedt3d/FxDesktop/blob/main/doc/ribbon-schema.md)
and [Ribbon Designer](https://github.com/jedt3d/FxDesktop/blob/main/doc/ribbon-designer.md).

## ListBox And Grid

`FxListBox` and `FxGrid` are the deepest controls in the package. They cover
dense desktop tables with virtualized scrolling, keyboard traversal, selection
models, inline editing, validation, TSV clipboard operations, undo/redo
integration, custom renderers, hosted lookup editors, input masks, cell action
buttons, and accessibility semantics.

![FxDesktop lookup cells and custom renderers](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.3.6/fxdesktop-v0.3.6-lookup-renderers.png)

![FxDesktop hosted multi-column database lookup overlay](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.3.6/fxdesktop-v0.3.6-db-lookup-overlay.png)

![FxDesktop masked editor and cell action button](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.3.6/fxdesktop-v0.3.6-masked-action-editor.png)

## Localization

FxDesktop uses Flutter's standard localization flow. Apps can add
`FxDesktopLocalizations.localizationsDelegates` and
`FxDesktopLocalizations.supportedLocales` to `MaterialApp`, then switch locale
the same way they would for other Flutter widgets.

```dart
MaterialApp(
  localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
  supportedLocales: FxDesktopLocalizations.supportedLocales,
  locale: const Locale('th'),
  home: const FxLocalizationGallery(),
);
```

Bundled package strings cover English, Thai, Japanese, and Nepali. ARB files
are the runtime source of truth; `.po` and `.pot` files are import/export
formats for translators.

![FxDesktop localization gallery in Thai](https://raw.githubusercontent.com/jedt3d/FxDesktop/v0.5.1/doc/screenshots/v0.4.0/localization/fxdesktop-localized-th.png)

## Text Input Constraints

`FxTextField` and `FxTextArea` include caption-style labels, helper text, error
text, required indicators, and serializable constraint metadata. Desktop apps
can use these APIs directly while AI/Xojo generators can export the same
metadata into templates.

```dart
const FxTextField(
  label: 'Phone',
  hintText: '#-####-####',
  requiredInput: true,
  constraints: FxTextInputConstraints(
    kind: FxTextInputConstraintKind.numeric,
    maxLength: 11,
  ),
  format: FxTextInputFormat.pattern('#-####-####'),
);

const FxTextField(
  label: 'Budget',
  format: FxTextInputFormat.number(decimalDigits: 2),
);
```

Pattern masks clean visible single-line input as the user types. Number formats
are applied on submit or focus loss so app-level undo records one committed
value change.

For form grids that mix inputs with and without helper, error, or counter text,
set `reserveSupportingTextSpace: true` on decorated inputs that should share the
same visual rhythm.

## Agent And Generator Use

FxDesktop specs can be serialized and passed into Xojo-side generators:

```dart
const spec = FxLayoutSpec.flex(
  id: 'root',
  direction: FxFlexDirection.row,
  gap: 8,
  flexChildren: [
    FxFlexItemSpec(id: 'sidebar', basis: 240),
    FxFlexItemSpec(id: 'content', grow: 1),
  ],
);

final context = FxFlexLayoutManager(spec: spec).toTemplateMap();
```

The resulting map is intended for AI agents, JinjaX templates, and Xojo export
adapters.

## Undo And Redo

FxDesktop provides `FxUndoController`, `FxUndoAction`, and `FxUndoScope` for
desktop-style semantic undo. The undo layer records committed app-state changes,
not every keystroke or transient widget frame.

```dart
final undo = FxUndoController();
var status = 'Draft';

undo.commitValue<String>(
  'Change status',
  oldValue: status,
  newValue: 'Approved',
  apply: (value) => status = value,
);

undo.undo();
undo.redo();
```

Text controls can still use Flutter's native focused text-editing undo for
typing. FxDesktop commit callbacks such as `FxTextField.onCommit` and
`FxSlider.onChangeEnd` are for app-visible history entries like `Change
customer` or `Change priority`.

See [Undo Guide](https://github.com/jedt3d/FxDesktop/blob/main/doc/undo.md).

## Development

Run the full local quality harness before committing:

```bash
dart run tool/agent_harness.dart
```

The main `example/` app is the vertical component harness. The
`listbox_demo/` app is the interactive ListBox/Grid spec gallery used to review
the `0.3.x` table surface, including lookup editors, input masks, cell action
buttons, row reordering, undo/redo, and large-table behavior.

The harness runs formatting checks, static analysis, tests, Dartdoc, pub.dev
dry-run checks, release version-sync checks, and public API policy checks.

Version tags and optional GitHub Releases are created only after a milestone is
implemented, documented, validated, and accepted. See
[Release Versioning](https://github.com/jedt3d/FxDesktop/blob/main/doc/release-versioning.md).

For phase work after `v0.2.1`, each implementation phase must keep the process
docs current as part of the release: review the active Flutter desktop skill,
update `AGENT.md`, update `CHANGELOG.md`, update README when user-facing usage
or workflow changes, then merge, tag, and create the GitHub Release from the
accepted phase branch.
