# Ribbon Schema

`FxRibbonDefinition` is the shared data contract for `FxRibbonToolbar`,
`FxRibbonDesigner`, tests, examples, and future generators. It is pure Dart
data and can be imported from or exported to JSON.

## Root

```json
{
  "version": "1.0",
  "projectType": "flutter",
  "name": "Explorer Ribbon",
  "localizedNames": {
    "th": "Explorer ribbon in Thai",
    "ja": "Explorer ribbon in Japanese",
    "ne": "Explorer ribbon in Nepali"
  },
  "tabs": [],
  "icons": {}
}
```

`version` uses the FxDesktop schema version. The importer also accepts the
Jaspr reference schema version `2.0` where the field shape maps to FxDesktop
types. `projectType` is `flutter` for FxDesktop-authored definitions.

## Tabs And Groups

Tabs contain ordered groups. Contextual tabs stay hidden until their
`contextGroup` is included in `FxRibbonToolbar.visibleContextGroups`.

```json
{
  "caption": "Home",
  "keyTip": "H",
  "isContextual": false,
  "groups": [
    {
      "caption": "Clipboard",
      "items": []
    }
  ]
}
```

Captions can include locale maps:

```json
{
  "caption": "Clipboard",
  "localizedCaptions": {
    "th": "Clipboard in Thai",
    "ja": "Clipboard in Japanese",
    "ne": "Clipboard in Nepali"
  }
}
```

Locale resolution follows the suite-wide `FxLocalizedText` order: exact locale,
language fallback, then the default `caption`.

## Items

`FxRibbonItemType` supports:

| JSON value | Dart value | Behavior |
|---|---|---|
| `large` | `FxRibbonItemType.large` | Large icon and caption command. |
| `medium` | `FxRibbonItemType.medium` | Medium row command with icon before caption. |
| `small` | `FxRibbonItemType.small` | Small row command, normally stacked. |
| `dropdown` | `FxRibbonItemType.dropdown` | Whole item opens a menu. |
| `splitbutton` | `FxRibbonItemType.splitButton` | Body fires command; arrow opens menu. |
| `mediumdropdown` | `FxRibbonItemType.mediumDropdown` | Medium row command where the whole row opens a menu. |
| `mediumsplitbutton` | `FxRibbonItemType.mediumSplitButton` | Medium row command with separate body and arrow zones. |
| `gallery` | `FxRibbonItemType.gallery` | Embedded ribbon gallery backed by menu-style items. |
| `toggle` | `FxRibbonItemType.toggle` | Persistent on/off command. |
| `checkbox` | `FxRibbonItemType.checkBox` | Checkbox-style persistent command. |
| `separator` | `FxRibbonItemType.separator` | Non-interactive divider. |
| `columnbreak` | `FxRibbonItemType.columnBreak` | Invisible layout break that starts a new command column. |

The importer also maps the Jaspr token `inribbongallery` to
`FxRibbonItemType.gallery`.

Example item:

```json
{
  "caption": "Paste",
  "tag": "clipboard.paste",
  "itemType": "large",
  "iconKey": "paste",
  "keyTip": "V",
  "tooltipText": "Paste from clipboard",
  "localizedCaptions": {
    "th": "Paste in Thai",
    "ja": "Paste in Japanese",
    "ne": "Paste in Nepali"
  },
  "localizedTooltips": {
    "th": "Paste tooltip in Thai",
    "ja": "Paste tooltip in Japanese",
    "ne": "Paste tooltip in Nepali"
  }
}
```

`tag` is the stable command identifier emitted in `FxRibbonEvent`. Do not use a
translated caption as application logic.

## Menus And Galleries

Dropdowns, split buttons, medium dropdowns, medium split buttons, and embedded
galleries use `menuItems`:

```json
{
  "caption": "Arrange",
  "tag": "view.arrange",
  "itemType": "splitbutton",
  "menuItems": [
    {"caption": "By name", "tag": "view.arrange.name"},
    {"itemType": "separator"},
    {"caption": "By date", "tag": "view.arrange.date"}
  ]
}
```

Menu item captions and semantic labels can also carry localized maps.

Embedded galleries can set `selectedMenuItemTag` to mark the current choice:

```json
{
  "caption": "Layout",
  "tag": "view.layout",
  "itemType": "gallery",
  "selectedMenuItemTag": "view.layout.details",
  "menuItems": [
    {"caption": "Extra large icons", "tag": "view.layout.extraLarge"},
    {"caption": "Large icons", "tag": "view.layout.large"},
    {"caption": "Details", "tag": "view.layout.details"}
  ]
}
```

Use `columnbreak` between items when a group needs a new vertical command
column without drawing an extra separator.

## Icons

Items refer to icons by `iconKey`. Definitions can embed SVG or PNG icon data:

```json
{
  "icons": {
    "paste": {
      "kind": "svg",
      "data": "<svg viewBox=\"0 0 24 24\"><path d=\"...\"/></svg>"
    }
  }
}
```

At runtime, `FxRibbonIconRegistry` can add or override sources:

- `FxRibbonIconSource.material`
- `FxRibbonIconSource.svgAsset`
- `FxRibbonIconSource.svgString`
- `FxRibbonIconSource.pngAsset`
- `FxRibbonIconSource.pngBytes`
- `FxRibbonIconSource.imageProvider`

Missing icons render a stable placeholder so layout and tests do not collapse.

## Validation

Use `FxRibbonValidator.validateDefinition(definition)` or
`FxRibbonValidator.validateJson(source)`.

Validation reports:

- invalid JSON/root shape
- unsupported schema version
- empty tab set
- missing tab, group, item, or menu captions
- missing or duplicate command tags
- dropdown/split buttons without menu items
- contextual tabs without a context group
- unknown embedded icon references
- invalid BCP-47-like locale tags

Errors should block import or publish. Warnings and info issues can be shown in
the designer while still allowing export.
