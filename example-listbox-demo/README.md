# FxDesktop ListBox/Grid Gallery

This app is the interactive spec gallery for the `FxListBox` and `FxGrid`
surface in FxDesktop.

It demonstrates the `0.3.x` table releases:

- selection modes, keyboard traversal, and table states
- sorting, column sizing, line wrapping, and implicit renderers
- editable cells, validation, range selection, TSV clipboard workflows, and
  undo/redo integration
- row reordering, inline styled text, range sliders, custom renderers, hosted
  lookup editors, multi-column database lookups, input masks, and ellipsis cell
  actions

Run it from this directory on macOS:

```bash
flutter run -d macos
```

The generated Windows runner is also present for platform parity checks:

```bash
flutter run -d windows
```

Useful review targets:

- Page 8: advanced formatting, auto-fit sizing, line wrapping, and progress
  overlays.
- Page 9: range slider, row reordering, and active row/column highlighting.
- Page 10: custom cell rendering, sparklines, map/enum lookups, hosted overlay
  editors, and lookup undo/redo.
- Page 11: multi-column database lookups, phone/SSN masks, ellipsis action
  buttons, and advanced editor undo/redo.

Run package checks with:

```bash
flutter analyze
flutter test
```
