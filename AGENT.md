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
- `dart pub publish --dry-run`
- example package analysis
- repository policy checks

## Documentation Rules

Every new public component needs:

- Dartdoc on public classes and constructors
- an entry in the component mapping docs
- a test or example demonstrating intended use
- a short note when it maps to a Xojo component

For Milestone 2 component work, follow
`doc/milestone-2-control-parity.md`. Preserve important Xojo semantics:
`FxComboBox` is editable with autocomplete, `FxPopupMenu` is fixed-choice,
`FxTabPanel` has visible tabs, and `FxPagePanel`/`FxCardContainer` are
indexed containers without visible tab headers.

## Version And Release Rules

- Do not bump versions or create tags for planning-only changes.
- When a milestone is implemented and accepted, update all versioned surfaces in
  one change: `pubspec.yaml`, README install snippet, CHANGELOG, release notes,
  and any docs that mention the current version.
- For Milestone 2, release each implementation phase separately:
  `v0.2.1`, `v0.2.2`, `v0.2.3`, and `v0.2.4`.
- For every Milestone 2 phase, update the example harness, capture screenshots,
  run the full quality harness, tag the version, and create a GitHub Release
  with screenshots attached.
- For Milestone 2 parallel work, use component sub-agent branches for isolated
  implementation and one coordinator/integrator branch for exports, registry,
  demo harness, screenshots, changelog, version bump, tag, and release.
- Create tags as `vX.Y.Z` only after the quality harness passes on the release
  commit.
- Create a GitHub Release when the milestone has meaningful release notes,
  screenshots, demo app changes, or a pub.dev publish candidate.
- Follow `doc/release-versioning.md` for the full checklist.

## Example Harness Rules

- Keep the visual test app as a vertical component harness.
- Show one component family per row.
- Include a short component name label for every row.
- Show useful state variants inside that row, such as enabled, disabled,
  checked, unchecked, selected, and indeterminate.
- Put the scrollbar on the outer window viewport, not next to a constrained
  inner content column.
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
