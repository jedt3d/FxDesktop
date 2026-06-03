# Changelog

## Unreleased

This update turns Milestone 2 from a broad idea into an executable development
plan for Xojo Desktop control parity. It captures the practical differences
that matter when generating or previewing Xojo-style desktop UI in Flutter:
editable ComboBox behavior, fixed-choice PopupMenu behavior, visible tabs,
headless page/card containers, and the smaller desktop controls that make real
forms feel complete.

### Added

- Added `doc/milestone-2-control-parity.md`, a phased roadmap for the next set
  of FxDesktop controls. The plan prioritizes core form inputs first, then
  navigation containers, desktop utility controls, and deeper ListBox/Grid
  behavior.
- Added planned mappings for Xojo Desktop controls that FxDesktop does not yet
  cover, including labels, styled labels, popup menus, combo boxes, radio
  groups, date/time pickers, color pickers, sliders, segmented buttons, tab
  panels, page panels, disclosure controls, scrollbars, progress controls, and
  separators.
- Added `doc/release-versioning.md`, a release checklist for version bumps,
  tags, optional GitHub Releases, and pub.dev readiness.

### Clarified

- Clarified that `FxComboBox` and `FxPopupMenu` are not interchangeable:
  ComboBox is editable and should support autocomplete, while PopupMenu is a
  fixed-choice selector.
- Clarified the container model for `FxTabPanel`, `FxPagePanel`, and
  `FxCardContainer`: visible tabs, headless indexed pages, and generator-friendly
  card stacks are different UI intents.
- Clarified that planning-only changes should not create version tags. Tags and
  optional GitHub Releases belong to accepted implementation milestones after
  the harness passes and all versioned docs are synchronized.
- Clarified that Milestone 2 implementation will ship as phase releases:
  `v0.2.1` through `v0.2.4`. Each phase must update the demo harness, capture
  screenshots, pass quality checks, tag the version, and create a GitHub
  Release.
- Added a parallel sub-agent workflow for Milestone 2 so multiple component
  groups can be implemented at the same time without letting release, registry,
  demo, and versioning work fragment across branches.

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
