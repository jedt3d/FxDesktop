# Ribbon Toolbar Designer

Standalone desktop/web-sized demo for the FxDesktop `FxRibbonDesigner`.

```bash
cd ribbon-toolbar-designer
flutter pub get
flutter run -d macos
```

For large-screen web smoke checks:

```bash
flutter build web --debug
flutter run -d chrome
```

This app intentionally hosts only the visual designer. The component-suite demo
in `../fx-desktop-example/` hosts the `FxRibbonToolbar` component alongside the
rest of the FxDesktop widgets.
