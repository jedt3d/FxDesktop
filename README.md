# FxDesktop

FxDesktop is a desktop-first Flutter component and layout library for building
Xojo-style UI design tools, previews, and generators.

It provides:

- CSS-like layout widgets: `FxFlexLayout` and `FxGridLayout`
- Xojo-comparable desktop components such as `FxButton`, `FxTextField`, and
  `FxGroupBox`
- Xojo-first custom controls such as `FxListBox` and `FxGrid`
- Serializable layout contracts for AI agents, JinjaX, and Xojo generation
- App-level semantic undo primitives for desktop workflows

FxDesktop is not a mobile design-system wrapper. Flutter already has strong
mobile and tablet layout primitives. Responsive features are added here only
when they help desktop windows, Flutter Web/WASM, split panes, inspectors, or
multi-size desktop workflows.

## Install

```yaml
dependencies:
  fx_desktop: ^0.3.0
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

`FxGridLayout` is a CSS Grid-like layout manager. `FxGrid` is a data/cell grid
control comparable to Xojo `DesktopGrid`.

Milestone 3 introduces deep `FxListBox` and `FxGrid` controls (refined in `v0.3.3`). This includes selection models, keyboard navigation/traversal, sorting, column sizing/visibility policies, capped auto-fit resizing (header double-click caps at 50% width and toggles line wrapping), editable cell types (text, number, boolean, options) with validation, clipboard operations (TSV copy/paste), layout undo/redo integration (undoing auto-fit and toggles), performance virtualization (up to 10k+ rows and 100+ columns), and rich accessibility support via `Semantics`.
See [Milestone 3: ListBox And Grid Depth](doc/milestone-3-listbox-grid.md).

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

The harness runs formatting checks, static analysis, tests, Dartdoc, pub.dev
dry-run checks, and public API policy checks.

Version tags and optional GitHub Releases are created only after a milestone is
implemented, documented, validated, and accepted. See
[Release Versioning](https://github.com/jedt3d/FxDesktop/blob/main/doc/release-versioning.md).

For phase work after `v0.2.1`, each implementation phase must keep the process
docs current as part of the release: review the active Flutter desktop skill,
update `AGENT.md`, update `CHANGELOG.md`, update README when user-facing usage
or workflow changes, then merge, tag, and create the GitHub Release from the
accepted phase branch.
