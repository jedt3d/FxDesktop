import 'package:flutter/material.dart';

/// How directly an FxDesktop component maps to a Xojo component.
enum FxComponentSupportLevel {
  /// The component has a close semantic and visual match.
  comparable,

  /// The component is implemented specifically because Flutter has no direct
  /// desktop equivalent.
  custom,

  /// The component is a future platform/native integration point.
  future,
}

/// AI-readable component metadata for generation and documentation.
class FxComponentDescriptor {
  /// Creates component metadata.
  const FxComponentDescriptor({
    required this.id,
    required this.name,
    required this.xojoDesktopClass,
    this.xojoWebClass,
    required this.supportLevel,
    this.notes,
  });

  /// Stable component id.
  final String id;

  /// Public FxDesktop class or concept name.
  final String name;

  /// Related Xojo Desktop class.
  final String xojoDesktopClass;

  /// Related Xojo Web class, when the concept maps cleanly.
  final String? xojoWebClass;

  /// Support level for this component.
  final FxComponentSupportLevel supportLevel;

  /// Short implementation or mapping note.
  final String? notes;

  /// Stable map for JinjaX, AI agents, and docs.
  Map<String, Object?> toTemplateMap() {
    return {
      'id': id,
      'name': name,
      'xojo_desktop_class': xojoDesktopClass,
      'xojo_web_class': xojoWebClass,
      'support_level': supportLevel.name,
      'notes': notes,
    };
  }
}

/// Built-in component registry for FxDesktop milestone 1.
const fxComponentRegistry = <FxComponentDescriptor>[
  FxComponentDescriptor(
    id: 'fx.button',
    name: 'FxButton',
    xojoDesktopClass: 'DesktopButton',
    xojoWebClass: 'WebButton',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.checkbox',
    name: 'FxCheckBox',
    xojoDesktopClass: 'DesktopCheckBox',
    xojoWebClass: 'WebCheckBox',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.text_field',
    name: 'FxTextField',
    xojoDesktopClass: 'DesktopTextField',
    xojoWebClass: 'WebTextField',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.text_area',
    name: 'FxTextArea',
    xojoDesktopClass: 'DesktopTextArea',
    xojoWebClass: 'WebTextArea',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.combo_box',
    name: 'FxComboBox',
    xojoDesktopClass: 'DesktopComboBox',
    xojoWebClass: 'WebComboBox',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.flex_layout',
    name: 'FxFlexLayout',
    xojoDesktopClass: 'DesktopFlexLayoutManager',
    xojoWebClass: 'WebFlexLayoutManager',
    supportLevel: FxComponentSupportLevel.custom,
    notes: 'Shared Flexbox-like layout contract for Desktop and Web/WASM.',
  ),
  FxComponentDescriptor(
    id: 'fx.grid_layout',
    name: 'FxGridLayout',
    xojoDesktopClass: 'DesktopFlexLayoutManager',
    xojoWebClass: 'WebFlexLayoutManager',
    supportLevel: FxComponentSupportLevel.custom,
    notes:
        'CSS Grid-like Flutter layout with export metadata for future Xojo generators.',
  ),
  FxComponentDescriptor(
    id: 'fx.list_box',
    name: 'FxListBox',
    xojoDesktopClass: 'DesktopListBox',
    xojoWebClass: 'WebListBox',
    supportLevel: FxComponentSupportLevel.custom,
  ),
  FxComponentDescriptor(
    id: 'fx.grid',
    name: 'FxGrid',
    xojoDesktopClass: 'DesktopGrid',
    xojoWebClass: 'WebListBox',
    supportLevel: FxComponentSupportLevel.custom,
    notes: 'Data/cell grid control, not the CSS-like FxGridLayout manager.',
  ),
];

/// A compact desktop button comparable to Xojo's DesktopButton.
class FxButton extends StatelessWidget {
  /// Creates an FxDesktop button.
  const FxButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.prominence = FxButtonProminence.normal,
  });

  /// Button label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Press callback.
  final VoidCallback? onPressed;

  /// Visual prominence.
  final FxButtonProminence prominence;

  @override
  Widget build(BuildContext context) {
    final childIcon = icon == null ? null : Icon(icon, size: 18);
    return switch (prominence) {
      FxButtonProminence.primary =>
        childIcon == null
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : FilledButton.icon(
                onPressed: onPressed,
                icon: childIcon,
                label: Text(label),
              ),
      FxButtonProminence.quiet =>
        childIcon == null
            ? TextButton(onPressed: onPressed, child: Text(label))
            : TextButton.icon(
                onPressed: onPressed,
                icon: childIcon,
                label: Text(label),
              ),
      FxButtonProminence.normal =>
        childIcon == null
            ? OutlinedButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: childIcon,
                label: Text(label),
              ),
    };
  }
}

/// Desktop button emphasis.
enum FxButtonProminence {
  /// Primary/default action.
  primary,

  /// Normal bordered action.
  normal,

  /// Low-emphasis text action.
  quiet,
}

/// A checkbox comparable to Xojo's DesktopCheckBox.
class FxCheckBox extends StatelessWidget {
  /// Creates an FxDesktop checkbox.
  const FxCheckBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Visible label.
  final String label;

  /// Current value.
  final bool value;

  /// Change callback.
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// A labeled single-line text input comparable to DesktopTextField.
class FxTextField extends StatelessWidget {
  /// Creates an FxDesktop text field.
  const FxTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helpText,
    this.controller,
    this.onChanged,
  });

  /// Visible label.
  final String label;

  /// Placeholder hint.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        helperText: helpText,
        hintText: hintText,
        isDense: true,
        labelText: label,
      ),
    );
  }
}

/// A labeled multiline input comparable to DesktopTextArea.
class FxTextArea extends StatelessWidget {
  /// Creates an FxDesktop text area.
  const FxTextArea({
    super.key,
    required this.label,
    this.hintText,
    this.helpText,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
  });

  /// Visible label.
  final String label;

  /// Placeholder hint.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Minimum visible lines.
  final int minLines;

  /// Maximum visible lines.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        helperText: helpText,
        hintText: hintText,
        isDense: true,
        labelText: label,
      ),
    );
  }
}

/// A framed desktop group comparable to Xojo's DesktopGroupBox.
class FxGroupBox extends StatelessWidget {
  /// Creates an FxDesktop group box.
  const FxGroupBox({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  /// Group title.
  final String title;

  /// Inner content.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
