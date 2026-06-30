# Milestone 3: ListBox And Grid Depth

Milestone 3 focuses on making `FxListBox` and `FxGrid` strong enough for real
desktop workflow screens and for future Xojo UI generation.

This is a large milestone. Treat it as a set of carefully scoped phase releases,
not one broad rewrite. The goal is Xojo-style semantic parity, predictable
desktop behavior, and generator-friendly metadata.

## Summary

`FxListBox` and `FxGrid` already exist as first-pass controls. Milestone 3 turns
them into serious desktop components:

- `FxListBox` represents row-oriented records, similar to Xojo `DesktopListBox`.
- `FxGrid` represents cell-oriented data, similar to Xojo `DesktopGrid`.
- Both controls must support dense desktop forms, inspectors, table workflows,
  screenshot evidence, AI-generated specs, and future Xojo export.

Do not merge the two controls into one generic table. They share rendering
infrastructure, but their public semantics are different.

## Current State

The current `v0.2.6` implementation provides:

| Control | Delivered behavior |
|---|---|
| `FxListBox` | Columns, rows, sticky header, single row selection, row enabled state, fixed row/column sizes, grid lines. |
| `FxGrid` | Columns, rows, optional headers, single cell selection, fixed row/column sizes, grid lines. |

Known gaps:

- no multi-selection
- no keyboard navigation
- no sorting
- no row/column resize
- no column reorder
- no editable cells
- no typed cell renderers/editors
- no focus/selection model object
- no empty/loading/error states
- no large-data or virtualization validation beyond the underlying table widget
- no clipboard support
- no generator contract for table operations

## Non-Goals

Milestone 3 should not attempt to build a full spreadsheet application.

Out of scope unless a later phase explicitly adds it:

- formulas
- merged cells
- pivot tables
- charts
- remote pagination framework
- database ORM integration
- full Excel import/export
- drag-and-drop row grouping
- mobile/tablet-first table behavior

## Control Semantics

### FxListBox

Use `FxListBox` when the user is selecting or scanning records.

Expected examples:

- order list
- customer list
- file/result list
- status list
- selectable navigation list with columns

The primary unit of interaction is the row.

Important behaviors:

- row selection
- optional multi-selection
- row enable/disable
- row-level actions
- sortable columns
- optional row checkboxes
- row commit events for undo/history

### FxGrid

Use `FxGrid` when the user is inspecting or editing cell-oriented data.

Expected examples:

- matrix values
- spreadsheet-like editor
- editable configuration grid
- structured numeric/text table
- key/value data with per-cell validation

The primary unit of interaction is the cell.

Important behaviors:

- cell selection
- rectangular range selection
- editable cell types
- validation per cell
- keyboard traversal
- clipboard copy/paste
- row and column headers
- commit events for undo/history

## Shared Table Foundation

Both controls should share internal table infrastructure where it reduces real
complexity, but that infrastructure should not leak third-party dependency
types into public APIs.

Internal shared concerns:

- scroll controller wiring
- hover and focus painting
- row/column sizing
- pinned headers
- cell text measurement and truncation
- keyboard navigation helpers
- selection painting
- empty/loading/error presentation
- accessibility labels

Public APIs should remain `Fx*` types only.

## Delivered Release History

Milestone 3 is delivered through `v0.3.6`. The original implementation phases
were completed on focused `codex/fxdesktop-phase-3-*` branches and consolidated
into the `v0.3.0` baseline release. Later `0.3.x` releases refined the table
surface with a dedicated spec gallery, advanced formatting, custom renderers,
hosted lookup editors, input masking, and enterprise-style action cells.

| Release | Status | Delivered focus |
|---|---|---|
| `v0.3.0` | Delivered | Milestone 3 baseline: ListBox/Grid selection, keyboard traversal, sorting, sizing, editing, validation, clipboard, undo integration, accessibility, performance tests, and documentation. |
| `v0.3.1` | Delivered | Interactive `listbox_demo` spec gallery and draggable multi-axis table scrollbars. |
| `v0.3.2` | Delivered | Excel-style column auto-sizing, line wrapping, implicit boolean/numeric/percentage rendering, and advanced feature demo page. |
| `v0.3.3` | Delivered | Capped auto-fit resizing, line-wrap synchronization, and undoable layout changes. |
| `v0.3.4` | Delivered | Range slider, drag-and-drop row reordering, active-cell crosshair visualization, and inline rich styled text cells. |
| `v0.3.5` | Delivered | Lookup providers, custom cell renderers, hosted overlay combobox editors, and lookup undo/redo integration. |
| `v0.3.6` | Delivered | Multi-column database lookups, input masks, cell action buttons, and background-saturation active row/column highlighting. |

The original phase plan remains below as the acceptance map for what was built.
Status lines now describe the delivered release surface instead of future work.

## Phase 3.1: Selection And State Foundation

Status: delivered in `v0.3.0`, with demo and scrollbar polish in `v0.3.1`.

Build stable interaction models before adding editing.

Deliver:

- `FxListBoxSelectionMode`
  - `none`
  - `single`
  - `multiple`
- `FxGridSelectionMode`
  - `none`
  - `cell`
  - `row`
  - `range`
- selection model value objects that can be serialized
- keyboard navigation for focused list/grid controls
- focus ring or focused-cell/row visual state
- hover state where it improves desktop scanability
- empty state
- loading state
- error state
- disabled control state

Acceptance criteria:

- mouse selection and keyboard selection produce the same selected model shape
- disabled rows/cells cannot be selected
- empty/loading/error states do not create nested scrollbars
- demo screenshot shows row selection, cell selection, multi-selection, empty,
  loading, and error states
- `toTemplateMap()` includes selection mode and state metadata

Screenshot targets:

- `fxdesktop-phase-3-1-listbox-selection-states.png`
- `fxdesktop-phase-3-1-grid-selection-states.png`

## Phase 3.2: Column And Sorting Behavior

Status: delivered in `v0.3.0`, with auto-sizing and wrapping refinements in
`v0.3.2` and `v0.3.3`.

Build table structure features that make the controls useful for records and
data views.

Deliver:

- sortable columns
- sort descriptors
- sort indicator rendering
- column width policy
  - fixed
  - min/max
  - flexible remaining width
- optional user-resizable columns
- optional column visibility metadata
- row height and header height consistency
- optional alternating row colors

Acceptance criteria:

- sorting is controlled by data/model state, not hidden widget state
- sort changes expose one committed callback suitable for undo/history
- column width APIs stay dependency-free
- ListBox and Grid can share sizing helpers without merging public semantics
- demo screenshot shows sorted, resized, hidden-column, and flexible-width
  examples

Screenshot targets:

- `fxdesktop-phase-3-2-listbox-sort-columns.png`
- `fxdesktop-phase-3-2-grid-sort-columns.png`

## Phase 3.3: Editing And Validation

Status: delivered in `v0.3.0`, with custom renderers, hosted lookup editors,
input masks, and cell action buttons extended in `v0.3.5` and `v0.3.6`.

Add editing only after selection and sizing are stable.

Deliver:

- typed cell value metadata
  - text
  - number
  - boolean
  - choice
  - date/time candidate if practical
- display renderer vs edit control boundary
- per-column editable flag
- per-cell editable override
- validation error metadata
- commit callbacks for edited values
- edit cancel behavior
- read-only mode

Acceptance criteria:

- editing one value commits one semantic change
- live editor state does not create app-level undo actions
- invalid values can be displayed without making the entire table unreadable
- `FxUndoController` integration is documented for table edits
- demo screenshot shows text, number, boolean, choice, read-only, and validation
  states

Screenshot targets:

- `fxdesktop-phase-3-3-listbox-editing.png`
- `fxdesktop-phase-3-3-grid-editing-validation.png`

## Phase 3.4: Clipboard, Range, And Generator Bridge

Status: delivered in `v0.3.0`, with range-selection, undo, and row-reordering
refinements visible in `v0.3.4`.

Add desktop productivity behavior and make the table specs useful for Xojo
generation.

Deliver:

- copy selected rows/cells as TSV text
- paste TSV into editable grid ranges
- rectangular range selection for `FxGrid`
- row selection copy for `FxListBox`
- generator-friendly action metadata
- JinjaX/Xojo template-map fields for columns, rows, selection, sorting, and
  editing rules

Acceptance criteria:

- copy/paste behavior is deterministic and tested
- paste validates each target cell before committing
- a paste operation can be represented as one undo action
- template maps are stable and documented
- demo screenshot or interaction capture shows range selection and clipboard
  workflow

Screenshot targets:

- `fxdesktop-phase-3-4-grid-range-selection.png`
- `fxdesktop-phase-3-4-clipboard-workflow.png`

## Phase 3.5: Performance And Hardening

Status: delivered in `v0.3.0` and maintained by
`test/fx_tables_performance_test.dart`.

Prove that the controls behave well enough for commercial desktop UI work.

Deliver:

- large-row smoke tests
- wide-column smoke tests
- deterministic test data builders
- keyboard navigation stress tests
- accessibility review for row/cell labels
- public API cleanup before closing the `0.3.x` line
- complete developer documentation

Acceptance criteria:

- demo can render meaningful large tables without blank screenshots
- large-data tests avoid fragile pixel-perfect assumptions
- public APIs remain dependency-free
- docs explain when to use `FxListBox` versus `FxGrid`
- docs explain which Xojo behaviors are supported, approximate, or deferred

Screenshot targets:

- `fxdesktop-phase-3-5-large-listbox.png`
- `fxdesktop-phase-3-5-large-grid.png`

## Current Screenshot Evidence

Latest `v0.3.6` screenshot evidence is stored in `doc/screenshots/v0.3.6/` and
generated by `test/release_screenshot_test.dart`:

- `fxdesktop-v0.3.6-lookup-renderers.png`
- `fxdesktop-v0.3.6-db-lookup-overlay.png`
- `fxdesktop-v0.3.6-masked-action-editor.png`

These screenshots cover custom renderers, map/enum lookup display values,
hosted multi-column database lookup overlays, input-mask columns, ellipsis
action cells, and active table selection/highlighting.

## Sub-Agent Plan

Milestone 3 is large enough to use sub-agents, but only with clear ownership.

Recommended roles:

| Role | Ownership |
|---|---|
| Coordinator | Branch, shared API consistency, exports, registry, docs, demo, screenshots, validation, release. |
| ListBox agent | Row selection, row state, row sorting, row actions, ListBox-specific tests. |
| Grid agent | Cell/range selection, editing, clipboard, Grid-specific tests. |
| Table foundation agent | Shared sizing, focus, keyboard navigation, rendering helpers, performance tests. |
| Docs/generator agent | Template maps, Xojo component map, README, milestone docs, screenshot checklist. |

Sub-agents should not independently update version numbers, tags, releases, or
GitHub Release notes. Those tasks belong to the coordinator.

## Demo Harness Rules

Milestone 3 screenshots must show the new table/grid behavior directly.

Rules:

- one row per component family or behavior group
- keep the outer app viewport as the primary scroll target
- avoid nested scrollbars except inside the table/grid control itself
- show enough rows/columns to prove horizontal and vertical behavior
- include visible selected, focused, disabled, empty, loading, and error states
- keep screenshot filenames tied to the phase and behavior

For table screenshots, capture the table at a stable size and avoid relying on
mouse-wheel automation when a deterministic screenshot harness can place the
target row directly.

## Testing Strategy

Milestone 3 tests should cover behavior, not just rendering.

Required test areas:

- serialization of column, row, selection, sort, edit, and validation metadata
- row selection, multi-selection, and disabled rows
- cell selection, range selection, and keyboard traversal
- sorting callbacks and sorted display
- column sizing metadata and validation
- editor commit/cancel paths
- invalid cell rendering
- clipboard copy/paste formatting and validation
- undo-friendly commit boundaries
- no public API leak from `two_dimensional_scrollables`

Run for every implementation phase:

```bash
dart format lib test example/lib tool
flutter analyze
flutter test
dart run tool/agent_harness.dart
```

When UI changes are included, also build/open the macOS example app and capture
phase screenshots.

## Resolved Design Decisions

These decisions were resolved by the shipped `0.3.x` implementation:

- Selection state is model-driven through public selected-row, selected-cell,
  and selected-range values plus change callbacks. Widgets keep only transient
  interaction state such as focus, hover, editing, and local sizing overrides.
- `FxListBox` keeps row-oriented semantics. It supports row selection,
  multi-selection, row state, sorting, editing, row reordering, and row copy.
- `FxGrid` owns cell-oriented semantics. It supports cell, row, and rectangular
  range selection modes because grid workflows often need both cell editing and
  whole-row inspection.
- Editable cells use lightweight internal editors and hosted overlays rather
  than embedding full public form controls into every virtualized cell.
- Clipboard behavior is enabled by table interaction state and editable column
  metadata. TSV paste validates target cells before committing changes.
- Table data remains descriptor-list based for the `0.3.x` line. Remote data
  source abstractions remain out of scope.
- Public names stay Flutter-friendly `Fx*` APIs while component maps preserve
  Xojo semantic alignment.

## Definition Of Done For Milestone 3

Milestone 3 is complete when:

- `FxListBox` has row selection, multi-selection, sorting, sizing, state, and
  useful row-oriented documentation.
- `FxGrid` has cell/range selection, editing, clipboard, validation, sizing,
  and useful cell-oriented documentation.
- latest `0.3.x` table behavior has screenshot evidence under
  `doc/screenshots/v0.3.6/`, with deterministic regeneration documented there.
- both controls have generator-friendly template maps.
- undo integration boundaries are documented and tested.
- all `0.3.x` phase releases are merged to `main`, tagged, and published as
  GitHub Releases.

## Refinements in v0.3.3

### Capped Column Auto-Sizing & Line-Wrapping
- **Double-click auto-fit**: Double-clicking the header resize border automatically adjusts the column width to fit the longest content.
- **50% Total Width Cap**: If the fit-content width exceeds 50% of the total table width, the column is capped at 50% width and line wrapping is automatically enabled (`true`). Otherwise, line wrapping is disabled (`false`).
- **Parent State Synchronization**: In `didUpdateWidget`, if the column descriptor's `lineWrap` property is modified by the parent widget, any local wrapping override is removed, syncing the layout state with the parent.

### Undo/Redo Layout Integration
- **Atomic Actions**: Auto-fitting changes both width and wrapping state in a single committed `FxUndoAction`.
- **Manual Switches**: Switch toggles on Page 8 are integrated with `FxUndoController.commitValue` for undoable manual wrapping toggles.

## Refinements in v0.3.4

### Range Slider (`FxSlider.range`)
- **Dual-Value Selection**: A range slider constructor that allows users to adjust both start (minimum) and end (maximum) values on a single track.
- **Parity with Desktop Slider Ranges**: Implements double thumb indicators with bounds checking and optional divisions.

### Drag-and-Drop Row Reordering
- **Virtual Grab Handles**: Renders a dedicated drag-handle column at index 0 when `allowRowReordering` is true.
- **Insertion Indicator**: Draws dynamic top/bottom row borders when dragging over target rows to indicate where the row will be dropped.
- **Reorder Callbacks**: Triggers the `onRowReordered` callback allowing developers to update their data models.

### Selection Crosshairs
- **Darker Target Borders**: The `v0.3.4` implementation highlighted the row and column boundaries corresponding to the active/selected cell by painting their borders 50% darker than the default grid line color. This was superseded by the background-saturation approach in `v0.3.6`.

### Inline Rich Styled Text Cells
- **Styled Cell Formatting**: Renders formatted text blocks inline within cells when `supportStyledText` is true.
- **Supported Tags**: Markdown (`**` for bold, `*` for italic, `~` for underline) and HTML (`<b>`, `<i>`, `<u>`) styles are parsed efficiently in `O(N)` time and rendered using rich text span hierarchies.

## Refinements in v0.3.5

### Lookup Providers and Hosted Editors
- **Key/value lookups**: `FxMapLookupProvider` and `FxEnumLookupProvider` allow
  tables to store raw IDs or enum values while displaying human-readable labels.
- **Custom renderers**: `cellRenderer` lets columns render badges, sparklines,
  or other inline widgets without changing the stored cell value.
- **Hosted combobox overlays**: `FxLookupComboBox` uses a composited overlay so
  dropdowns are not clipped by the table viewport and are dismissed on scroll.
- **Undo integration**: Lookup edits commit raw keys through the same semantic
  undo path as other cell edits.

## Refinements in v0.3.6

### Advanced Cell Editors
- **Multi-column database lookups**: `FxDbLookupProvider` displays tabular
  dropdown options with headers and detail columns while committing the raw key.
- **Input masks**: `FxMaskTextInputFormatter` supports `#`, `A`, and `*`
  placeholders for phone, SSN, and other fixed-format text entry.
- **Cell action buttons**: `hasActionButton`, `actionIcon`, and
  `onActionPressed` add ellipsis-style editor actions for workflows such as
  file pickers, modal dialogs, and external selectors.
- **Background-saturation highlighting**: Active rows and columns are highlighted
  with a subtle saturated background instead of heavy crosshair borders.
