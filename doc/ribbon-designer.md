# Ribbon Designer

`FxRibbonDesigner` is an embeddable visual editor for `FxRibbonDefinition`.
It is part of the package core, so it avoids file-picker, browser-download, and
platform-channel dependencies. Host apps decide how to open, save, upload, or
download JSON.

## Basic Use

```dart
FxRibbonDesigner(
  initialDefinition: FxRibbonSamples.explorer(),
  onDefinitionChanged: (definition) {
    // Store the current model in app state.
  },
  onSelectionChanged: (selection) {
    // Track the selected tab, group, or item if needed.
  },
  onExportRequested: (json) {
    // Save, copy, upload, or download from the host app.
  },
)
```

When no `initialDefinition` is supplied, the designer starts with
`FxRibbonSamples.explorer()`.

## Layout

The designer has five main regions:

- command row: new definition, add tab, add group, add item, delete, export,
  and preview locale controls
- live preview: an embedded `FxRibbonToolbar`
- structure pane: tabs, groups, and items
- JSON preview: current definition as formatted JSON
- inspector: editable properties for the selected tab, group, or item

The status row reports validation state from `FxRibbonValidator`.

The `v0.5.1` ribbon refresh extends the item type selector with medium row
commands, medium dropdowns, medium split buttons, embedded galleries, and
invisible column breaks. Menu and gallery entries still round-trip through the
JSON preview; the built-in visual editor for nested menu items remains a later
`0.5.x` task.

## Localization

The designer uses `FxDesktopLocalizations` for its own chrome. Apps should wire
the normal FxDesktop delegates into `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
  supportedLocales: FxDesktopLocalizations.supportedLocales,
  home: const FxRibbonDesigner(),
);
```

The preview locale selector changes only the live ribbon preview. It does not
change the host app locale and does not mutate saved model data.

The first release lets users edit fallback, Thai, Japanese, and Nepali
captions for tabs, groups, and items. Tooltips and semantic labels already
round-trip through the model and can be edited in code or by editing JSON.

## Icons

The visual inspector can edit `iconKey`. The icon data itself lives in the
definition's embedded icon bundle or in the runtime `FxRibbonIconRegistry`
provided by the host app.

Package core does not import files. A host app can add an icon manager and then
write the chosen key or embedded icon data back into `FxRibbonDefinition`.

## Export

Export is callback-based:

```dart
FxRibbonDesigner(
  onExportRequested: (json) {
    debugPrint(json);
  },
)
```

The JSON is produced by `FxRibbonDefinition.toJsonString()` and can be imported
later with `FxRibbonDefinition.fromJsonString(source)`.

## First-Release Scope

Delivered in `v0.5.0`:

- create a new definition
- add and delete tabs, groups, and items
- edit fallback captions and localized captions
- edit item tags, item type, enabled state, toggle state, tooltip, keytip, and
  icon key
- edit tab keytip, contextual state, and context group
- preview the ribbon through `FxRibbonToolbar`
- switch preview locale
- export JSON through callback
- show validation state

Added in `v0.5.1`:

- Explorer-style toolbar preview with application button, flat command bands,
  equal-width command columns, embedded gallery rendering, and preserved
  colored SVG icons
- designer support for the added item types in the structure tree, inspector
  selector, JSON preview, validation, and export path

Deferred to later `0.5.x` work:

- built-in open/import JSON UI
- visual reordering
- full menu item editor
- visual editing for localized tooltips and semantic labels
- undo/redo snapshots
- dirty-state tracking
- file picker, browser download, and drag/drop icon import integration
- Xojo generation and Jaspr-compatible export mode
