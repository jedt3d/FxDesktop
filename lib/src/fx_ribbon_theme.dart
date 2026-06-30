import 'package:flutter/material.dart';

/// Ribbon visual density.
enum FxRibbonDensity {
  /// Dense desktop toolbar.
  compact,

  /// Default desktop/web toolbar.
  regular,

  /// Larger toolbar suited to touch screens and relaxed layouts.
  comfortable;

  /// Large icon size.
  double get largeIconSize => switch (this) {
    FxRibbonDensity.compact => 28,
    FxRibbonDensity.regular => 32,
    FxRibbonDensity.comfortable => 36,
  };

  /// Small icon size.
  double get smallIconSize => switch (this) {
    FxRibbonDensity.compact => 14,
    FxRibbonDensity.regular => 16,
    FxRibbonDensity.comfortable => 18,
  };

  /// Minimum interactive target height.
  double get minTargetHeight => switch (this) {
    FxRibbonDensity.compact => 22,
    FxRibbonDensity.regular => 24,
    FxRibbonDensity.comfortable => 36,
  };

  /// Full ribbon height.
  double get expandedHeight => switch (this) {
    FxRibbonDensity.compact => 108,
    FxRibbonDensity.regular => 118,
    FxRibbonDensity.comfortable => 240,
  };

  /// Collapsed ribbon height.
  double get collapsedHeight => switch (this) {
    FxRibbonDensity.compact => 24,
    FxRibbonDensity.regular => 25,
    FxRibbonDensity.comfortable => 44,
  };
}

/// Pointer interaction mode.
enum FxRibbonInteractionMode {
  /// Adapt to the most recent pointer kind.
  auto,

  /// Compact mouse-first interaction.
  mouse,

  /// Larger touch targets.
  touch,
}

/// Theme extension for FxRibbonToolbar and FxRibbonDesigner.
class FxRibbonThemeData extends ThemeExtension<FxRibbonThemeData> {
  /// Creates ribbon theme data.
  const FxRibbonThemeData({
    this.density = FxRibbonDensity.regular,
    this.borderRadius = 2,
    this.backgroundColor,
    this.tabStripColor,
    this.activeTabColor,
    this.groupBackgroundColor,
    this.hoverColor,
    this.pressedColor,
    this.keyTipBackgroundColor,
    this.keyTipForegroundColor,
  });

  /// Default density.
  final FxRibbonDensity density;

  /// Ribbon control radius.
  final double borderRadius;

  /// Optional toolbar background.
  final Color? backgroundColor;

  /// Optional tab strip background.
  final Color? tabStripColor;

  /// Optional selected tab color.
  final Color? activeTabColor;

  /// Optional group background.
  final Color? groupBackgroundColor;

  /// Optional hover state color.
  final Color? hoverColor;

  /// Optional pressed/selected state color.
  final Color? pressedColor;

  /// Optional keytip badge background.
  final Color? keyTipBackgroundColor;

  /// Optional keytip badge foreground.
  final Color? keyTipForegroundColor;

  /// Resolves ribbon theme data from [context].
  static FxRibbonThemeData of(BuildContext context) {
    return Theme.of(context).extension<FxRibbonThemeData>() ??
        const FxRibbonThemeData();
  }

  /// Background color resolved against [scheme].
  Color resolvedBackground(ColorScheme scheme) =>
      backgroundColor ?? scheme.surface;

  /// Tab-strip color resolved against [scheme].
  Color resolvedTabStrip(ColorScheme scheme) =>
      tabStripColor ?? scheme.surfaceContainerHighest;

  /// Active tab color resolved against [scheme].
  Color resolvedActiveTab(ColorScheme scheme) =>
      activeTabColor ?? scheme.surface;

  /// Group color resolved against [scheme].
  Color resolvedGroupBackground(ColorScheme scheme) =>
      groupBackgroundColor ?? scheme.surfaceContainerLow;

  /// Hover color resolved against [scheme].
  Color resolvedHover(ColorScheme scheme) =>
      hoverColor ?? scheme.primary.withValues(alpha: 0.08);

  /// Pressed color resolved against [scheme].
  Color resolvedPressed(ColorScheme scheme) =>
      pressedColor ?? scheme.primary.withValues(alpha: 0.14);

  /// Keytip background resolved against [scheme].
  Color resolvedKeyTipBackground(ColorScheme scheme) =>
      keyTipBackgroundColor ?? scheme.inverseSurface;

  /// Keytip foreground resolved against [scheme].
  Color resolvedKeyTipForeground(ColorScheme scheme) =>
      keyTipForegroundColor ?? scheme.onInverseSurface;

  @override
  FxRibbonThemeData copyWith({
    FxRibbonDensity? density,
    double? borderRadius,
    Color? backgroundColor,
    Color? tabStripColor,
    Color? activeTabColor,
    Color? groupBackgroundColor,
    Color? hoverColor,
    Color? pressedColor,
    Color? keyTipBackgroundColor,
    Color? keyTipForegroundColor,
  }) {
    return FxRibbonThemeData(
      density: density ?? this.density,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      tabStripColor: tabStripColor ?? this.tabStripColor,
      activeTabColor: activeTabColor ?? this.activeTabColor,
      groupBackgroundColor: groupBackgroundColor ?? this.groupBackgroundColor,
      hoverColor: hoverColor ?? this.hoverColor,
      pressedColor: pressedColor ?? this.pressedColor,
      keyTipBackgroundColor:
          keyTipBackgroundColor ?? this.keyTipBackgroundColor,
      keyTipForegroundColor:
          keyTipForegroundColor ?? this.keyTipForegroundColor,
    );
  }

  @override
  FxRibbonThemeData lerp(ThemeExtension<FxRibbonThemeData>? other, double t) {
    if (other is! FxRibbonThemeData) {
      return this;
    }
    return FxRibbonThemeData(
      density: t < 0.5 ? density : other.density,
      borderRadius: _lerpDouble(borderRadius, other.borderRadius, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      tabStripColor: Color.lerp(tabStripColor, other.tabStripColor, t),
      activeTabColor: Color.lerp(activeTabColor, other.activeTabColor, t),
      groupBackgroundColor: Color.lerp(
        groupBackgroundColor,
        other.groupBackgroundColor,
        t,
      ),
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t),
      pressedColor: Color.lerp(pressedColor, other.pressedColor, t),
      keyTipBackgroundColor: Color.lerp(
        keyTipBackgroundColor,
        other.keyTipBackgroundColor,
        t,
      ),
      keyTipForegroundColor: Color.lerp(
        keyTipForegroundColor,
        other.keyTipForegroundColor,
        t,
      ),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
