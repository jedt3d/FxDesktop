# FxDesktop

FxDesktop is a desktop-first Flutter component and layout library for building
Xojo-style UI design tools, previews, and generators.

It provides:

- CSS-like layout widgets: `FxFlexLayout` and `FxGridLayout`
- Xojo-comparable desktop components such as `FxButton`, `FxTextField`, and
  `FxGroupBox`
- Xojo-first custom controls such as `FxListBox` and `FxGrid`
- Serializable layout contracts for AI agents, JinjaX, and Xojo generation

FxDesktop is not a mobile design-system wrapper. Flutter already has strong
mobile and tablet layout primitives. Responsive features are added here only
when they help desktop windows, Flutter Web/WASM, split panes, inspectors, or
multi-size desktop workflows.

## Install

```yaml
dependencies:
  fx_desktop: ^0.2.2
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
| `FxGroupBox` | `DesktopGroupBox` | custom/group container |

`FxGridLayout` is a CSS Grid-like layout manager. `FxGrid` is a data/cell grid
control comparable to Xojo `DesktopGrid`.

Milestone 2 extends Xojo Desktop control parity in phase releases. `v0.2.2`
adds navigation and indexed containers after the first core form controls:
segmented buttons, visible tab panels, headless page panels, generator-friendly
card containers, and disclosure triangles.
See [Milestone 2: Xojo Desktop Control Parity](https://github.com/jedt3d/FxDesktop/blob/main/doc/milestone-2-control-parity.md).

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
