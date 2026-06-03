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

## Mobile And Tablet

FxDesktop is not meant to replace normal Flutter responsive design for mobile
or tablet. Standard Flutter and adaptive widgets should be enough for those
targets. Responsive behavior belongs in FxDesktop only when it helps desktop
windows, Flutter Web/WASM, split panes, inspectors, or large/small desktop
workflows.
