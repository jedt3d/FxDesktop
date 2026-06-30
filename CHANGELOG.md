# Changelog

## Unreleased

## 0.3.7

Version `0.3.7` is a package-page and release automation polish release for the
first public pub.dev deployment line.

### Documentation
- Added ListBox/Grid screenshots directly to `README.md` so pub.dev readers can
  see the advanced table surface without opening the repository.
- Reconciled Milestone 3 documentation with the delivered `0.3.6` release
  history.
- Updated ListBox/Grid docs, release-versioning guidance, component mapping,
  testing notes, and gallery README so the current table surface is described
  as shipped rather than planned.
- Moved release verification notes into `doc/` and refreshed the `v0.3.6`
  manual checklist.

### Release
- Added package screenshots to `pubspec.yaml` for pub.dev package-page media.
- Added release-sync validation for `pubspec.yaml`, README, `CHANGELOG.md`,
  screenshots, and Git tags.
- Hardened GitHub Actions publishing for Flutter package publishing through
  `flutter pub publish`.
- Kept release screenshot widget checks in CI while avoiding exact pixel-golden
  comparisons on Ubuntu, where renderer differences can invalidate macOS
  release screenshot artifacts.

## 0.3.6

Version `0.3.6` introduces advanced enterprise cell editing features: cell action buttons, input masking, and multi-column lookups.

### Added
- **Multi-Column Lookup (`FxDbLookupProvider`)**: Added database-style multi-column lookup supporting multiple detail headers and columns in dropdown selectors.
- **Cell Action/Ellipsis Buttons**: Added `hasActionButton`, `actionIcon`, and `onActionPressed` callback to `FxListBoxColumn` and `FxGridColumn` for custom ellipsis action dialog integration.
- **Input Masking (`FxMaskTextInputFormatter`)**: Built custom regex-based input formatter for applying patterns like phone format `(###) ###-####` and SSN `###-##-####` on-the-fly.
- **Demo Gallery Page 11**: Created interactive demonstration featuring input mask formatting, ellipsis file picking, and tabular database lookups.
- **Pub.dev Package Evidence**: Added package screenshots and release-sync checks so `pubspec.yaml`, README, `CHANGELOG.md`, and the Git tag stay aligned for the first public `fx_desktop` publish.

## 0.3.5

Version `0.3.5` introduces custom cell rendering, database-grade key-value lookups, and hosted combobox overlays.

### Added
- **Lookup Providers (`FxLookupProvider`)**: Added `FxMapLookupProvider` and `FxEnumLookupProvider` to decouple database Keys/IDs from user-facing labels in grid/list views.
- **Custom Cell Renderers (`cellRenderer`)**: Added column-level widget builders supporting custom inline graphics (badges, Canvas sparklines) with `RepaintBoundary` caching.
- **Hosted Overlay Editors (`FxLookupComboBox`)**: Implemented non-clipped overlay dropdowns linked via `CompositedTransformFollower` and auto-dismissed on table scroll.
- **Undo/Redo Integration**: All lookup choices committed as raw keys to the undo stack, automatically updating reactive label visual lookups on revert/apply.
- **Demo Gallery Page 10**: Interactive sandbox page illustrating map/enum lookups, undo stacks, and Canvas trend sparklines.

## 0.3.4

Version `0.3.4` introduces advanced choice controls, grid interactions, visual guidance enhancements, and inline text formatting.

### Added
- **Range Slider (`FxSlider.range`)**: Implemented a dual-value range slider allowing users to control minimum and maximum values concurrently.
- **Drag-and-Drop Row Reordering**: Added support for manual row reordering via virtual grab handles on the left side of `FxListBox` and `FxGrid` rows, including visual insertion indicators and an `onRowReordered` callback.
- **Active Cell Crosshairs**: Enhanced selection feedback by dynamically drawing 50% darker border lines around the active cell's corresponding row (top/bottom) and column (left/right).
- **Inline Rich Styled Text**: Support for inline markup (`<b>`, `<i>`, `<u>`, `**`, `*`, `~`) inside cells when `supportStyledText` is enabled on columns.
- **Interactive Demo Extensions**: Page 8 updated with row reordering and rich styled doctor notes. Added Page 9 to showcase the dual-handle range slider and selection crosshairs.

## 0.3.3

Version `0.3.3` refines the table layout behavior and integrates column resize and line-wrapping toggling into the Undo stack.

### Added
- **Capped Auto-Fit Column Resizing**: Double-clicking a header resize border automatically fits the longest content, capped at 50% of the total table width. If the content exceeds this threshold, the width is set to 50% and line wrapping is automatically enabled (`true`) for that column. Otherwise, line wrapping is disabled (`false`).
- **Layout Undo Integration**: Both column width and wrapping changes from auto-fit double-clicks are recorded as atomic, reversible actions in the `FxUndoController` stack.
- **Undoable Switch**: Manual line-wrapping toggling on Page 8 is integrated with `_undoController.commitValue` for seamless undo/redo.
- **Documentation Polish**: Updated layout contract and component guides detailing capped column auto-fit and undo behaviors.

### Changed
- Page 8's default line wrapping for the Doctor Notes column is now disabled (`false`) by default.
- State-based line wrapping overrides are now synced with parent configurations in `didUpdateWidget`, clearing dynamic overrides when parent properties change.

## 0.3.2

Version `0.3.2` implements advanced formatting, automatic resizing, line wrapping, and implicit types.

### Added
- **Excel-Style Column Auto-sizing**: Double-click a header resize border to automatically size to fit the column's content.
- **Column Line Wrapping**: Added `lineWrap` to column descriptors with dynamic row height calculation.
- **Implicit Rendering & Alignment**: 
  - Case-insensitive "true"/"false" and boolean fields automatically render as interactive checkboxes.
  - Numeric columns automatically align right (header and cells).
  - Cells containing percentage strings (e.g., "75%") render bottom border progress bar overlays.
- **Advanced Features Page**: Added Page 8 to the interactive spec gallery demo.

## 0.3.1

Version `0.3.1` introduces the interactive `listbox_demo` spec gallery application for desktop platforms and polishes the scrollbar behavior in the table components.

### Added
- **FxListBox Interactive Spec Gallery**: A standalone Flutter desktop gallery demonstrating all 7 feature areas (Selection, Column Sizing/Resizing, Sorting, Inline Editing, Validation, Table States, and Scale/Virtualization) on PagePanel screens.
- **Draggable Multi-Axis Scrollbars**: Embedded axis-filtered draggable vertical and horizontal scrollbars (`thumbVisibility: true`) in both `FxListBox` and `FxGrid` using nested `Scrollbar` containers.
- **Theme Synchronization**: Synced the interactive spec gallery UI colors with the light theme of the main example app (seed color `0xff2563eb`, scaffold background `0xfff6f7f9`).

## 0.3.0

Version `0.3.0` completes Milestone 3, delivering high-performance, deep implementations of the row-oriented `FxListBox` (matching Xojo `DesktopListBox`) and cell-oriented `FxGrid` (matching Xojo `DesktopGrid`) controls. 

This release provides comprehensive desktop-grade functionality for dense business data views and layout editors, while establishing visual validation, stress-testing harnesses, undo integration, and full accessibility semantics.

### Added

- **High-Performance Virtualization**: Virtualized two-dimensional scrolling, supporting datasets at scale (tested up to 10,000+ rows and 100+ columns) with high frame-rate stability and minimal memory overhead.
- **Selection Models**:
  - `FxListBoxSelectionMode` support for `none`, `single`, and `multiple` selections.
  - `FxGridSelectionMode` support for `none`, `cell`, `row`, and rectangular `range` selection.
- **Keyboard Navigation & Traversal**: Desktop-style Arrow keys traversal, Shift+Arrow range selection expansion, Home/End, PageUp/PageDown, and tab focus management.
- **Column Sorting & Width Policies**: Interactive column headers with visual sort indicators, custom sort descriptors, and flexible column width policies (fixed, min/max bounds, or proportional weights).
- **In-Cell Editing & Validation**: Typed editor widgets (text, numeric, checkbox selection, popup choices) with validation error visual badges, commit/cancel lifecycle hooks, and read-only cell/row overrides.
- **Clipboard Operations**: TSV-format copy/paste integration. Users can copy cell/range/row selections to the clipboard and paste TSV tables directly into editable grids with cell-by-cell validation.
- **Undo/Redo History**: Direct integration with `FxUndoController` to group grid cell edits, bulk pastes, or sort updates into single undo/redo semantic actions.
- **Accessibility & Semantics**: Complete `Semantics` coverage announcing column captions, sorting statuses, cell coordinates, current selection state, cell values, and validation errors for screen readers.
- **Developer Guide & Spec**: Added [milestone-3-listbox-grid.md](doc/milestone-3-listbox-grid.md) and comparison guides under [developer-guide.md](doc/developer-guide.md).

### Changed

- Updated the vertical demo harness in `example/lib/main.dart` with functional samples for custom grid range selection, interactive column resizing, cell editing, bulk clipboard copy/pasting, and sorting.
- Configured visual regression golden testing using `test/visual_golden_test.dart` to assert correct layout and focus-ring states on buttons, checkboxes, disclosures, and progress controls.

## 0.2.6

Phase 2.6 is a visual polish release for mixed desktop form rows. It fixes the
alignment problem where decorated inputs without helper text or counters looked
shorter than neighboring inputs with supporting text.

The release keeps compact production defaults while giving form grids and the
demo harness an explicit way to reserve supporting-text space.

### Added

- Added `reserveSupportingTextSpace` to `FxTextField` and `FxTextArea`.
- Added `errorText` and `reserveSupportingTextSpace` to `FxDateTimePicker`.
- Added `helpText`, `errorText`, and `reserveSupportingTextSpace` to
  `FxPopupMenu` and `FxComboBox`.
- Added a shared internal supporting-text policy for decorated input controls.
- Added a mixed decorated-input demo row that compares `FxTextField`,
  `FxDateTimePicker`, `FxPopupMenu`, and `FxComboBox` in one row.

### Changed

- Updated the demo harness to top-align state samples instead of center-aligning
  mixed-height controls.
- Updated text input, date/time, popup, and combo demo rows to opt into reserved
  supporting text where visual comparison requires consistent field rhythm.

### Validated

- Added widget coverage for reserved supporting text, helper text, and error
  text across text fields, text areas, date/time pickers, popup menus, and combo
  boxes.
- Re-captured Phase 2.5 screenshots so the corrected input alignment is visible
  in release evidence.

## 0.2.5

Phase 2.5 makes `FxTextField` and `FxTextArea` more useful for real desktop
data-entry forms. It adds a typed, generator-friendly way to describe input
constraints, required fields, character counters, and single-line display
formats without moving form validation into a separate framework.

This release keeps a clear boundary between live editing and committed app
history. Character filtering and pattern masks can clean what the user sees
while typing, but number display formatting happens only on submit or focus
loss. That keeps `FxUndoController` focused on one semantic form edit rather
than every keystroke or transient formatter frame.

### Added

- Added `FxTextInputConstraints` for serializable text input rules.
- Added `FxTextInputConstraintKind` with `any`, `numeric`, `alpha`,
  `alphanumeric`, and `emailLike` character classes.
- Added maximum-length enforcement and optional character counters for
  `FxTextField` and `FxTextArea`.
- Added forbidden-character filtering and forbidden-pattern rejection for both
  text controls.
- Added `allowTab` metadata for text areas. Pasted tab characters can be
  preserved when requested, while keyboard Tab continues to follow normal
  desktop focus traversal.
- Added `requiredInput` and `showRequiredIndicator` to both text controls so
  required form fields can be represented directly in the component metadata
  and label display.
- Added `FxTextInputFormat` and `FxTextInputFormatType` for single-line display
  formatting.
- Added digit pattern masks such as `#-####-####` for phone-like values.
- Added commit-time fixed decimal number formatting such as `#,###.00`.
- Added Phase 2.5 demo rows for text-field constraints, required fields,
  character counts, forbidden input, phone masks, fixed decimals, and text-area
  constraint states.

### Clarified

- Clarified that text input captions/labels belong on the FxDesktop input
  controls so generators do not need to manually pair a separate label with
  every input.
- Clarified that multiline text areas do not support format masks in Phase 2.5;
  they support constraints, counters, required state, and forbidden input.
- Clarified that display formatting for business values should happen on
  commit/blur when it may affect undo history.
- Clarified that constraints are useful metadata for AI and Xojo generation,
  but host applications still own full validation rules and persistence.

### Validated

- Added widget tests for numeric, alpha, and alphanumeric filtering.
- Added widget tests for max length and visible character counters.
- Added widget tests for forbidden characters and forbidden patterns.
- Added widget tests for phone pattern formatting and commit-only fixed decimal
  formatting.
- Added widget tests for required indicators and text-area constraint metadata.
- Added undo regression coverage proving masked text commits one undo action
  only after submit.

## 0.2.4

Phase 2.4 completes the Milestone 2 form-control surface by deepening the
existing text-entry controls instead of adding new component families. The
release makes text input previews closer to real desktop forms by showing
validation, helper text, read-only state, password entry, field icons, and
predictable multiline text behavior.

This phase keeps `FxTextField` and `FxTextArea` as the canonical text input
components for Xojo-style form generation. The richer behavior belongs on those
existing controls, not in separate replacement widgets.

It also polishes `FxColorPicker` after Phase 2.3 by making optional colors
usable from the control itself. A no-color state is now a real selectable value,
and the default picker includes HSV sliders plus RGB hex entry for desktop
environments without a native color wheel integration.

This release also adds FxDesktop's semantic undo foundation. `FxUndoController`
records committed app-state changes, while native Flutter text editing remains
responsible for keystroke-level undo inside focused text fields.

### Added

- Added validation/error presentation to `FxTextField` and `FxTextArea`.
- Added helper/help text support to both text-entry controls so AI-generated
  forms can preserve text hints, balloon-help style notes, and validation
  guidance.
- Added read-only support for text fields and text areas.
- Added password/obscured-entry support to `FxTextField`.
- Added prefix and suffix icon support to `FxTextField`.
- Added deterministic multiline text-area behavior for preview and testing.
- Added an explicit `No Color` action to `FxColorPicker`.
- Added a default HSV slider and `#RRGGBB` hex-entry picker to
  `FxColorPicker`.
- Added semantic undo/redo primitives for FxDesktop apps: `FxUndoAction`,
  `FxUndoController`, and `FxUndoScope`.
- Added value, batch, undo, redo, clear, label, and history-depth support to the
  undo controller so apps can expose desktop-style Undo and Redo commands.
- Added commit callbacks for controls where live editing should be separated
  from committed app history: `FxTextField.onCommit`, `FxTextArea.onCommit`,
  `FxComboBox.onCommit`, `FxSlider.onChangeStart`, `FxSlider.onChangeEnd`, and
  `FxColorPicker.onCommit`.
- Added an Undo/Redo section to the example harness showing committed checkbox,
  popup, text field, slider, and tab changes.
- Added Phase 2.4 demo rows that keep `FxTextField` and `FxTextArea` separate
  while showing normal, disabled, read-only, validation, password, icon, and
  multiline states.

### Clarified

- Clarified that Phase 2.4 is a depth release for existing text-entry controls,
  not a new component-family release.
- Clarified that nullable controls need an explicit UI action for clearing the
  value, not just display text that says the value is missing.
- Clarified that FxDesktop undo is app-level semantic undo, while Flutter's
  native text editing undo remains responsible for keystroke-level editing
  inside focused text fields.
- Clarified that passive controls such as labels, progress indicators,
  separators, group boxes, and theme extensions should not own undo history.
- Clarified the delivered vs planned Milestone 2 mapping so Phase 3 can move on
  to table and grid depth.

### Validated

- Added focused widget tests for text entry, validation, disabled/read-only
  behavior, password obscuring, prefix/suffix icons, helper text, multiline
  behavior, and template metadata.
- Added focused widget tests for nullable color selection, HSV slider changes,
  RGB hex entry, invalid hex handling, disabled behavior, and injected picker
  behavior.
- Added unit coverage for undo commit, undo, redo, redo invalidation,
  unchanged-value suppression, batch actions, and scoped controller access.
- Added widget coverage for checkbox, popup menu, radio group, text commit,
  slider drag-end commit, tab/page/card index changes, and color picker commit.
- Verified the release with the local Flutter quality path and macOS demo
  harness before tagging.

## 0.2.3

Phase 2.3 fills in the compact utility controls that usually sit around forms,
dialogs, inspectors, and status panels. The release adds color selection,
progress display, separators, and rich display text without adding standalone
widgets for controls that Flutter already handles well through standard
scrollbars, menu anchors, or future numeric-field accessories.

This phase keeps FxDesktop focused on Xojo-style semantic parity rather than
duplicating every native control one-for-one. `FxPopupArrow`, standalone
up/down arrows, and manual vertical/horizontal scrollbars remain documented
decision points instead of public widgets in this release.

### Added

- Added `FxColorPicker` for desktop color value preview and selection metadata,
  comparable to Xojo `DesktopColorPicker`.
- Added `FxProgressBar` for determinate progress with min, max, disabled state,
  and safe value normalization.
- Added `FxProgressWheel` for compact indeterminate progress/loading states.
- Added `FxSeparator` for horizontal and vertical separators in dense desktop
  layouts.
- Added `FxStyledLabel` for rich label/help text using mixed spans, wrapping,
  alignment, and disabled appearance.
- Added Phase 2.3 rows to the example harness for picker, progress, separator,
  and styled text/display groups.
- Added component registry entries and Xojo mapping documentation for every
  Phase 2.3 public component.

### Clarified

- Clarified that `FxPopupArrow` remains documentation-only in Phase 2.3 because
  Flutter already provides mature popup menu patterns.
- Clarified that `DesktopUpDownArrows` should be revisited as a numeric field or
  stepper accessory rather than a standalone widget.
- Clarified that vertical and horizontal scrollbars should normally use
  Flutter `Scrollbar` attached to the owning scrollable instead of manual
  FxDesktop scrollbar widgets.

### Validated

- Added focused widget tests for utility control rendering, disabled states,
  callbacks, orientation, and template metadata.
- Expanded registry tests so Phase 2.3 controls remain mapped to the intended
  Xojo Desktop concepts.
- Verified the release with the local Flutter quality path and macOS demo
  harness before tagging.

## 0.2.2

Phase 2.2 adds the controls needed to move between modes, pages, and compact
sections in a Xojo-style desktop interface. The release keeps the same visual
harness discipline from Phase 2.1: every new component appears directly in the
demo, and the navigation container examples use visibly different page content
so screenshots prove that selection changes affect the displayed UI.

This phase also used a split implementation workflow. Dedicated sub-agents built
the navigation containers and navigation controls in separate files, while the
coordinator handled exports, registry metadata, demo integration, documentation,
screenshots, versioning, and release preparation from the phase branch.

### Added

- Added `FxSegmentedButton` and `FxSegmentedOption` for single-selection mode
  switching comparable to Xojo `DesktopSegmentedButton`.
- Added `FxTabPanel` for visible tab headers that select indexed content pages,
  comparable to Xojo `DesktopTabPanel`.
- Added `FxPagePanel` for headless indexed page switching comparable to Xojo
  `DesktopPagePanel`.
- Added `FxCardContainer` as a generator-friendly indexed card stack that can
  be controlled by another widget, such as `FxSegmentedButton`.
- Added `FxDisclosureTriangle` for compact collapsible sections with expanded,
  collapsed, and disabled states.
- Added Phase 2.2 rows to the example harness. The navigation row compares
  visible tabs, headless pages, and segmented-card switching side by side; the
  disclosure row shows expanded, collapsed, and disabled states.
- Added component registry entries and Xojo mapping documentation for every
  Phase 2.2 component.

### Clarified

- Clarified the phase release discipline for future work: every implementation
  phase must review the active Flutter desktop skill, keep `AGENT.md`,
  `CHANGELOG.md`, and README current, and finish with branch management, version
  tagging, and a GitHub Release.
- Clarified that Phase 2.2 screenshot work should capture the new navigation
  rows directly and include an alternate selected state for tab/page/card
  components.

### Validated

- Added focused widget tests for selected-index rendering, callbacks, state
  preservation, disabled behavior, and template metadata.
- Expanded registry tests so Phase 2.2 controls remain mapped to their intended
  Xojo Desktop classes.
- Verified the release with the local Flutter quality path and macOS demo
  harness before tagging.

## 0.2.1

Phase 2.1 makes FxDesktop more useful for real Xojo-style data-entry screens.
The package now has the first set of core form controls that were missing after
Milestone 1: labels, fixed-choice menus, editable combo boxes, radio choices,
date/time picking, and sliders.

This release also proves the parallel sub-agent workflow. Three focused
component streams implemented independent control families, then the coordinator
integrated the public exports, registry metadata, vertical demo harness, docs,
tests, screenshots, version bump, tag, and GitHub Release from one phase branch.

### Added

- Added `FxLabel` for plain desktop labels with wrapping, alignment, and
  disabled appearance.
- Added `FxPopupMenu` for fixed-choice selection. It intentionally does not
  allow free text entry, matching the Xojo `DesktopPopupMenu` intent.
- Added `FxComboBox` for editable text plus autocomplete suggestions, matching
  the Xojo `DesktopComboBox` use case more closely than a normal dropdown.
- Added `FxRadioButton` and `FxRadioGroup` for single radio options and managed
  exclusive option groups.
- Added `FxDateTimePicker` with date, time, and date-time modes. This keeps date
  entry as a picker control instead of treating it as a plain text field.
- Added `FxSlider` for numeric range input with min, max, divisions, enabled
  state, and visible value label support.
- Added Phase 2.1 component rows to the example harness. The harness continues
  to use one component family per vertical row and shows useful enabled,
  disabled, selected, empty, nullable, and range states.
- Added component registry metadata and Xojo mapping documentation for every
  Phase 2.1 control.

### Clarified

- Clarified the delivered vs planned Milestone 2 mappings in
  `doc/xojo-component-map.md`.
- Clarified that Phase 2.1 is delivered in `v0.2.1`, while `v0.2.2` through
  `v0.2.4` remain planned for navigation containers, utility controls, and text
  input depth. Deeper ListBox/Grid behavior moves to Phase 3.

### Validated

- Added focused widget tests for the new form, choice, range, and date/time
  controls.
- Expanded registry tests so the Phase 2.1 controls remain mapped to the
  intended Xojo Desktop classes.
- Verified the release with the local Flutter quality path and macOS demo
  harness before tagging.

## 0.1.0

The first milestone established FxDesktop as a real Flutter package rather than
only a design discussion. It introduced the package structure, desktop-first
component naming, layout contracts, initial Xojo component mappings, tests,
documentation, CI, and a runnable macOS example harness.

### Added

- Added the initial `fx_desktop` package scaffold with a public
  `package:fx_desktop/fx_desktop.dart` entrypoint.
- Added the desktop-first `Fx*` naming convention and component registry so AI
  agents and generators can reason about Xojo-style controls in a stable way.
- Added `FxFlexLayout`, `FxGridLayout`, `FxFlexItem`, `FxGridArea`, and
  `FxGridPlacement` for CSS-like layout work in desktop and Web/WASM previews.
- Added `FxLayoutSpec`, `FxFlexLayoutManager`, and `FxGridLayoutManager` as
  serializable contracts for AI agents, JinjaX, and future Xojo export.
- Added the first Xojo-first data controls: `FxListBox` and `FxGrid`.
- Added basic comparable controls including button, checkbox, text field, text
  area, and group box support.
- Added README, developer guide, layout contract notes, JinjaX bridge notes,
  Xojo component mapping, testing documentation, and the local AI-agent quality
  contract in `AGENT.md`.
- Added a macOS example app that presents components as a vertical visual
  harness with useful enabled, disabled, selected, and indeterminate states.
- Added CI and local quality harness checks for formatting, analysis, tests,
  Dartdoc, pub.dev dry-run validation, example analysis, and public API policy.

### Validated

- Verified the package with Flutter analysis, widget tests, Dartdoc generation,
  pub.dev dry-run validation, and the example app test.
- Verified the example macOS app can be built and signed locally with Developer
  ID tooling.
