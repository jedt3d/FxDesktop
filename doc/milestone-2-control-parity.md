# Milestone 2: Xojo Desktop Control Parity

Milestone 2 focuses on making FxDesktop feel complete enough to design common
Xojo Desktop forms, dialogs, inspectors, and workflow screens.

The goal is semantic parity first. FxDesktop widgets do not need to be native
Xojo controls, but they should represent the same design intent clearly enough
for preview, documentation, AI generation, and future Xojo export.

## Priority Rules

- Prefer controls that appear frequently in form and workflow UI.
- Preserve Xojo semantics when Flutter/Material has multiple possible widgets.
- Every new component must appear in the example harness as one vertical row.
- Every harness row must show useful states such as enabled, disabled, empty,
  selected, collapsed, expanded, indeterminate, min, max, and loading.
- Public APIs should expose FxDesktop types only. Do not leak dependency types.
- Add component registry entries, mapping docs, widget tests, and dartdoc with
  every new public component.

## Control Semantics

Some Xojo controls look similar but carry different intent:

- `DesktopComboBox` maps to `FxComboBox`: editable text plus list selection,
  with autocomplete support.
- `DesktopPopupMenu` maps to `FxPopupMenu`: fixed-choice selection without free
  text entry.
- `DesktopTabPanel` maps to `FxTabPanel`: visible tab headers choose pages.
- `DesktopPagePanel` maps to `FxPagePanel`: indexed pages without visible tabs.
- `FxCardContainer` is a generator-friendly indexed container stack. It can map
  to a PagePanel-style implementation or to show/hide container controls when
  another control, such as `FxSegmentedButton`, chooses the visible card.

## Priority List

| Priority | FxDesktop Component | Xojo Desktop Counterpart | Scope |
|---:|---|---|---|
| 1 | `FxLabel` | `DesktopLabel` | Plain label with alignment, enabled/disabled appearance, and wrapping. |
| 2 | `FxPopupMenu` | `DesktopPopupMenu` | Fixed option list, selected item, disabled state, empty state. |
| 3 | `FxComboBox` | `DesktopComboBox` | Editable option list, text entry, autocomplete, disabled state. |
| 4 | `FxRadioButton` | `DesktopRadioButton` | Single radio option with selected/unselected/disabled states. |
| 5 | `FxRadioGroup` | `DesktopRadioGroup` | Managed exclusive option set for generated forms. |
| 6 | `FxDateTimePicker` | `DesktopDateTimePicker` | Date, time, and date-time modes with nullable value. |
| 7 | `FxSlider` | `DesktopSlider` | Numeric range input with min, max, divisions, value label option. |
| 8 | `FxSegmentedButton` | `DesktopSegmentedButton` | Mode selector, often used to switch cards/pages. |
| 9 | `FxTabPanel` | `DesktopTabPanel` | Visible tab container with selected tab index. |
| 10 | `FxPagePanel` | `DesktopPagePanel` | Headless indexed page container. |
| 11 | `FxCardContainer` | PagePanel/container-stack pattern | Headless indexed card stack for generator workflows. |
| 12 | `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | Collapsible section control. |
| 13 | `FxPopupArrow` | `DesktopPopupArrow` | Compact menu/action disclosure control. |
| 14 | `FxUpDownArrows` | `DesktopUpDownArrows` | Small stepper control for numeric fields. |
| 15 | `FxVerticalScrollBar` | `DesktopScrollbar` | Explicit vertical scrollbar control when needed as a widget. |
| 16 | `FxHorizontalScrollBar` | `DesktopScrollbar` | Explicit horizontal scrollbar control when needed as a widget. |
| 17 | `FxColorPicker` | `DesktopColorPicker` | Color selection field/button with value preview. |
| 18 | `FxProgressBar` | `DesktopProgressBar` | Determinate progress. |
| 19 | `FxProgressWheel` | `DesktopProgressWheel` | Indeterminate progress/loading. |
| 20 | `FxSeparator` | `DesktopSeparator` | Horizontal and vertical separators for dense forms. |
| 21 | `FxStyledLabel` | Styled text label pattern | Rich text label using spans and paragraph styles. |

## Phased Development

### Phase 2.1: Core Form Inputs

Build the controls required for ordinary data-entry forms:

- `FxLabel`
- `FxPopupMenu`
- `FxComboBox`
- `FxRadioButton`
- `FxRadioGroup`
- `FxDateTimePicker`
- `FxSlider`

Demo presentation:

- Add one row per component to the vertical example harness.
- Show selected, empty, disabled, and validation-friendly states.
- For `FxComboBox`, show autocomplete behavior separately from `FxPopupMenu`.

Validation:

- Widget tests for render, disabled state, value changes, and keyboard-friendly
  selection where practical.
- Registry and component-map tests for every new component.

### Phase 2.2: Navigation And Indexed Containers

Build controls used to switch page or mode:

- `FxSegmentedButton`
- `FxTabPanel`
- `FxPagePanel`
- `FxCardContainer`
- `FxDisclosureTriangle`

Demo presentation:

- Add a container demo row that shows three approaches side by side:
  `FxTabPanel`, `FxPagePanel`, and `FxSegmentedButton` controlling
  `FxCardContainer`.
- Show collapsed and expanded states for `FxDisclosureTriangle`.

Validation:

- Selected-index tests.
- Page/card preservation tests.
- Keyboard/focus tests for tab and segmented navigation when supported.

### Phase 2.3: Desktop Utility Controls

Build smaller desktop controls that complete common dialogs and inspectors:

- `FxPopupArrow`
- `FxUpDownArrows`
- `FxVerticalScrollBar`
- `FxHorizontalScrollBar`
- `FxColorPicker`
- `FxProgressBar`
- `FxProgressWheel`
- `FxSeparator`
- `FxStyledLabel`

Demo presentation:

- Group compact utility controls into rows by family: pickers, steppers,
  scrolling, progress, and text/display.
- Show min/max/disabled states for steppers, scrollbars, and sliders.
- Show determinate and indeterminate progress states.

Validation:

- Render and state tests.
- Serialization or template-map tests only when a control needs generator
  metadata beyond normal widget properties.

### Phase 2.4: Existing Control Depth

Improve existing high-value controls:

- `FxListBox`: sorting, multi-select, column resize, keyboard navigation,
  editable cells, checkbox cells.
- `FxGrid`: cell editing, selection modes, keyboard navigation, column resize,
  datasource-ready model.
- `FxTextField`: validation state, prefix/suffix icons, password mode.
- `FxTextArea`: validation state and predictable scroll behavior.

Demo presentation:

- Keep ListBox and Grid as separate rows.
- Add compact examples for single select, multi-select, sorting, and editable
  cells instead of building a dashboard-style demo.

## Version And Release Checkpoint

Do not create a version tag for this planning document alone.

When Milestone 2 implementation is complete and accepted:

- choose the next semantic version
- update `pubspec.yaml`
- update README install instructions
- update `CHANGELOG.md`
- update this milestone document from plan status to delivered status
- update component mapping docs so planned items become implemented items
- run `dart run tool/agent_harness.dart`
- tag the release as `vX.Y.Z`
- consider a GitHub Release when screenshots, demo app changes, or pub.dev
  publishing notes would help users

See [Release Versioning](release-versioning.md) for the repository-wide
checklist.

## Definition Of Done

Each component is done only when all items are complete:

- Public widget/model API exists with dartdoc.
- Component registry maps it to Xojo Desktop and, when applicable, Xojo Web.
- `doc/xojo-component-map.md` documents the mapping.
- The example harness shows the component and its useful states.
- Unit or widget tests cover basic rendering and state behavior.
- `dart run tool/agent_harness.dart` passes.
