# Developer Guide

## Architecture

FxDesktop keeps three layers separate:

1. Public component models and specs.
2. Flutter widgets that render the models.
3. Template/export maps for AI agents, JinjaX, and Xojo generators.

This separation keeps UI rendering testable while allowing future Xojo export
adapters to evolve without breaking widgets.

## Undo Architecture

FxDesktop undo is semantic app history. Use `FxUndoController` to record
committed changes to app state, component models, layout specs, tables, or
forms. Do not place independent undo stacks inside leaf controls.

Text input is the main exception: Flutter's focused text editing already
provides native undo behavior for keystrokes. FxDesktop records only committed
text values through callbacks such as `FxTextField.onCommit` and
`FxTextArea.onCommit`.

Input constraints and display formats must preserve that boundary. Character
filters and lightweight masks can run while the user types, but number
formatting or other business-value normalization should run on submit, focus
loss, or an explicit apply action so undo history receives one meaningful
change.

Required state, caption/label text, helper text, and constraint metadata belong
on the text control itself. That mirrors Xojo Web's caption-capable inputs and
keeps AI/Xojo generators from manually pairing a separate label with every
ordinary field.

When several decorated inputs share one form row, align them from the top and
use reserved supporting-text space for fields without helper, error, or counter
text. This preserves a consistent desktop form rhythm without adding fake
visible helper labels.

For complex components, group related changes as one action. Grid row edits,
layout property changes, or multi-field form updates should be committed as
one user-visible operation with a clear label.

## Adding A Component

When adding a public component:

1. Add a `Fx*` class with Dartdoc.
2. Add or update model/spec types if the component has generator metadata.
3. Add a descriptor to `fxComponentRegistry`.
4. Add widget or unit tests.
5. Update `doc/xojo-component-map.md`.
6. Add an example when the component introduces a new interaction pattern.

## Dependency Policy

FxDesktop may depend on layout packages internally, but public API must not
expose dependency-specific types. App code should import only:

```dart
import 'package:fx_desktop/fx_desktop.dart';
```

Milestone 1 dependencies:

- `flexiblebox` for `FxFlexLayout`
- `flutter_layout_grid` for `FxGridLayout`
- `two_dimensional_scrollables` for `FxListBox` and `FxGrid`

## ListBox and Grid Components

FxDesktop provides two distinct table controls, matching Xojo's layout patterns:
1. **`FxListBox`** (comparable to Xojo `DesktopListBox`/`WebListBox`): Used for row-oriented record selection and display. The primary unit of selection and interaction is the row.
2. **`FxGrid`** (comparable to Xojo `DesktopGrid`): Used for cell-oriented data editing, matrix configuration, and structured spreadsheet-like workloads. The primary unit of selection and interaction is the cell or a cell range.

### When to Use Which
- Use `FxListBox` when the user needs to scan lists of entities (e.g. customers, documents, logs) and select or trigger actions on whole records.
- Use `FxGrid` when the user edits cells directly, expects rectangular range selections (click-and-drag or Shift+Arrow keys), needs per-cell validation markers, or copies/pastes multiple cells as Tab-Separated Values (TSV).

### Xojo Parity Alignment
- **Supported features**: Column resizing, multi-selection modes, column sorting descriptors, custom empty/loading/error placeholder overrides, inline cell editors (text, checkbox/boolean, choice/dropdown), validation styling, raw pointer range selection, TSV clipboard copy/paste, and atomic undo/redo integration.
- **Approximate features**: alternating row colors, column sizing metrics (fixed, flexible, min/max).
- **Deferred / Out-of-scope**: cell merging, formulas, pivot tables, and drawing custom canvas elements inside cells (although in Flutter this is easily done by providing custom cell builders).

### Layout Refinements (Auto-Fit & Wrapping)
- **Auto-Fit Capping**: Double-clicking header resize borders auto-fits content up to 50% of the table width. Exceeding 50% caps the width and sets the column's wrapping override to `true` (wrapped by default).
- **State Overrides**: Wrapping overrides are stored in local state (`_columnLineWrapOverrides`). If the parent updates the column descriptors (e.g. toggles wrapping), local overrides are automatically cleared in `didUpdateWidget` to match the parent.
- **Undo Integration**: Auto-fit changes (width and wrapping state) are recorded as a single committed `FxUndoAction`. Manual switch toggles can be committed via `_undoController.commitValue`.

### Interaction and Visual Parity (v0.3.4)
- **Range Slider (`FxSlider.range`)**: Dual-handle slider constructor for choosing minimum and maximum range limits in one control.
- **Drag-and-Drop Row Reordering**: Reorder rows manually in `FxListBox` and `FxGrid` using virtual grab handles. Emits `onRowReordered` callback and draws custom visual drop indicators.
- **Selection Crosshairs (Darker Active Borders)**: Emphasizes the active cell's location by rendering 50% darker border lines for the active row's top/bottom borders and active column's left/right borders.
- **Inline Rich Styled Text**: Render styled text in cell values using Markdown-like (`**` bold, `*` italic, `~` underline) or HTML-like (`<b>`, `<i>`, `<u>`) tags when `supportStyledText` is enabled on columns.

## Release Workflow

Normal CI validates every pull request. Publishing to pub.dev is tag-based only.
Do not publish from arbitrary pushes.

Release checklist:

1. Update `pubspec.yaml` version.
2. Update `CHANGELOG.md`.
3. Run `dart run tool/agent_harness.dart`.
4. Commit changes.
5. Push a tag matching the package version, such as `v0.1.0`.
