# Developer Guide

## Architecture

FxDesktop keeps three layers separate:

1. Public component models and specs.
2. Flutter widgets that render the models.
3. Template/export maps for AI agents, JinjaX, and Xojo generators.

This separation keeps UI rendering testable while allowing future Xojo export
adapters to evolve without breaking widgets.

## Adding A Component

When adding a public component:

1. Add a `Fx*` class with Dartdoc.
2. Add or update model/spec types if the component has generator metadata.
3. Add a descriptor to `fxComponentRegistry`.
4. Add widget or unit tests.
5. Update `doc/xojo-component-map.md`.
6. Add an example when the component introduces a new interaction pattern.

## Dependency Policy

FxDesktop may depend on layout packages internally, but public API must not
expose dependency-specific types. App code should import only:

```dart
import 'package:fx_desktop/fx_desktop.dart';
```

Milestone 1 dependencies:

- `flexiblebox` for `FxFlexLayout`
- `flutter_layout_grid` for `FxGridLayout`
- `two_dimensional_scrollables` for `FxListBox` and `FxGrid`

## Release Workflow

Normal CI validates every pull request. Publishing to pub.dev is tag-based only.
Do not publish from arbitrary pushes.

Release checklist:

1. Update `pubspec.yaml` version.
2. Update `CHANGELOG.md`.
3. Run `dart run tool/agent_harness.dart`.
4. Commit changes.
5. Push a tag matching the package version, such as `v0.1.0`.
