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

## Proposed Phase Plan

Milestone 3 uses the `0.3.x` release line. Each phase should be implemented,
screenshotted, validated, merged to `main`, tagged, and published as a GitHub
Release before the next phase begins.

| Phase | Proposed tag | Focus |
|---|---|---|
| 3.1 | `v0.3.1` | Selection, focus, keyboard navigation, empty/loading/error states. |
| 3.2 | `v0.3.2` | Sorting, column sizing, column visibility, row/column metrics. |
| 3.3 | `v0.3.3` | Editable ListBox/Grid cells, typed renderers/editors, validation, commit callbacks. |
| 3.4 | `v0.3.4` | Clipboard, range selection, undo integration, generator template maps. |
| 3.5 | `v0.3.5` | Large-data behavior, performance tests, documentation hardening, release polish. |

The phase count can change after detailed design, but each phase must stay small
enough to review and release confidently.

## Phase 3.1: Selection And State Foundation

Status: planned.

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

Status: planned.

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

Status: planned.

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

Status: planned.

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

Status: planned.

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

## Open Design Questions

Resolve these before Phase 3.1 implementation starts:

- Should selection models be controlled-only, uncontrolled with initial values,
  or support both?
- Should `FxListBox` support cell selection at all, or keep row-only semantics?
- Should `FxGrid` support row selection as a mode, or should row selection be
  considered ListBox behavior?
- Should editable cells use built-in FxDesktop inputs such as `FxTextField`,
  `FxCheckBox`, and `FxPopupMenu`, or lightweight internal editors?
- Should copy/paste be opt-in per control, per column, or always available when
  selection exists?
- Should table data remain simple descriptor lists, or do we need a data-source
  interface for large remote/local datasets?
- How much of Xojo `DesktopListBox` API should be mirrored versus represented
  with Flutter-friendly names?

## Definition Of Done For Milestone 3

Milestone 3 is complete when:

- `FxListBox` has row selection, multi-selection, sorting, sizing, state, and
  useful row-oriented documentation.
- `FxGrid` has cell/range selection, editing, clipboard, validation, sizing,
  and useful cell-oriented documentation.
- both controls have screenshot evidence for each implemented phase.
- both controls have generator-friendly template maps.
- undo integration boundaries are documented and tested.
- all `0.3.x` phase releases are merged to `main`, tagged, and published as
  GitHub Releases.
