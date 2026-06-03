import 'package:flutter/material.dart';

/// Layout direction for choice controls with multiple options.
enum FxChoiceOrientation {
  /// Stack options from top to bottom.
  vertical,

  /// Lay options out from left to right, wrapping when needed.
  horizontal,
}

/// A single option in an [FxRadioGroup].
class FxRadioOption<T> {
  /// Creates a radio group option.
  const FxRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// Value selected when this option is chosen.
  final T value;

  /// Visible option label.
  final String label;

  /// Whether this option is selectable when its group is enabled.
  final bool enabled;
}

/// A single radio option comparable to Xojo's DesktopRadioButton.
class FxRadioButton<T> extends StatelessWidget {
  /// Creates an FxDesktop radio button.
  const FxRadioButton({
    super.key,
    required this.label,
    required this.value,
    this.groupValue,
    this.selected,
    this.onChanged,
    this.enabled = true,
  });

  /// Visible option label.
  final String label;

  /// Value represented by this radio button.
  final T value;

  /// Current group value used to determine selected state.
  final T? groupValue;

  /// Standalone selected state used when [groupValue] is not supplied.
  final bool? selected;

  /// Called when this radio button is selected.
  final ValueChanged<T>? onChanged;

  /// Whether this radio button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveGroupValue = groupValue ?? (selected == true ? value : null);
    final isSelected = effectiveGroupValue == value;
    final isEnabled = enabled && onChanged != null;

    return Material(
      type: MaterialType.transparency,
      child: RadioGroup<T>(
        groupValue: effectiveGroupValue,
        onChanged: (newValue) {
          if (isEnabled && newValue != null) {
            onChanged?.call(newValue);
          }
        },
        child: RadioListTile<T>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          enabled: isEnabled,
          selected: isSelected,
          title: Text(label),
          value: value,
        ),
      ),
    );
  }
}

/// A managed exclusive option set comparable to Xojo's DesktopRadioGroup.
class FxRadioGroup<T> extends StatelessWidget {
  /// Creates an FxDesktop radio group.
  const FxRadioGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.orientation = FxChoiceOrientation.vertical,
    this.enabled = true,
    this.spacing = 8,
  });

  /// Options displayed by the group.
  final List<FxRadioOption<T>> options;

  /// Currently selected option value.
  final T? value;

  /// Called when the selected option changes.
  final ValueChanged<T>? onChanged;

  /// Whether options are stacked vertically or laid out horizontally.
  final FxChoiceOrientation orientation;

  /// Whether the group and all selectable options are enabled.
  final bool enabled;

  /// Spacing between options.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final isGroupEnabled = enabled && onChanged != null;
    final children = [
      for (final option in options)
        _FxRadioOptionTile<T>(
          label: option.label,
          value: option.value,
          selected: option.value == value,
          enabled: isGroupEnabled && option.enabled,
        ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (newValue) {
          if (isGroupEnabled && newValue != null) {
            onChanged?.call(newValue);
          }
        },
        child: switch (orientation) {
          FxChoiceOrientation.vertical => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _spacedVertical(children),
          ),
          FxChoiceOrientation.horizontal => Wrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final child in children) IntrinsicWidth(child: child),
            ],
          ),
        },
      ),
    );
  }

  List<Widget> _spacedVertical(List<Widget> children) {
    if (children.length < 2 || spacing == 0) {
      return children;
    }

    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(height: spacing),
        children[index],
      ],
    ];
  }
}

/// A numeric range input comparable to Xojo's DesktopSlider.
class FxSlider extends StatelessWidget {
  /// Creates an FxDesktop slider.
  const FxSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.enabled = true,
    this.valueLabel,
  }) : assert(min <= max, 'min must be less than or equal to max'),
       assert(
         value >= min && value <= max,
         'value must be between min and max',
       ),
       assert(divisions == null || divisions > 0);

  /// Current slider value.
  final double value;

  /// Minimum allowed value.
  final double min;

  /// Maximum allowed value.
  final double max;

  /// Optional number of discrete divisions between [min] and [max].
  final int? divisions;

  /// Called when the slider value changes.
  final ValueChanged<double>? onChanged;

  /// Called when a slider drag begins.
  final ValueChanged<double>? onChangeStart;

  /// Called when a slider drag is committed.
  final ValueChanged<double>? onChangeEnd;

  /// Whether the slider is enabled.
  final bool enabled;

  /// Optional visible label for the current value.
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onChanged != null;
    final label = valueLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: isEnabled ? onChanged : null,
            onChangeStart: isEnabled ? onChangeStart : null,
            onChangeEnd: isEnabled ? onChangeEnd : null,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _FxRadioOptionTile<T> extends StatelessWidget {
  const _FxRadioOptionTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final T value;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      enabled: enabled,
      selected: selected,
      title: Text(label),
      value: value,
    );
  }
}
