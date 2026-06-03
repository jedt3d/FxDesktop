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
| 13 | `FxColorPicker` | `DesktopColorPicker` | Color selection field/button with value preview. |
| 14 | `FxProgressBar` | `DesktopProgressBar` | Determinate progress. |
| 15 | `FxProgressWheel` | `DesktopProgressWheel` | Indeterminate progress/loading. |
| 16 | `FxSeparator` | `DesktopSeparator` | Horizontal and vertical separators for dense forms. |
| 17 | `FxStyledLabel` | Styled text label pattern | Rich text label using spans and paragraph styles. |
| 18 | `FxPopupArrow` | `DesktopPopupArrow` | Decision required; Flutter menu widgets may already cover this intent. |
| 19 | `FxUpDownArrows` | `DesktopUpDownArrows` | Decision required; may be a numeric-field accessory rather than standalone widget. |
| 20 | `FxVerticalScrollBar` | `DesktopScrollbar` | Decision required; Flutter `Scrollbar` usually owns this behavior already. |
| 21 | `FxHorizontalScrollBar` | `DesktopScrollbar` | Decision required; Flutter `Scrollbar` usually owns this behavior already. |

## Phased Development

Milestone 2 is released as a set of smaller phase releases. Each phase must be
implemented, demonstrated, screenshotted, validated, tagged, and published as a
GitHub Release before the next phase starts.

| Phase | Release tag | Release focus |
|---|---|---|
| 2.1 | `v0.2.1` | Core form inputs, delivered |
| 2.2 | `v0.2.2` | Navigation and indexed containers |
| 2.3 | `v0.2.3` | Desktop utility controls |
| 2.4 | `v0.2.4` | Text input depth |

Because FxDesktop is still pre-1.0, the `0.2.x` release line represents
Milestone 2, and the patch number maps to each phase.

## Parallel Sub-Agent Workflow

Milestone 2 can use multiple sub-agents, but only with clear ownership. Parallel
agents should build isolated component groups and avoid editing shared
integration files at the same time.

Starting with Phase 2.2, every phase must explicitly decide whether to use
sub-agents before implementation starts. Use sub-agents when the phase contains
independent component families, separate test surfaces, or parallelizable docs
and demo work. If a phase stays single-agent, record the reason in the plan or
PR description.

Use one coordinator/integrator agent for each phase. The coordinator owns:

- phase branch management
- public exports
- component registry consolidation
- example harness integration
- screenshot capture
- changelog and version updates
- release tagging and GitHub Release creation

Component sub-agents should own narrow implementation branches and avoid release
tasks. They may add component source files, focused tests, and focused docs, but
they should not tag versions or publish releases.

Recommended branch pattern:

| Branch type | Pattern | Purpose |
|---|---|---|
| Phase integration | `codex/fxdesktop-phase-2-1` | Collects all Phase 2.1 work before PR to `main`. |
| Component work | `codex/fxdesktop-2-1-combo-popup` | Isolated sub-agent work for one component group. |
| Component work | `codex/fxdesktop-2-1-radio-slider` | Isolated sub-agent work for one component group. |
| Component work | `codex/fxdesktop-2-1-datetime` | Isolated sub-agent work for one component group. |

Recommended file ownership:

- Component agents create focused files such as
  `lib/src/fx_form_inputs.dart`, `lib/src/fx_selection_controls.dart`, or
  `lib/src/fx_navigation.dart` instead of expanding one large shared file.
- Component agents add focused tests under `test/` with names that match the
  component group.
- The coordinator updates shared files such as `lib/fx_desktop.dart`,
  `fxComponentRegistry`, `example/lib/main.dart`, `CHANGELOG.md`, README, and
  release docs after component branches are merged into the phase branch.

Recommended execution waves:

1. **Wave A: component implementation**
   - Sub-agents build independent component groups in parallel.
   - Each sub-agent runs formatting, `flutter analyze`, and relevant widget
     tests before handing off.
2. **Wave B: integration**
   - Coordinator merges component branches into the phase branch.
   - Coordinator resolves API consistency, registry entries, exports, and docs.
3. **Wave C: demo and screenshots**
   - Coordinator adds vertical harness rows for the whole phase.
   - Coordinator builds/runs the macOS example app and captures screenshots.
4. **Wave D: release**
   - Coordinator updates version surfaces, runs the full harness, merges to
     `main`, tags the phase version, creates the GitHub Release, attaches
     screenshots, and deletes completed branches.

Phase 2.1 can safely use three component sub-agents:

| Sub-agent | Components | Notes |
|---|---|---|
| Form selection agent | `FxLabel`, `FxPopupMenu`, `FxComboBox` | Must preserve editable ComboBox vs fixed PopupMenu semantics. |
| Choice/range agent | `FxRadioButton`, `FxRadioGroup`, `FxSlider` | Should standardize selected, disabled, min, max, and divisions behavior. |
| Date/time agent | `FxDateTimePicker` | Should define nullable date/time modes and avoid plain text date input. |

Do not run release tasks from sub-agent branches. Release tasks happen only from
the phase integration branch after all component work is merged and validated.

### Phase 2.1: Core Form Inputs

Status: delivered in `v0.2.1`.

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
- Capture top and scrolled screenshots of the example harness after the new
  rows are visible.
- Save screenshots under `doc/screenshots/v0.2.1/` and attach them to the
  GitHub Release.

Validation:

- Widget tests for render, disabled state, value changes, and keyboard-friendly
  selection where practical.
- Registry and component-map tests for every new component.
- `dart run tool/agent_harness.dart` must pass.
- The macOS example app must build and open successfully when UI changes are
  included.

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
- Capture screenshots that compare the visible tab approach, headless indexed
  page approach, and segmented-card approach.
- Save screenshots under `doc/screenshots/v0.2.2/` and attach them to the
  GitHub Release.

Validation:

- Selected-index tests.
- Page/card preservation tests.
- Keyboard/focus tests for tab and segmented navigation when supported.
- `dart run tool/agent_harness.dart` must pass.
- The macOS example app must build and open successfully when UI changes are
  included.

### Phase 2.3: Desktop Utility Controls

Build smaller desktop controls that complete common dialogs and inspectors.
Phase 2.3 must first decide whether a control needs a new FxDesktop public
widget, a thin adapter around an existing Flutter widget, or documentation only.
Do not duplicate Flutter behavior when the standard widget already works well
for desktop preview and Xojo generation.

- `FxColorPicker`
- `FxProgressBar`
- `FxProgressWheel`
- `FxSeparator`
- `FxStyledLabel`

Decision candidates:

| Candidate | Xojo Desktop Counterpart | Phase 2.3 Decision | Reason |
|---|---|---|---|
| `FxPopupArrow` | `DesktopPopupArrow` | Document or thin adapter first | Flutter already has `PopupMenuButton`, `MenuAnchor`, and trailing icon patterns. Build a standalone widget only if Xojo export needs a separate `DesktopPopupArrow` component or the demo needs a compact menu-only control. |
| `FxUpDownArrows` | `DesktopUpDownArrows` | Prefer numeric stepper accessory | Flutter does not have a direct desktop up/down arrow control, but a standalone widget is rarely useful without a numeric field. Prefer an `FxNumberField` or stepper accessory unless Xojo generation explicitly needs the standalone component. |
| `FxVerticalScrollBar` | `DesktopScrollbar` | Do not duplicate by default | Flutter `Scrollbar` already attaches to scrollable regions and handles thumb behavior. Add an FxDesktop wrapper only for consistent desktop styling or generator metadata, not as a separate manual scrollbar control. |
| `FxHorizontalScrollBar` | `DesktopScrollbar` | Do not duplicate by default | Flutter can show horizontal scrollbars for horizontal scroll views. Add only a wrapper/metadata helper when table, grid, or design-preview export requires it. |

Demo presentation:

- Group compact utility controls into rows by family: pickers, progress, and
  text/display. Include stepper or scrollbar rows only after the decision table
  says they need public FxDesktop widgets.
- Show min/max/disabled states for any utility control that exposes a numeric
  range or explicit state.
- Show determinate and indeterminate progress states.
- Capture screenshots for picker, progress, and text/display groups. Capture
  stepper or scrolling groups only when Phase 2.3 explicitly creates public
  widgets for them.
- Save screenshots under `doc/screenshots/v0.2.3/` and attach them to the
  GitHub Release.

Validation:

- Render and state tests.
- Serialization or template-map tests only when a control needs generator
  metadata beyond normal widget properties.
- `dart run tool/agent_harness.dart` must pass.
- The macOS example app must build and open successfully when UI changes are
  included.

### Phase 2.4: Text Input Depth

Improve existing text-entry controls only:

- `FxTextField`: validation state, prefix/suffix icons, password mode.
- `FxTextArea`: validation state and predictable scroll behavior.

Demo presentation:

- Keep `FxTextField` and `FxTextArea` as separate rows.
- Show normal, disabled, read-only when supported, validation error, helper
  text, prefix/suffix icon, password, and multiline scroll states where
  practical.
- Capture before/after-style screenshots that show validation and text-entry
  behavior improvements.
- Save screenshots under `doc/screenshots/v0.2.4/` and attach them to the
  GitHub Release.

Validation:

- Interaction tests for validation, text entry, disabled/read-only behavior,
  password visibility, helper text, prefix/suffix icons, and multiline scrolling
  where practical.
- `dart run tool/agent_harness.dart` must pass.
- The macOS example app must build and open successfully when UI changes are
  included.

## Phase 3: Table And Grid Depth

Move deeper table/grid work out of Milestone 2 so Phase 2 can finish the common
form-control surface first. Phase 3 focuses on data-heavy desktop controls:

- `FxListBox`: sorting, multi-select, column resize, keyboard navigation,
  editable cells, checkbox cells, and datasource-ready models.
- `FxGrid`: cell editing, selection modes, keyboard navigation, column resize,
  datasource-ready models, and richer cell renderers.

Phase 3 screenshots should keep `FxListBox` and `FxGrid` as separate rows and
show compact examples for single select, multi-select, sorting, and editable
cells instead of building a dashboard-style demo.

## Per-Phase Release Workflow

Each phase release follows the same sequence:

1. Implement the phase on a dedicated branch.
2. Add or update the relevant rows in the vertical example harness.
3. Add component registry entries, component-map docs, dartdoc, and tests.
4. Build and run the macOS example app for visual verification.
5. Check screenshot navigation before capture:
   - identify whether the harness has one outer scrollbar or nested scrollbars
   - verify whether the current input method uses normal or natural scroll
     direction
   - use deterministic Flutter screenshot offsets if macOS scroll automation
     cannot reliably reach the target rows
6. Capture screenshots at a stable desktop viewport and save them under
   `doc/screenshots/vX.Y.Z/`.
   Each newly created component must appear in at least one screenshot, and the
   screenshot filenames should name the component group being shown.
7. Update `CHANGELOG.md` with human-readable release notes for that phase.
8. Update `pubspec.yaml`, README install instructions, and any versioned docs to
   the phase version.
9. Run `dart run tool/agent_harness.dart`.
10. Merge to `main`.
11. Tag the release as `vX.Y.Z`.
12. Create a GitHub Release and attach the screenshots.
13. Delete the completed phase branch.

## Version And Release Checkpoint

Do not create a version tag for this planning document alone.

When each Milestone 2 phase implementation is complete and accepted:

- use the planned phase version, such as `v0.2.1` for Phase 2.1
- update `pubspec.yaml`
- update README install instructions
- update `CHANGELOG.md`
- update this milestone document so the completed phase is marked delivered
- update component mapping docs so planned items become implemented items
- add screenshots for the released phase, with every new component visible in
  at least one screenshot
- run `dart run tool/agent_harness.dart`
- tag the release as `vX.Y.Z`
- create a GitHub Release and attach screenshots

See [Release Versioning](release-versioning.md) for the repository-wide
checklist.

## Definition Of Done

Each component is done only when all items are complete:

- Public widget/model API exists with dartdoc.
- Component registry maps it to Xojo Desktop and, when applicable, Xojo Web.
- `doc/xojo-component-map.md` documents the mapping.
- The example harness shows the component and its useful states.
- Screenshots show the component in the example harness for the phase release.
- Unit or widget tests cover basic rendering and state behavior.
- `dart run tool/agent_harness.dart` passes.
