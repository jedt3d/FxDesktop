# Xojo Component Map

FxDesktop maps Flutter widgets to Xojo-style desktop UI concepts. The mapping
is semantic and generation-oriented, not a native-control equivalence.

| FxDesktop | Xojo Desktop | Xojo Web | Status |
|---|---|---|---|
| `FxButton` | `DesktopButton` | `WebButton` | Comparable |
| `FxCheckBox` | `DesktopCheckBox` | `WebCheckBox` | Comparable |
| `FxLabel` | `DesktopLabel` | `WebLabel` | Comparable |
| `FxTextField` | `DesktopTextField` | `WebTextField` | Comparable |
| `FxTextArea` | `DesktopTextArea` | `WebTextArea` | Comparable |
| `FxPopupMenu` | `DesktopPopupMenu` | `WebPopupMenu` | Comparable |
| `FxComboBox` | `DesktopComboBox` | `WebComboBox` | Comparable |
| `FxRadioButton` | `DesktopRadioButton` | `WebRadioButton` | Comparable |
| `FxRadioGroup` | `DesktopRadioGroup` | `WebRadioGroup` | Comparable |
| `FxDateTimePicker` | `DesktopDateTimePicker` | `WebDatePicker` | Comparable |
| `FxSlider` | `DesktopSlider` | `WebSlider` | Comparable |
| `FxSegmentedButton` | `DesktopSegmentedButton` | generation/custom | Comparable |
| `FxTabPanel` | `DesktopTabPanel` | generation/custom | Comparable |
| `FxPagePanel` | `DesktopPagePanel` | generation/custom | Comparable |
| `FxCardContainer` | PagePanel/container-stack pattern | generation/custom | Custom |
| `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | generation/custom | Comparable |
| `FxColorPicker` | `DesktopColorPicker` | generation/custom | Comparable |
| `FxProgressBar` | `DesktopProgressBar` | generation/custom | Comparable |
| `FxProgressWheel` | `DesktopProgressWheel` | generation/custom | Comparable |
| `FxSeparator` | `DesktopSeparator` | generation/custom | Comparable |
| `FxStyledLabel` | styled label pattern | generation/custom | Custom |
| `FxGroupBox` | `DesktopGroupBox` | custom group container | Near |
| `FxFlexLayout` | `DesktopFlexLayoutManager` | `WebFlexLayoutManager` | Custom bridge |
| `FxGridLayout` | layout/generation contract | layout/generation contract | Custom bridge |
| `FxListBox` | `DesktopListBox` | `WebListBox` | Custom |
| `FxGrid` | `DesktopGrid` | future/custom | Custom |
| `FxLocalizationGallery` | localization preview window | generation/custom | Custom |
| `FxRibbonToolbar` | `XjRibbon` / `DesktopCanvas` ribbon | `XjRibbon` / `WebCanvas` ribbon | Custom |
| `FxRibbonDesigner` | `XjRibbon Designer` | embeddable Flutter web/desktop designer | Custom |
| `FxRibbonIconView` | `XjRibbon` icon renderer | supporting renderer | Custom |

## Layout Naming

- `FxFlexLayout` is a CSS Flexbox-like layout widget.
- `FxGridLayout` is a CSS Grid-like layout widget.
- `FxGrid` is a data/cell grid control.
- `FxFlexLayoutManager` and `FxGridLayoutManager` are non-visual adapters that
  export layout specs for templates and generators.

## Milestone 2 Delivered Mappings

Phase 2.1 delivered the first set of core form controls in `v0.2.1`. Phase 2.2
delivered navigation and indexed container controls in `v0.2.2`. Phase 2.3
delivered compact utility and display controls in `v0.2.3`. Phase 2.4 deepened
text inputs and polished nullable color selection in `v0.2.4`. Phase 2.5 added
text input constraints, required indicators, character counters, and
single-line display formats in `v0.2.5`. Phase 2.6 polished mixed decorated
input alignment in `v0.2.6`.

| FxDesktop | Xojo Desktop | Notes |
|---|---|---|
| `FxLabel` | `DesktopLabel` | Plain label, alignment, wrapping, disabled appearance. |
| `FxPopupMenu` | `DesktopPopupMenu` | Fixed-choice menu; not editable. |
| `FxComboBox` | `DesktopComboBox` | Editable text plus list selection and autocomplete. |
| `FxRadioButton` | `DesktopRadioButton` | Single radio option. |
| `FxRadioGroup` | `DesktopRadioGroup` | Managed exclusive option group. |
| `FxDateTimePicker` | `DesktopDateTimePicker` | Date, time, and date-time modes. |
| `FxPopupMenu` input depth | `DesktopPopupMenu` | Helper/error text and reserved supporting space for mixed form rows. |
| `FxComboBox` input depth | `DesktopComboBox` | Helper/error text and reserved supporting space for mixed form rows. |
| `FxSlider` | `DesktopSlider` | Numeric range input. |
| `FxSegmentedButton` | `DesktopSegmentedButton` | Single-selection mode selector, often used to switch pages or cards. |
| `FxTabPanel` | `DesktopTabPanel` | Visible tab headers choose indexed content pages. |
| `FxPagePanel` | `DesktopPagePanel` | Headless indexed page container without visible tab headers. |
| `FxCardContainer` | PagePanel/container-stack pattern | Generator-friendly card stack controlled by another widget. |
| `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | Collapsible section control with expanded, collapsed, and disabled states. |
| `FxColorPicker` | `DesktopColorPicker` | Nullable color picker with explicit no-color action, HSV sliders, and RGB hex entry. |
| `FxProgressBar` | `DesktopProgressBar` | Determinate progress indicator. |
| `FxProgressWheel` | `DesktopProgressWheel` | Indeterminate loading indicator. |
| `FxSeparator` | `DesktopSeparator` | Horizontal or vertical visual separator. |
| `FxStyledLabel` | styled label pattern | Rich label/help text with mixed text spans. |
| `FxTextField` depth | `DesktopTextField` | Validation state, prefix/suffix icons, password mode, constraints, required state, character count, pattern masks, and commit-time number formatting. |
| `FxTextArea` depth | `DesktopTextArea` | Validation state, predictable multiline scrolling, constraints, required state, character count, and forbidden input metadata. |

## Milestone 2 Documented Non-Duplication Candidates

These Xojo controls may not need standalone FxDesktop widgets if standard
Flutter behavior already covers the interaction. Keep the mapping documented so
AI agents and generators understand why a component is or is not created.

| Xojo Desktop | FxDesktop Decision | Reason |
|---|---|---|
| `DesktopPopupArrow` | Use `PopupMenuButton`, `MenuAnchor`, or a thin `FxPopupArrow` adapter only when needed. | Flutter already has mature popup/menu patterns, so a full duplicate control is unnecessary unless Xojo export needs the explicit component. |
| `DesktopUpDownArrows` | Prefer a numeric-field stepper accessory before a standalone widget. | Up/down arrows normally need a bound numeric value; standalone arrows are less useful in Flutter UI. |
| `DesktopScrollbar` vertical | Prefer Flutter `Scrollbar` attached to a scrollable. | Flutter manages scroll behavior, thumb state, and controller binding already. |
| `DesktopScrollbar` horizontal | Prefer Flutter `Scrollbar` attached to horizontal scroll views. | Tables and grids should expose horizontal scrolling through their own scroll containers rather than manual scrollbar widgets. |

See [Milestone 2: Xojo Desktop Control Parity](milestone-2-control-parity.md)
for priority, phases, demo presentation, and definition of done.

## Milestone 3 Delivered Table Depth

Milestone 3 is delivered through `v0.3.6`. Keep the semantic split clear:

| FxDesktop | Xojo Desktop | Delivered table direction |
|---|---|---|
| `FxListBox` | `DesktopListBox` | Row-oriented record list with row selection, multi-selection, sorting, column sizing/visibility, row state, optional cell editing, lookup editors, input masks, row reordering, TSV copy/paste, undo integration, and generator metadata. |
| `FxGrid` | `DesktopGrid` | Cell-oriented data grid with cell/row/range selection, keyboard traversal, sorting, sizing, inline editing, validation, lookup editors, input masks, ellipsis action buttons, TSV clipboard workflows, undo integration, and generator metadata. |

Advanced `0.3.x` refinements include custom cell renderers, hosted lookup
combobox overlays, multi-column database lookups, active row/column background
highlighting, and performance tests for large row and wide column sets.

See [Milestone 3: ListBox And Grid Depth](milestone-3-listbox-grid.md) for the
delivered release history and [Advanced Grid Features (v0.3.6)](milestone-6-advanced-grid-features.md)
for the latest cell-editing features.

## Milestone 4 Delivered Localization Foundation

Milestone 4 is delivered in `v0.4.0` before the next major component surface.
The source of truth is Flutter-native ARB localization with checked-in generated
localizations, while `.po` and `.pot` files are supported as translator bridge
formats. Duplicate English labels stay as separate keys when their component or
workflow context differs, matching the way Xojo projects can need different
translations for identical source words in different controls. The first
localization set covers English, Thai, Japanese, and Nepali, plus
`FxLocalizationGallery`, a one-window gallery that switches existing FxDesktop
component families between those languages.

See [Localization](localization.md) for the implementation guide and
[Milestone 4: Localization Foundation](milestone-4-localization.md) for the
acceptance map.

## Milestone 5 Delivered Ribbon Surface

Milestone 5 is delivered in `v0.5.0` with an Office-style ribbon toolbar and
visual designer for large Flutter desktop and web surfaces. It transfers the
Dart model/schema lessons from `jaspr-ribbon-toolbar` and the original Xojo
control semantics from `XjRibbon`, while adapting the renderer to Flutter
widgets, semantics, focus, menus, pointer-kind handling, theming, and the
Milestone 4 localization foundation.

| FxDesktop | Source concept | Delivered direction |
|---|---|---|
| `FxRibbonToolbar` | `RibbonToolbar` / `XjRibbon` | Widget-first ribbon with tabs, groups, large/small commands, dropdowns, split buttons, toggles, checkboxes, separators, contextual tabs, collapse behavior, SVG/PNG/Material icons, keytips, mouse, keyboard, touch mode, semantic events, and localized captions. |
| `FxRibbonDesigner` | Jaspr/Xojo ribbon designers | Embeddable visual designer with hierarchy editing, inspector, live preview, validation, JSON export callback, localized caption editing, and shared model updates. |
| `FxRibbonIconView` | Jaspr/Xojo icon renderer | Supporting public renderer for SVG, PNG, Material, image-provider, and placeholder icon sources. |

See [Milestone 5: Ribbon Toolbar And Visual Designer](milestone-5-ribbon-toolbar-designer.md)
for the delivered acceptance map, plus [Ribbon Schema](ribbon-schema.md) and
[Ribbon Designer](ribbon-designer.md) for usage details.

## Mobile And Tablet

FxDesktop is not meant to replace normal Flutter responsive design for mobile
or tablet. Standard Flutter and adaptive widgets should be enough for those
targets. Responsive behavior belongs in FxDesktop only when it helps desktop
windows, Flutter Web/WASM, split panes, inspectors, or large/small desktop
workflows.
