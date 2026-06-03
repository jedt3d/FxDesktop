# Xojo Component Map

FxDesktop maps Flutter widgets to Xojo-style desktop UI concepts. The mapping
is semantic and generation-oriented, not a native-control equivalence.

| FxDesktop | Xojo Desktop | Xojo Web | Status |
|---|---|---|---|
| `FxButton` | `DesktopButton` | `WebButton` | Comparable |
| `FxCheckBox` | `DesktopCheckBox` | `WebCheckBox` | Comparable |
| `FxTextField` | `DesktopTextField` | `WebTextField` | Comparable |
| `FxTextArea` | `DesktopTextArea` | `WebTextArea` | Comparable |
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

## Milestone 2 Planned Mappings

| FxDesktop | Xojo Desktop | Notes |
|---|---|---|
| `FxLabel` | `DesktopLabel` | Plain label, alignment, wrapping, disabled appearance. |
| `FxStyledLabel` | styled label pattern | Rich text spans for labels/help text. |
| `FxPopupMenu` | `DesktopPopupMenu` | Fixed-choice menu; not editable. |
| `FxComboBox` | `DesktopComboBox` | Editable text plus list selection and autocomplete. |
| `FxRadioButton` | `DesktopRadioButton` | Single radio option. |
| `FxRadioGroup` | `DesktopRadioGroup` | Managed exclusive option group. |
| `FxDateTimePicker` | `DesktopDateTimePicker` | Date, time, and date-time modes. |
| `FxColorPicker` | `DesktopColorPicker` | Color value selector with preview. |
| `FxSlider` | `DesktopSlider` | Numeric range input. |
| `FxSegmentedButton` | `DesktopSegmentedButton` | Mode selector, often used to switch pages/cards. |
| `FxTabPanel` | `DesktopTabPanel` | Visible tab container. |
| `FxPagePanel` | `DesktopPagePanel` | Indexed page container without visible tabs. |
| `FxCardContainer` | PagePanel/container-stack pattern | Generator-friendly indexed card stack. |
| `FxDisclosureTriangle` | `DesktopDisclosureTriangle` | Collapsible section control. |
| `FxPopupArrow` | `DesktopPopupArrow` | Compact action/menu disclosure. |
| `FxUpDownArrows` | `DesktopUpDownArrows` | Numeric stepper. |
| `FxVerticalScrollBar` | `DesktopScrollbar` | Explicit vertical scrollbar widget. |
| `FxHorizontalScrollBar` | `DesktopScrollbar` | Explicit horizontal scrollbar widget. |
| `FxProgressBar` | `DesktopProgressBar` | Determinate progress. |
| `FxProgressWheel` | `DesktopProgressWheel` | Indeterminate progress/loading. |
| `FxSeparator` | `DesktopSeparator` | Horizontal or vertical separator. |

See [Milestone 2: Xojo Desktop Control Parity](milestone-2-control-parity.md)
for priority, phases, demo presentation, and definition of done.

## Mobile And Tablet

FxDesktop is not meant to replace normal Flutter responsive design for mobile
or tablet. Standard Flutter and adaptive widgets should be enough for those
targets. Responsive behavior belongs in FxDesktop only when it helps desktop
windows, Flutter Web/WASM, split panes, inspectors, or large/small desktop
workflows.
