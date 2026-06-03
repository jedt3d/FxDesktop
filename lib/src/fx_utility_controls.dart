import 'package:flutter/material.dart';

import 'fx_theme.dart';

/// Shows a color picker and returns the selected color.
typedef FxColorPickerDelegate =
    Future<Color?> Function(BuildContext context, Color? selectedColor);

/// Orientation for [FxSeparator].
enum FxSeparatorOrientation {
  /// Draws a left-to-right separator.
  horizontal,

  /// Draws a top-to-bottom separator.
  vertical,
}

/// A desktop color selector comparable to Xojo's DesktopColorPicker.
///
/// The control renders as a compact button with a color swatch and text. Tests
/// and host apps can inject [picker] to avoid depending on a platform dialog.
class FxColorPicker extends StatelessWidget {
  /// Creates an FxDesktop color picker.
  const FxColorPicker({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.picker,
  });

  /// Visible label for the color value.
  final String label;

  /// Current selected color.
  final Color? value;

  /// Called when a new color is selected.
  final ValueChanged<Color>? onChanged;

  /// Whether the picker can be opened.
  final bool enabled;

  /// Optional color picker delegate for tests or custom integrations.
  final FxColorPickerDelegate? picker;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxColorPicker',
      'xojo_desktop_class': 'DesktopColorPicker',
      'label': label,
      'value': _colorToTemplateValue(value),
      'enabled': enabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fxTheme = FxTheme.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final interactive = enabled && onChanged != null;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final valueText = _formatColor(value);

    return Semantics(
      button: true,
      enabled: interactive,
      label: label,
      value: valueText,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: fxTheme.controlSize.height),
        child: OutlinedButton(
          onPressed: interactive ? () => _selectColor(context) : null,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(0, fxTheme.controlSize.height),
            padding: fxTheme.controlPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(fxTheme.borderRadius),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FxColorSwatch(color: value, enabled: enabled),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$label: $valueText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectColor(BuildContext context) async {
    final selectedColor = await (picker ?? _showDefaultColorPicker)(
      context,
      value,
    );
    if (selectedColor != null) {
      onChanged?.call(selectedColor);
    }
  }

  Future<Color?> _showDefaultColorPicker(
    BuildContext context,
    Color? selectedColor,
  ) {
    return showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(label),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in _defaultPalette)
                _FxPaletteButton(
                  color: color,
                  selected: color == selectedColor,
                  onTap: () => Navigator.of(dialogContext).pop(color),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A determinate progress indicator comparable to Xojo's DesktopProgressBar.
class FxProgressBar extends StatelessWidget {
  /// Creates an FxDesktop progress bar.
  const FxProgressBar({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.enabled = true,
  });

  /// Current progress value.
  final double value;

  /// Minimum progress value.
  final double min;

  /// Maximum progress value.
  final double max;

  /// Whether the progress bar uses its normal enabled appearance.
  final bool enabled;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxProgressBar',
      'xojo_desktop_class': 'DesktopProgressBar',
      'value': value,
      'min': min,
      'max': max,
      'normalizedValue': _normalizedValue,
      'enabled': enabled,
    };
  }

  double get _normalizedValue {
    if (!value.isFinite || !min.isFinite || !max.isFinite || min >= max) {
      return 0;
    }
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final fxTheme = FxTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = enabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.22);
    final trackColor = enabled
        ? colorScheme.surfaceContainerHighest
        : colorScheme.onSurface.withValues(alpha: 0.08);

    return Semantics(
      enabled: enabled,
      value: '${(_normalizedValue * 100).round()}%',
      child: SizedBox(
        height: 14,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(fxTheme.borderRadius),
          child: LinearProgressIndicator(
            value: _normalizedValue,
            backgroundColor: trackColor,
            color: fillColor,
          ),
        ),
      ),
    );
  }
}

/// An indeterminate progress indicator comparable to Xojo's DesktopProgressWheel.
class FxProgressWheel extends StatelessWidget {
  /// Creates an FxDesktop progress wheel.
  const FxProgressWheel({
    super.key,
    this.enabled = true,
    this.size = 24,
    this.strokeWidth = 3,
  }) : assert(size > 0),
       assert(strokeWidth > 0);

  /// Whether the wheel uses its normal enabled appearance.
  final bool enabled;

  /// Square size of the wheel in logical pixels.
  final double size;

  /// Stroke width for the circular indicator.
  final double strokeWidth;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxProgressWheel',
      'xojo_desktop_class': 'DesktopProgressWheel',
      'enabled': enabled,
      'size': size,
      'strokeWidth': strokeWidth,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicator = SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: enabled
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.22),
      ),
    );

    return Semantics(
      enabled: enabled,
      child: enabled ? indicator : Opacity(opacity: 0.5, child: indicator),
    );
  }
}

/// A horizontal or vertical rule comparable to Xojo's DesktopSeparator.
class FxSeparator extends StatelessWidget {
  /// Creates an FxDesktop separator.
  const FxSeparator({
    super.key,
    this.orientation = FxSeparatorOrientation.horizontal,
    this.thickness = 1,
    this.color,
  }) : assert(thickness >= 0);

  /// Whether the separator is horizontal or vertical.
  final FxSeparatorOrientation orientation;

  /// Painted separator thickness in logical pixels.
  final double thickness;

  /// Optional separator color. Defaults to the FxDesktop grid line color.
  final Color? color;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxSeparator',
      'xojo_desktop_class': 'DesktopSeparator',
      'orientation': orientation.name,
      'thickness': thickness,
      'color': _colorToTemplateValue(color),
    };
  }

  @override
  Widget build(BuildContext context) {
    final separatorColor = color ?? FxTheme.of(context).gridLineColor;

    return Semantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = switch (orientation) {
            FxSeparatorOrientation.horizontal => Size(
              constraints.hasBoundedWidth ? constraints.maxWidth : 0,
              thickness,
            ),
            FxSeparatorOrientation.vertical => Size(
              thickness,
              constraints.hasBoundedHeight ? constraints.maxHeight : 0,
            ),
          };

          return DecoratedBox(
            decoration: BoxDecoration(color: separatorColor),
            child: SizedBox.fromSize(size: size),
          );
        },
      ),
    );
  }
}

class _FxColorSwatch extends StatelessWidget {
  const _FxColorSwatch({required this.color, required this.enabled});

  final Color? color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = enabled
        ? colorScheme.outline
        : colorScheme.onSurface.withValues(alpha: 0.22);
    final fillColor = color ?? Colors.transparent;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(3),
      ),
      child: SizedBox.square(
        dimension: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? fillColor : fillColor.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(2),
          ),
          child: color == null
              ? Icon(Icons.close, size: 12, color: borderColor)
              : null,
        ),
      ),
    );
  }
}

class _FxPaletteButton extends StatelessWidget {
  const _FxPaletteButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: _formatColor(color),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const SizedBox.square(dimension: 28),
          ),
        ),
      ),
    );
  }
}

const _defaultPalette = <Color>[
  Color(0xff000000),
  Color(0xff4b5563),
  Color(0xffffffff),
  Color(0xffef4444),
  Color(0xfff97316),
  Color(0xffeab308),
  Color(0xff22c55e),
  Color(0xff06b6d4),
  Color(0xff3b82f6),
  Color(0xff8b5cf6),
  Color(0xffec4899),
  Color(0xffa855f7),
];

String _formatColor(Color? color) {
  if (color == null) {
    return 'No color';
  }

  final argb = color.toARGB32();
  final alpha = (argb >> 24) & 0xff;
  final red = (argb >> 16) & 0xff;
  final green = (argb >> 8) & 0xff;
  final blue = argb & 0xff;
  final rgb = [red, green, blue]
      .map((channel) => channel.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();

  if (alpha == 0xff) {
    return '#$rgb';
  }

  return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

String? _colorToTemplateValue(Color? color) {
  if (color == null) {
    return null;
  }

  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
