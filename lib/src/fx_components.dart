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

/// Built-in component registry for FxDesktop.
const fxComponentRegistry = <FxComponentDescriptor>[
  FxComponentDescriptor(
    id: 'fx.label',
    name: 'FxLabel',
    xojoDesktopClass: 'DesktopLabel',
    xojoWebClass: 'WebLabel',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
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
    notes:
        'Single-line text input with validation, helper text, read-only, password, and icon states.',
  ),
  FxComponentDescriptor(
    id: 'fx.text_area',
    name: 'FxTextArea',
    xojoDesktopClass: 'DesktopTextArea',
    xojoWebClass: 'WebTextArea',
    supportLevel: FxComponentSupportLevel.comparable,
    notes:
        'Multiline text input with validation, helper text, read-only, and predictable scrolling.',
  ),
  FxComponentDescriptor(
    id: 'fx.combo_box',
    name: 'FxComboBox',
    xojoDesktopClass: 'DesktopComboBox',
    xojoWebClass: 'WebComboBox',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Editable text input with autocomplete suggestions.',
  ),
  FxComponentDescriptor(
    id: 'fx.popup_menu',
    name: 'FxPopupMenu',
    xojoDesktopClass: 'DesktopPopupMenu',
    xojoWebClass: 'WebPopupMenu',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Fixed-choice selector without free text entry.',
  ),
  FxComponentDescriptor(
    id: 'fx.radio_button',
    name: 'FxRadioButton',
    xojoDesktopClass: 'DesktopRadioButton',
    xojoWebClass: 'WebRadioButton',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.radio_group',
    name: 'FxRadioGroup',
    xojoDesktopClass: 'DesktopRadioGroup',
    xojoWebClass: 'WebRadioGroup',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.date_time_picker',
    name: 'FxDateTimePicker',
    xojoDesktopClass: 'DesktopDateTimePicker',
    xojoWebClass: 'WebDatePicker',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Date, time, and date-time picker; not a plain text field.',
  ),
  FxComponentDescriptor(
    id: 'fx.slider',
    name: 'FxSlider',
    xojoDesktopClass: 'DesktopSlider',
    xojoWebClass: 'WebSlider',
    supportLevel: FxComponentSupportLevel.comparable,
  ),
  FxComponentDescriptor(
    id: 'fx.segmented_button',
    name: 'FxSegmentedButton',
    xojoDesktopClass: 'DesktopSegmentedButton',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Mode selector, often used to switch pages or cards.',
  ),
  FxComponentDescriptor(
    id: 'fx.tab_panel',
    name: 'FxTabPanel',
    xojoDesktopClass: 'DesktopTabPanel',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Visible tab headers choose indexed pages.',
  ),
  FxComponentDescriptor(
    id: 'fx.page_panel',
    name: 'FxPagePanel',
    xojoDesktopClass: 'DesktopPagePanel',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Headless indexed page container without visible tab headers.',
  ),
  FxComponentDescriptor(
    id: 'fx.card_container',
    name: 'FxCardContainer',
    xojoDesktopClass: 'DesktopPagePanel',
    supportLevel: FxComponentSupportLevel.custom,
    notes:
        'Generator-friendly indexed card stack controlled by another widget.',
  ),
  FxComponentDescriptor(
    id: 'fx.disclosure_triangle',
    name: 'FxDisclosureTriangle',
    xojoDesktopClass: 'DesktopDisclosureTriangle',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Collapsible section control.',
  ),
  FxComponentDescriptor(
    id: 'fx.color_picker',
    name: 'FxColorPicker',
    xojoDesktopClass: 'DesktopColorPicker',
    supportLevel: FxComponentSupportLevel.comparable,
    notes:
        'Nullable color picker with no-color, HSV sliders, and RGB hex input.',
  ),
  FxComponentDescriptor(
    id: 'fx.progress_bar',
    name: 'FxProgressBar',
    xojoDesktopClass: 'DesktopProgressBar',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Determinate progress indicator.',
  ),
  FxComponentDescriptor(
    id: 'fx.progress_wheel',
    name: 'FxProgressWheel',
    xojoDesktopClass: 'DesktopProgressWheel',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Indeterminate progress or loading indicator.',
  ),
  FxComponentDescriptor(
    id: 'fx.separator',
    name: 'FxSeparator',
    xojoDesktopClass: 'DesktopSeparator',
    supportLevel: FxComponentSupportLevel.comparable,
    notes: 'Horizontal or vertical separator for dense desktop layouts.',
  ),
  FxComponentDescriptor(
    id: 'fx.styled_label',
    name: 'FxStyledLabel',
    xojoDesktopClass: 'DesktopLabel',
    supportLevel: FxComponentSupportLevel.custom,
    notes: 'Styled label/help text pattern with mixed text spans.',
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
    this.onChanged,
    this.tristate = false,
  });

  /// Visible label.
  final String label;

  /// Current value.
  final bool? value;

  /// Change callback.
  final ValueChanged<bool?>? onChanged;

  /// Whether the checkbox supports an indeterminate value.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        tristate: tristate,
        value: tristate ? value : value ?? false,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

/// A labeled single-line text input comparable to DesktopTextField.
class FxTextField extends StatefulWidget {
  /// Creates an FxDesktop text field.
  const FxTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helpText,
    this.errorText,
    this.controller,
    this.value,
    this.onChanged,
    this.onCommit,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
  });

  /// Visible label.
  final String label;

  /// Placeholder hint.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Validation error text shown below the field.
  final String? errorText;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Current text value when [controller] is not supplied.
  final String? value;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Called when editing is committed by submit or focus loss.
  final ValueChanged<String>? onCommit;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Whether the text can be selected but not edited.
  final bool readOnly;

  /// Whether text entry is obscured for password-like input.
  final bool obscureText;

  /// Optional leading icon.
  final IconData? prefixIcon;

  /// Optional trailing icon.
  final IconData? suffixIcon;

  /// Optional focus node for host-managed focus.
  final FocusNode? focusNode;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxTextField',
      'xojo_desktop_class': 'DesktopTextField',
      'label': label,
      'hintText': hintText,
      'helpText': helpText,
      'errorText': errorText,
      'enabled': enabled,
      'readOnly': readOnly,
      'obscureText': obscureText,
      'hasPrefixIcon': prefixIcon != null,
      'hasSuffixIcon': suffixIcon != null,
    };
  }

  @override
  State<FxTextField> createState() => _FxTextFieldState();
}

class _FxTextFieldState extends State<FxTextField> {
  late final TextEditingController _ownedController;
  late final FocusNode _ownedFocusNode;
  late String _lastCommittedText;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController(text: widget.value ?? '');
    _ownedFocusNode = FocusNode();
    _lastCommittedText = _controller.text;
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(FxTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode).removeListener(
        _handleFocusChanged,
      );
      _focusNode.addListener(_handleFocusChanged);
    }
    if (widget.controller == null &&
        widget.value != oldWidget.value &&
        widget.value != _ownedController.text) {
      _ownedController.text = widget.value ?? '';
      _lastCommittedText = _ownedController.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _ownedFocusNode.dispose();
    _ownedController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _commitIfChanged();
    }
  }

  void _commitIfChanged() {
    final currentText = _controller.text;
    if (currentText == _lastCommittedText) {
      return;
    }
    _lastCommittedText = currentText;
    widget.onCommit?.call(currentText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      onSubmitted: (_) => _commitIfChanged(),
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
        helperText: widget.helpText,
        hintText: widget.hintText,
        isDense: true,
        labelText: widget.label,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 18),
        suffixIcon: widget.suffixIcon == null
            ? null
            : Icon(widget.suffixIcon, size: 18),
      ),
    );
  }
}

/// A labeled multiline input comparable to DesktopTextArea.
class FxTextArea extends StatefulWidget {
  /// Creates an FxDesktop text area.
  const FxTextArea({
    super.key,
    required this.label,
    this.hintText,
    this.helpText,
    this.errorText,
    this.controller,
    this.scrollController,
    this.value,
    this.onChanged,
    this.onCommit,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
  });

  /// Visible label.
  final String label;

  /// Placeholder hint.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Validation error text shown below the text area.
  final String? errorText;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Optional scroll controller for deterministic multiline scrolling.
  final ScrollController? scrollController;

  /// Current text value when [controller] is not supplied.
  final String? value;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Called when editing is committed by focus loss or editing completion.
  final ValueChanged<String>? onCommit;

  /// Minimum visible lines.
  final int minLines;

  /// Maximum visible lines.
  final int maxLines;

  /// Whether the text area is enabled.
  final bool enabled;

  /// Whether the text can be selected but not edited.
  final bool readOnly;

  /// Optional focus node for host-managed focus.
  final FocusNode? focusNode;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxTextArea',
      'xojo_desktop_class': 'DesktopTextArea',
      'label': label,
      'hintText': hintText,
      'helpText': helpText,
      'errorText': errorText,
      'enabled': enabled,
      'readOnly': readOnly,
      'minLines': minLines,
      'maxLines': maxLines,
      'hasScrollController': scrollController != null,
    };
  }

  @override
  State<FxTextArea> createState() => _FxTextAreaState();
}

class _FxTextAreaState extends State<FxTextArea> {
  late final TextEditingController _ownedController;
  late final ScrollController _ownedScrollController;
  late final FocusNode _ownedFocusNode;
  late String _lastCommittedText;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController;

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController(text: widget.value ?? '');
    _ownedScrollController = ScrollController();
    _ownedFocusNode = FocusNode();
    _lastCommittedText = _controller.text;
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(FxTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode).removeListener(
        _handleFocusChanged,
      );
      _focusNode.addListener(_handleFocusChanged);
    }
    if (widget.controller == null &&
        widget.value != oldWidget.value &&
        widget.value != _ownedController.text) {
      _ownedController.text = widget.value ?? '';
      _lastCommittedText = _ownedController.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _ownedFocusNode.dispose();
    _ownedController.dispose();
    _ownedScrollController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _commitIfChanged();
    }
  }

  void _commitIfChanged() {
    final currentText = _controller.text;
    if (currentText == _lastCommittedText) {
      return;
    }
    _lastCommittedText = currentText;
    widget.onCommit?.call(currentText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: widget.onChanged,
      onEditingComplete: _commitIfChanged,
      readOnly: widget.readOnly,
      scrollController: _scrollController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
        helperText: widget.helpText,
        hintText: widget.hintText,
        isDense: true,
        labelText: widget.label,
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
