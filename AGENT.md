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
