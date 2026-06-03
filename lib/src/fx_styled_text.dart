import 'package:flutter/material.dart';

/// A single styled run in an [FxStyledLabel].
class FxStyledTextSpan {
  /// Creates an immutable styled text run.
  const FxStyledTextSpan({required this.text, this.style});

  /// Text rendered by this run.
  final String text;

  /// Optional style for this run, merged by Flutter with the label style.
  final TextStyle? style;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'text': text,
      if (style != null) 'style': _textStyleToTemplateMap(style!),
    };
  }
}

/// A styled text label comparable to a Xojo styled text label pattern.
///
/// [text] is the plain fallback used for metadata and accessibility. When
/// [spans] is empty it is also the rendered text; otherwise each styled run in
/// [spans] is rendered in order.
class FxStyledLabel extends StatelessWidget {
  /// Creates an FxDesktop styled label.
  const FxStyledLabel({
    super.key,
    required this.text,
    this.spans = const [],
    this.enabled = true,
    this.softWrap = true,
    this.alignment = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.style,
  });

  /// Plain fallback label text.
  final String text;

  /// Styled text runs rendered when provided.
  final List<FxStyledTextSpan> spans;

  /// Whether the label uses the normal enabled appearance.
  final bool enabled;

  /// Whether long label text wraps onto multiple lines.
  final bool softWrap;

  /// Horizontal text alignment.
  final TextAlign alignment;

  /// Maximum number of rendered lines, or unlimited when null.
  final int? maxLines;

  /// How overflowing text is handled.
  final TextOverflow overflow;

  /// Optional base text style applied before per-span styles.
  final TextStyle? style;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxStyledLabel',
      'xojo_desktop_class': 'DesktopLabel',
      'text': text,
      'spanCount': spans.length,
      'spans': [for (final span in spans) span.toTemplateMap()],
      'enabled': enabled,
      'softWrap': softWrap,
      'alignment': alignment.name,
      'maxLines': maxLines,
      'overflow': overflow.name,
      if (style != null) 'style': _textStyleToTemplateMap(style!),
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = Text.rich(
      TextSpan(
        text: spans.isEmpty ? text : null,
        style: style,
        children: spans.isEmpty
            ? null
            : [
                for (final span in spans)
                  TextSpan(text: span.text, style: span.style),
              ],
      ),
      textAlign: alignment,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: text,
    );

    if (enabled) {
      return label;
    }

    return Opacity(opacity: 0.38, child: label);
  }
}

Map<String, Object?> _textStyleToTemplateMap(TextStyle style) {
  return {
    if (style.fontWeight != null) 'fontWeight': style.fontWeight.toString(),
    if (style.fontStyle != null) 'fontStyle': style.fontStyle!.name,
    if (style.fontSize != null) 'fontSize': style.fontSize,
    if (style.color != null) 'color': _colorToTemplateValue(style.color!),
    if (style.decoration != null) 'decoration': style.decoration.toString(),
  };
}

String _colorToTemplateValue(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
}
