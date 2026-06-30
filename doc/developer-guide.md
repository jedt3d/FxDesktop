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
- **Supported features**: Column resizing, multi-selection modes, column sorting descriptors, custom empty/loading/error placeholder overrides, inline cell editors (text, checkbox/boolean, choice/dropdown), validation styling, raw pointer range selection, TSV clipboard copy/paste, row reordering, lookup providers, hosted dropdown editors, input masks, ellipsis action buttons, custom cell renderers, active row/column background highlighting, and atomic undo/redo integration.
- **Approximate features**: alternating row colors, column sizing metrics (fixed, flexible, min/max), and generator-friendly table metadata.
- **Deferred / Out-of-scope**: cell merging, formulas, pivot tables, remote data-source abstractions, full spreadsheet import/export, and ORM/database integration.

### Layout Refinements (Auto-Fit & Wrapping)
- **Auto-Fit Capping**: Double-clicking header resize borders auto-fits content up to 50% of the table width. Exceeding 50% caps the width and sets the column's wrapping override to `true` (wrapped by default).
- **State Overrides**: Wrapping overrides are stored in local state (`_columnLineWrapOverrides`). If the parent updates the column descriptors (e.g. toggles wrapping), local overrides are automatically cleared in `didUpdateWidget` to match the parent.
- **Undo Integration**: Auto-fit changes (width and wrapping state) are recorded as a single committed `FxUndoAction`. Manual switch toggles can be committed via `_undoController.commitValue`.

### Interaction and Visual Parity (v0.3.4-v0.3.6)
- **Range Slider (`FxSlider.range`)**: Dual-handle slider constructor for choosing minimum and maximum range limits in one control.
- **Drag-and-Drop Row Reordering**: Reorder rows manually in `FxListBox` and `FxGrid` using virtual grab handles. Emits `onRowReordered` callback and draws custom visual drop indicators.
- **Active Row/Column Highlighting**: `v0.3.4` introduced darker crosshair borders; `v0.3.6` supersedes that visual treatment with subtle background-saturation highlighting for the active row and column while preserving the selected cell as the focal point.
- **Inline Rich Styled Text**: Render styled text in cell values using Markdown-like (`**` bold, `*` italic, `~` underline) or HTML-like (`<b>`, `<i>`, `<u>`) tags when `supportStyledText` is enabled on columns.
- **Lookup Providers and Hosted Editors**: Use `FxMapLookupProvider`, `FxEnumLookupProvider`, or `FxDbLookupProvider` with `FxCellType.lookup` to store raw keys while showing readable labels, including multi-column dropdowns.
- **Input Masks and Cell Actions**: Use column `inputMask`, `hasActionButton`, `actionIcon`, and `onActionPressed` for fixed-format entry and ellipsis-style workflows such as file pickers or selector dialogs.

## Localization

Milestone 4 plans the suite-wide localization foundation. Follow
`doc/milestone-4-localization.md` before localizing components or adding
new user-facing strings.

Key rules:

- Use Flutter-native ARB and generated localizations as the source of truth.
- Use `.po`/`.pot` only as translator import/export bridge formats.
- Keep duplicate English words as separate keys when context differs.
- Preserve PO `msgctxt` so imports do not merge unrelated translations.
- Use `MaterialLocalizations` where Flutter already supplies localized text or
  formatting.
- Keep app-authored labels and data caller-owned unless a component model
  explicitly supports localized values.

## Ribbon Toolbar and Designer

Milestone 5 plans a large-screen `FxRibbonToolbar` and `FxRibbonDesigner`.
Follow `doc/milestone-5-ribbon-toolbar-designer.md` before implementing this
surface.

Key rules:

- Keep public names under the `Fx*` prefix.
- Keep the ribbon model pure Dart and serializable.
- Use `iconKey` plus a registry for SVG/PNG/Material/placeholder icons.
- Prefer Flutter widget primitives for semantics, focus, actions, menus,
  overlays, tooltips, pointer handling, and theming.
- Treat Flutter `ThemeData` plus `FxRibbonThemeData` as the style-sheet layer;
  avoid a parallel CSS-like styling system for the first release.
- Support mouse, keyboard, and touch on desktop/web large screens.
- Do not turn the ribbon into a mobile-phone navigation component.
- Treat 1280 px as the primary design width and 1024 px as the minimum usable
  width that must prove horizontal overflow or equivalent large-screen behavior.
- Use the documented ribbon cycle runner once Cycle 0 creates it:
  `dart run tool/ribbon_cycle.dart --all` for unattended progress or
  `dart run tool/ribbon_cycle.dart --cycle N` for focused resumes.
- Consume the Milestone 4 localization foundation for built-in strings,
  context-specific duplicate text, and `.po`/`.pot` bridge behavior.
- Keep the designer embeddable and dependency-light; app shells can provide
  file picker or web download integrations through callbacks.

## Release Workflow

Normal CI validates every pull request. Publishing to pub.dev is tag-based only.
Do not publish from arbitrary pushes.

Release checklist:

1. Update `pubspec.yaml` version.
2. Update `CHANGELOG.md`.
3. Run `dart run tool/agent_harness.dart`.
4. Commit changes.
5. Push a tag matching the package version, such as `v0.1.0`.
