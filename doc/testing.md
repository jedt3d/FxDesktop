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
dart run tool/fx_l10n.dart audit
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

Localization-specific checks:

```bash
flutter gen-l10n
dart run tool/fx_l10n.dart audit
flutter test test/fx_localizations_test.dart test/fx_l10n_po_bridge_test.dart
flutter test --update-goldens test/release_screenshot_test.dart
```

The `v0.4.0` localization screenshot set covers English, Thai, Japanese,
Nepali, and an RTL smoke view under `doc/screenshots/v0.4.0/localization/`.

Ribbon-specific checks:

```bash
flutter test test/fx_ribbon_models_test.dart test/fx_ribbon_layout_test.dart test/fx_ribbon_toolbar_test.dart test/fx_ribbon_designer_test.dart
flutter test --update-goldens test/release_screenshot_test.dart
```

The `v0.5.0` ribbon screenshot set covers a 1280 px toolbar and designer proof
surface under `doc/screenshots/v0.5.0/ribbon/`.

## Public API Policy

Public FxDesktop APIs should not expose implementation dependency types from:

- `flexiblebox`
- `flutter_layout_grid`
- `two_dimensional_scrollables`

Keep those packages behind FxDesktop wrappers.
