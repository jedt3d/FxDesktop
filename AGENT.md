# AGENT.md

This file is the operating contract for AI agents and maintainers working on
FxDesktop.

## Mission

FxDesktop is a desktop-first Flutter library for Xojo-style UI design,
previewing, and generation. Keep the library useful for desktop windows,
Flutter Web/WASM, split panes, inspectors, dense forms, and table-like controls.

Do not treat FxDesktop as a generic mobile design-system wrapper. Mobile and
tablet layouts should normally use standard Flutter and adaptive patterns.

## Code Standards

- Target Dart 3.x and current stable Flutter.
- Follow `flutter_lints` unless a local rule documents otherwise.
- Keep public APIs small, typed, documented, and stable.
- Do not leak third-party dependency types from public FxDesktop APIs.
- Prefer immutable value objects and `const` constructors.
- Keep component models separate from rendering widgets.
- Keep undo history at the app/model layer. Leaf components may expose commit
  callbacks, but they must not own independent undo stacks.
- For nullable controls, provide an explicit UI action for the null state. Do
  not rely on display text alone to represent values such as no color.
- For text inputs, keep constraints, required state, help text, and captions on
  the input component metadata. Do not require generators to create a separate
  label and validation model for every ordinary field.
- Live input formatters may filter characters or apply lightweight pattern
  masks, but business-value display formatting should happen on commit/blur
  when it affects app state or undo history.
- When decorated inputs appear in the same form row, align them from the top
  and use reserved supporting-text space instead of fake visible helper labels.
- Use relative paths in source, docs, scripts, and CI.
- Do not commit generated build outputs, platform caches, or machine-local paths.

## Naming Rules

- Public widgets and models use the `Fx*` prefix.
- `FxFlexLayout` and `FxGridLayout` are layout managers.
- `FxGrid` is a data/cell grid control comparable to Xojo `DesktopGrid`.
- Do not add `Desktop` or `Web` to Flutter API names. Desktop/Web differences
  belong in export adapters and template maps.

## Quality Harness

Before committing, run:

```bash
dart run tool/agent_harness.dart
```

The harness runs:

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `dart doc`
- `flutter pub publish --dry-run`
- release version-sync checks
- example package analysis
- repository policy checks

## Documentation Rules

Every new public component needs:

- Dartdoc on public classes and constructors
- an entry in the component mapping docs
- a test or example demonstrating intended use
- a short note when it maps to a Xojo component

When a component changes user-editable state, decide whether the existing
`onChanged` callback is already a committed action or whether the component
needs an explicit commit callback. Text input, sliders, color pickers, grids,
and future layout editors should avoid recording every transient frame in
`FxUndoController`.

For Milestone 2 component work, follow
`doc/milestone-2-control-parity.md`. Preserve important Xojo semantics:
`FxComboBox` is editable with autocomplete, `FxPopupMenu` is fixed-choice,
`FxTabPanel` has visible tabs, and `FxPagePanel`/`FxCardContainer` are
indexed containers without visible tab headers.

For Milestone 3 table work, follow `doc/milestone-3-listbox-grid.md`.
Preserve the semantic split: `FxListBox` is row-oriented record selection and
`FxGrid` is cell-oriented data inspection/editing. Shared table infrastructure
is allowed, but public APIs must keep the two controls distinct.

Milestone 3 is delivered through `v0.3.6`. Treat the milestone document as a
delivered acceptance map plus release history, not as a pending phase plan. For
new table work, update `CHANGELOG.md`, `doc/milestone-3-listbox-grid.md`,
`doc/xojo-component-map.md`, `doc/milestone-6-advanced-grid-features.md` when
advanced editor behavior changes, and the `example-listbox-demo/` gallery docs.

Milestone 4 localization is delivered in `v0.4.0`; keep
`doc/milestone-4-localization.md` as the acceptance map and
`doc/localization.md` as the implementation guide. Use Flutter's native
localization stack as the primary path: ARB files, `gen_l10n`,
`flutter_localizations`, `intl`, `LocalizationsDelegate`, and
`Localizations.override` for tests/previews. Treat `.po` and `.pot` as
translator import/export bridge formats, not the runtime source of truth. Do not
deduplicate localization keys only because English text matches; repeated words
need context-specific keys and PO `msgctxt` so translations can differ by
component, command, validation, or designer context. New framework-owned strings
must update all four bundled locales, regenerate localizations, run
`dart run tool/fx_l10n.dart audit`, update `FxLocalizationGallery` when useful,
and keep ribbon/designer work on the same localization foundation.

Milestone 5 ribbon/designer is delivered in `v0.5.0`, with the Explorer-style
visual refresh delivered in `v0.5.1`. Follow
`doc/milestone-5-ribbon-toolbar-designer.md`, `doc/ribbon-schema.md`, and
`doc/ribbon-designer.md` before changing this surface. Keep the implementation
scoped to FxDesktop; use `jaspr-ribbon-toolbar` as Dart architecture source
material and `XjRibbon` as design ancestry only. Public APIs must use `Fx*`
names such as `FxRibbonToolbar`, `FxRibbonDefinition`, and
`FxRibbonDesigner`. Preserve the Flutter widget-first renderer that uses focus,
actions, semantics, menus, overlays, themes, and pointer-kind handling instead
of a canvas-only port. The toolbar must support mouse, keyboard, and touch on
large desktop/web screens; it must not become a mobile-phone navigation system.
Keep icon support behind the `iconKey` registry with SVG, PNG, Material, and
placeholder sources. Preserve the flat command-band layout, application button,
equal-width row columns, embedded galleries, and divider-separated groups in
the Explorer sample. Use Flutter `ThemeExtension`/`ThemeData` as the ribbon
style-sheet surface, with `FxRibbonThemeData` only for ribbon-specific tokens.
Consume the Milestone 4 localization foundation instead of creating a
ribbon-only translation system; ribbon and designer strings must use the same
four-locale, context-specific, PO-bridge workflow. Run the focused ribbon tests,
localization audit, release screenshots, and full harness before tagging a
`0.5.x` release.

## Version And Release Rules

- Do not bump versions or create tags for planning-only changes.
- When a milestone is implemented and accepted, update all versioned surfaces in
  one change: `pubspec.yaml`, README install snippet, CHANGELOG, release notes,
  and any docs that mention the current version.
- For Milestone 2, release each implementation phase separately:
  `v0.2.1`, `v0.2.2`, `v0.2.3`, `v0.2.4`, `v0.2.5`, and `v0.2.6`.
- For Milestone 3, use the `0.3.x` release line for implementation phases.
  Planning-only specs and documentation reconciliation do not bump the package
  version.
- For Milestone 4 localization, use the `0.4.x` release line for implementation
  phases.
- For Milestone 5 ribbon/designer, use the `0.5.x` release line unless the
  accepted release plan changes.
- For every Milestone 2 phase, update the example harness, capture screenshots,
  run the full quality harness, tag the version, and create a GitHub Release
  with screenshots attached.
- For Milestone 2 parallel work, use component sub-agent branches for isolated
  implementation and one coordinator/integrator branch for exports, registry,
  demo harness, screenshots, changelog, version bump, tag, and release.
- Create tags as `vX.Y.Z` only after the quality harness passes on the release
  commit.
- Pub.dev automated publishing must use tag pattern `v{{version}}`; the pushed
  tag must match `pubspec.yaml`, README, and `CHANGELOG.md`.
- Because FxDesktop is a Flutter package, publish checks and publishing use
  `flutter pub publish`, not `dart pub publish`.
- Create a GitHub Release when the milestone has meaningful release notes,
  screenshots, demo app changes, or a pub.dev publish candidate.
- Follow `doc/release-versioning.md` for the full checklist.

## Phase Execution Checkpoints

For Phase 2.2 and later, every implementation phase must start with these
checks:

- Consider whether sub-agents should be used. If the phase has independent
  component groups, split them into focused component agents and keep one
  coordinator/integrator agent for shared files, screenshots, versioning, and
  release work.
- Before capturing screenshots, inspect the example harness for nested
  scrollbars. The outer window viewport should be the primary screenshot
  scroll target. Inner scrollbars are allowed only inside components that need
  them, such as multiline text areas or grids.
- Verify the actual scroll direction before relying on screenshot automation.
  macOS natural scrolling, synthetic wheel events, and scrollbar thumb dragging
  can move in opposite directions depending on the input method. If automation
  cannot reliably reach the target component, use a deterministic Flutter
  screenshot/golden harness with explicit scroll offsets.
- When using a Flutter screenshot/golden harness, load both a readable text font
  and the Material Icons font. Otherwise icon-based controls can render as
  placeholder boxes in release screenshots even when the app itself is correct.
- Capture evidence for every newly created component. A release screenshot set
  must show the new components themselves, not only older controls that happen
  to appear near the top of the harness.
- For tab, page, segmented, card, or other indexed navigation components, make
  every selectable page visibly different in the demo. Screenshots should prove
  that selected state changes the displayed content, not only the highlighted
  tab or segment.

Every implementation phase must also update the working process surfaces before
release:

- Review and improve the active Flutter desktop skill used for the work. At a
  minimum, carry forward any lesson learned about building, validating,
  signing, screenshotting, or releasing Flutter macOS desktop software.
- Keep `AGENT.md`, `CHANGELOG.md`, and `README.md` up to date with the phase.
  If a file does not need content changes, say why in the PR description.
- Manage the phase through Git: dedicated branch, review/merge path, version tag,
  and GitHub Release. Do not treat a completed implementation phase as done
  until the branch, tag, and release have been handled.

## Example Harness Rules

- Keep the visual test app as a vertical component harness.
- Show one component family per row.
- Include a short component name label for every row.
- Show useful state variants inside that row, such as enabled, disabled,
  checked, unchecked, selected, and indeterminate.
- Put the scrollbar on the outer window viewport, not next to a constrained
  inner content column.
- For screenshot work, verify that each new component row can be reached and
  captured directly. Prefer filenames that identify the component group shown,
  such as `phase-2-2-tab-panel.png` or `phase-2-3-progress-controls.png`.
- For navigation container rows, include at least one screenshot with the
  default selection and one with an alternate selection when the component is
  intended to switch content.
- Avoid complex navigation or dashboards in the basic harness. Add a sidebar
  component browser only after the component count makes a single vertical list
  hard to scan.

## Xojo Bridge Rules

- `FxLayoutSpec` is the shared contract for AI agents, JinjaX, and Xojo
  generation.
- Xojo Desktop generation maps flex specs to `DesktopFlexLayoutManager`.
- Xojo Web generation maps flex specs to `WebFlexLayoutManager`.
- JinjaX stays a Xojo-side template bridge in milestone 1; do not port a Dart
  Jinja engine into this package unless a future plan explicitly chooses that.
