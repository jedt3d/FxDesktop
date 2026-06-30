# Testing

Run the full harness:

```bash
dart run tool/agent_harness.dart
```

The harness checks:

- Dart formatting
- Flutter static analysis
- Flutter unit/widget tests
- Dartdoc generation
- pub.dev dry-run readiness
- example package analysis
- repository policy checks

Individual commands:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
dart doc
flutter pub publish --dry-run
```

The example app can be checked separately:

```bash
cd example
flutter pub get
flutter analyze
```

The interactive table gallery can be checked separately:

```bash
cd listbox_demo
flutter pub get
flutter analyze
flutter test
flutter run -d macos
```

Use the gallery for manual review of `FxListBox` and `FxGrid` behavior,
especially pages 10 and 11 for custom renderers, hosted lookup editors,
multi-column database lookup dropdowns, input masks, ellipsis action buttons,
and undo/redo integration.

Release screenshot evidence belongs under `doc/screenshots/vX.Y.Z/`. Prefer a
deterministic Flutter screenshot or golden harness for table states when manual
scrolling is unreliable.

## Public API Policy

Public FxDesktop APIs should not expose implementation dependency types from:

- `flexiblebox`
- `flutter_layout_grid`
- `two_dimensional_scrollables`

Keep those packages behind FxDesktop wrappers.
