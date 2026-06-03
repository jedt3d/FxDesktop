# Layout Contract

FxDesktop layout APIs are shared by Flutter Desktop and Flutter Web/WASM.
Desktop/Web differences are handled only by export adapters.

## Flex

`FxFlexLayout` maps the same core terms as the Xojo flex layout libraries:

| FxDesktop | Meaning | Xojo export |
|---|---|---|
| `direction` | row or column flow | layout direction |
| `justify` | main-axis distribution | justify content |
| `align` | cross-axis alignment | align items |
| `gap` | child spacing | gap |
| `padding` | container inset | padding |
| `FxFlexItem.grow` | grow factor | `AddControl(control, growFactor)` |

`FxFlexLayoutManager.toTemplateMap()` exports stable keys for JinjaX and Xojo
generators. For Desktop it points to `DesktopFlexLayoutManager`; for Web it
points to `WebFlexLayoutManager`.

## Grid Layout

`FxGridLayout` is a CSS Grid-like layout manager. It is not the same as
`FxGrid`.

Use `FxGridLayout` for page/form structure:

- fixed, flexible, auto, and intrinsic tracks
- named areas
- row and column gaps
- explicit placement and spans

Use `FxGrid` for data/cell UI comparable to Xojo `DesktopGrid`.

## Export Policy

Layout specs should be serializable and deterministic:

- use stable child ids
- avoid machine-local paths
- keep third-party dependency types out of template maps
- preserve enough metadata for Xojo text project generation
