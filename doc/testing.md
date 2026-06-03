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
dart pub publish --dry-run
```

The example app can be checked separately:

```bash
cd example
flutter pub get
flutter analyze
```

## Public API Policy

Public FxDesktop APIs should not expose implementation dependency types from:

- `flexiblebox`
- `flutter_layout_grid`
- `two_dimensional_scrollables`

Keep those packages behind FxDesktop wrappers.
