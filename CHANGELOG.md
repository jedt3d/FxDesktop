# Changelog

## Unreleased

No unreleased changes.

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
