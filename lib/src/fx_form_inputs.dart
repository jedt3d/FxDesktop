import 'package:flutter/material.dart';

import 'fx_localizations.dart';
import 'fx_input_decoration.dart';

/// A plain label comparable to Xojo's DesktopLabel.
class FxLabel extends StatelessWidget {
  /// Creates an FxDesktop label.
  const FxLabel({
    super.key,
    required this.text,
    this.enabled = true,
    this.softWrap = true,
    this.alignment = TextAlign.start,
    this.style,
  });

  /// Label text.
  final String text;

  /// Whether the label uses the normal enabled appearance.
  final bool enabled;

  /// Whether long label text wraps onto multiple lines.
  final bool softWrap;

  /// Horizontal text alignment.
  final TextAlign alignment;

  /// Optional text style applied before disabled-state opacity.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      softWrap: softWrap,
      textAlign: alignment,
      style: style,
    );

    if (enabled) {
      return label;
    }

    return Opacity(opacity: 0.38, child: label);
  }
}

/// A fixed-choice menu comparable to Xojo's DesktopPopupMenu.
class FxPopupMenu extends StatelessWidget {
  /// Creates an FxDesktop popup menu.
  const FxPopupMenu({
    super.key,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.hintText,
    this.helpText,
    this.errorText,
    this.reserveSupportingTextSpace = false,
    this.emptyText,
  });

  /// Fixed option captions available to select.
  final List<String> options;

  /// Currently selected option caption.
  final String? selectedValue;

  /// Selection callback.
  final ValueChanged<String?>? onChanged;

  /// Whether the popup menu is enabled.
  final bool enabled;

  /// Optional field label.
  final String? label;

  /// Placeholder shown when no option is selected.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Validation error text shown below the menu.
  final String? errorText;

  /// Whether to reserve one supporting-text line when no helper or error is
  /// present.
  final bool reserveSupportingTextSpace;

  /// Text shown when the menu has no options.
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final hasOptions = options.isNotEmpty;
    final effectiveValue =
        selectedValue != null && options.contains(selectedValue)
        ? selectedValue
        : null;
    final isEnabled = enabled && hasOptions && onChanged != null;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: errorText,
        helperText: fxEffectiveHelperText(
          helpText: helpText,
          errorText: errorText,
          reserveSupportingTextSpace: reserveSupportingTextSpace,
        ),
        isDense: true,
        labelText: label,
      ),
      hint: Text(
        hasOptions
            ? hintText ?? ''
            : emptyText ?? fxDesktopLocalizationsOf(context).popupMenuNoOptions,
      ),
      initialValue: effectiveValue,
      isExpanded: true,
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: isEnabled ? onChanged : null,
    );
  }
}

/// An editable combo box comparable to Xojo's DesktopComboBox.
class FxComboBox extends StatefulWidget {
  /// Creates an FxDesktop combo box.
  const FxComboBox({
    super.key,
    required this.options,
    this.value,
    this.controller,
    this.onChanged,
    this.onCommit,
    this.onOptionSelected,
    this.enabled = true,
    this.label,
    this.hintText,
    this.helpText,
    this.errorText,
    this.reserveSupportingTextSpace = false,
    this.maxVisibleOptions = 6,
  }) : assert(maxVisibleOptions > 0);

  /// Option captions used for autocomplete suggestions.
  final List<String> options;

  /// Current text value when [controller] is not supplied.
  final String? value;

  /// Optional text controller for externally managed editable text.
  final TextEditingController? controller;

  /// Editable text change callback.
  final ValueChanged<String>? onChanged;

  /// Called when editable text is committed by blur, submit, or option pick.
  final ValueChanged<String>? onCommit;

  /// Callback fired when an autocomplete option is selected.
  final ValueChanged<String>? onOptionSelected;

  /// Whether the combo box is enabled.
  final bool enabled;

  /// Optional field label.
  final String? label;

  /// Placeholder shown when the editable text is empty.
  final String? hintText;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Validation error text shown below the combo box.
  final String? errorText;

  /// Whether to reserve one supporting-text line when no helper or error is
  /// present.
  final bool reserveSupportingTextSpace;

  /// Maximum number of autocomplete options visible at one time.
  final int maxVisibleOptions;

  @override
  State<FxComboBox> createState() => _FxComboBoxState();
}

class _FxComboBoxState extends State<FxComboBox> {
  late final TextEditingController _ownedController;
  late final FocusNode _focusNode;
  late String _lastCommittedText;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _lastCommittedText = _controller.text;
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(FxComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _focusNode.dispose();
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
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        if (!widget.enabled || widget.options.isEmpty) {
          return const Iterable<String>.empty();
        }

        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return widget.options;
        }

        return widget.options.where(
          (option) => option.toLowerCase().contains(query),
        );
      },
      onSelected: (option) {
        widget.onOptionSelected?.call(option);
        widget.onChanged?.call(option);
        if (option != _lastCommittedText) {
          _lastCommittedText = option;
          widget.onCommit?.call(option);
        }
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              enabled: widget.enabled,
              focusNode: focusNode,
              onChanged: widget.onChanged,
              onSubmitted: (_) {
                onFieldSubmitted();
                _commitIfChanged();
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorText: widget.errorText,
                helperText: fxEffectiveHelperText(
                  helpText: widget.helpText,
                  errorText: widget.errorText,
                  reserveSupportingTextSpace: widget.reserveSupportingTextSpace,
                ),
                hintText: widget.hintText,
                isDense: true,
                labelText: widget.label,
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        final visibleOptions = options.take(widget.maxVisibleOptions).toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 40.0 * widget.maxVisibleOptions,
                minWidth: 180,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: visibleOptions.length,
                itemBuilder: (context, index) {
                  final option = visibleOptions[index];
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
