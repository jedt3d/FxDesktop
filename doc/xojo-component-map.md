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
| `FxGroupBox` | `DesktopGroupBox` | custom group container | Near |
| `FxFlexLayout` | `DesktopFlexLayoutManager` | `WebFlexLayoutManager` | Custom bridge |
| `FxGridLayout` | layout/generation contract | layout/generation contract | Custom bridge |
| `FxListBox` | `DesktopListBox` | `WebListBox` | Custom |
| `FxGrid` | `DesktopGrid` | future/custom | Custom |

## Layout Naming

- `FxFlexLayout` is a CSS Flexbox-like layout widget.
- `FxGridLayout` is a CSS Grid-like layout widget.
- `FxGrid` is a data/cell grid control.
- `FxFlexLayoutManager` and `FxGridLayoutManager` are non-visual adapters that
  export layout specs for templates and generators.

## Milestone 2 Delivered Mappings

Phase 2.1 delivered the first set of core form controls in `v0.2.1`. Phase 2.2
delivered navigation and indexed container controls in `v0.2.2`.

| FxDesktop | Xojo Desktop | Notes |
|---|---|---|
| `FxLabel` | `DesktopLabel` | Plain label, alignment, wrapping, disabled appearance. |
| `FxPopupMenu` | `DesktopPopupMenu` | Fixed-choice menu; not editable. |
| `FxComboBox` | `DesktopComboBox` | Editable text plus list selection and autocomplete. |
| `FxRadioButton` | `DesktopRadioButton` | Single radio option. |
| `FxRadioGroup` | `DesktopRadioGroup` | Managed exclusive option group. |
| `FxDateTimePicker` | `DesktopDateTimePicker` | Date, time, and date-time modes. |
| `FxSlider` | `DesktopSlider` | Numeric range input. |
| `FxSegmentedButton` | `DesktopSegmentedButton` | Single-selection mode selector, often used to switch pages or cards. |
| `FxTabPanel` | `DesktopTabPanel` | Visible tab headers choose indexed content pages. |
| `FxPagePanel` | `DesktopPagePanel` | Headless indexed page container without visible tab headers. |
| `FxCardContainer` | PagePanel/container-stack pattern | Generator-friendly card stack controlled by another widget. |
| `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | Collapsible section control with expanded, collapsed, and disabled states. |

## Milestone 2 Planned Mappings

| FxDesktop | Xojo Desktop | Notes |
|---|---|---|
| `FxStyledLabel` | styled label pattern | Rich text spans for labels/help text. |
| `FxColorPicker` | `DesktopColorPicker` | Color value selector with preview. |
| `FxProgressBar` | `DesktopProgressBar` | Determinate progress. |
| `FxProgressWheel` | `DesktopProgressWheel` | Indeterminate progress/loading. |
| `FxSeparator` | `DesktopSeparator` | Horizontal or vertical separator. |

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

## Mobile And Tablet

FxDesktop is not meant to replace normal Flutter responsive design for mobile
or tablet. Standard Flutter and adaptive widgets should be enough for those
targets. Responsive behavior belongs in FxDesktop only when it helps desktop
windows, Flutter Web/WASM, split panes, inspectors, or large/small desktop
workflows.
