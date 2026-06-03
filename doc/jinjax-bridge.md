# JinjaX Bridge

FxDesktop does not port JinjaX to Dart in milestone 1. JinjaX remains the Xojo
side template engine.

FxDesktop provides stable context maps that can be serialized to JSON or passed
through an agent pipeline. Xojo tools can load that context and render templates
with JinjaX.

## Example Context

```dart
const spec = FxLayoutSpec.flex(
  id: 'root',
  direction: FxFlexDirection.row,
  gap: 8,
  flexChildren: [
    FxFlexItemSpec(id: 'sidebar', basis: 240),
    FxFlexItemSpec(id: 'content', grow: 1),
  ],
);

final context = FxFlexLayoutManager(
  spec: spec,
).toTemplateMap(target: FxXojoTarget.desktop);
```

The map contains:

- `kind`
- `direction`
- `gap`
- `flexChildren`
- `target`
- `xojo_manager_class`
- `xojo_setup_event`
- `uses_apply_layout`

## Template Strategy

Recommended Xojo-side templates:

- desktop window generation
- desktop flex layout setup in `Opening`
- web page generation
- web flex layout setup in `Shown`

The template engine should emit Xojo code that adds controls in layout order and
calls `ApplyLayout()` after setup and resize paths.

Reference templates live in:

- `templates/jinjax/desktop_flex_opening.jinja`
- `templates/jinjax/web_flex_shown.jinja`
