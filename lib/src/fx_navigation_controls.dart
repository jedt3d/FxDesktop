import 'package:flutter/material.dart';

import 'fx_theme.dart';

/// A single option in an [FxSegmentedButton].
class FxSegmentedOption<T> {
  /// Creates a segmented button option.
  const FxSegmentedOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// Value selected when this segment is chosen.
  final T value;

  /// Visible segment label.
  final String label;

  /// Optional leading icon shown before [label].
  final Widget? icon;

  /// Whether this option is selectable when its segmented button is enabled.
  final bool enabled;
}

/// A single-selection mode selector comparable to Xojo's DesktopSegmentedButton.
class FxSegmentedButton<T> extends StatelessWidget {
  /// Creates an FxDesktop segmented button.
  const FxSegmentedButton({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  /// Segments displayed by the control.
  final List<FxSegmentedOption<T>> options;

  /// Currently selected option value.
  final T value;

  /// Called when the selected segment changes.
  final ValueChanged<T>? onChanged;

  /// Whether the segmented button and selectable options are enabled.
  final bool enabled;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxSegmentedButton',
      'xojo_desktop_class': 'DesktopSegmentedButton',
      'selectedValue': value,
      'optionCount': options.length,
      'enabled': enabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fxTheme = FxTheme.of(context);
    final isGroupEnabled = enabled && onChanged != null;

    return SegmentedButton<T>(
      segments: [
        for (final option in options)
          ButtonSegment<T>(
            value: option.value,
            label: Text(option.label),
            icon: option.icon,
            enabled: isGroupEnabled && option.enabled,
          ),
      ],
      selected: {value},
      showSelectedIcon: false,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(0, fxTheme.controlSize.height),
        ),
        padding: WidgetStatePropertyAll(fxTheme.controlPadding),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      onSelectionChanged: isGroupEnabled
          ? (values) {
              if (values.isNotEmpty) {
                onChanged?.call(values.single);
              }
            }
          : null,
    );
  }
}

/// A compact collapsible section control comparable to Xojo's disclosure UI.
class FxDisclosureTriangle extends StatelessWidget {
  /// Creates an FxDesktop disclosure triangle.
  const FxDisclosureTriangle({
    super.key,
    required this.expanded,
    required this.title,
    required this.child,
    this.onChanged,
    this.enabled = true,
  });

  /// Whether the disclosure content is visible.
  final bool expanded;

  /// Visible title shown next to the disclosure triangle.
  final String title;

  /// Content shown when [expanded] is true.
  final Widget child;

  /// Called when the disclosure header requests a new expanded state.
  final ValueChanged<bool>? onChanged;

  /// Whether the disclosure header can be toggled.
  final bool enabled;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxDisclosureTriangle',
      'xojo_desktop_class': 'DesktopDisclosureTriangle',
      'expanded': expanded,
      'enabled': enabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    final header = InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: interactive ? () => onChanged?.call(!expanded) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 18,
              color: foregroundColor,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: textStyle?.copyWith(color: foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: interactive,
      toggled: expanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          if (expanded)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20, top: 4),
              child: child,
            ),
        ],
      ),
    );
  }
}
