import 'package:flutter/material.dart';

/// Standard desktop control densities used by FxDesktop components.
enum FxControlSize {
  /// Dense control metrics for toolbars and inspectors.
  compact(28),

  /// Default desktop form control metrics.
  regular(34),

  /// Larger metrics for prominent commands or relaxed forms.
  large(42);

  /// Default control height in logical pixels.
  final double height;

  const FxControlSize(this.height);
}

/// Desktop-oriented theme extension for FxDesktop widgets.
class FxTheme extends ThemeExtension<FxTheme> {
  /// Creates a theme extension for FxDesktop widgets.
  const FxTheme({
    this.controlSize = FxControlSize.regular,
    this.borderRadius = 4,
    this.controlPadding = const EdgeInsets.symmetric(horizontal: 10),
    this.gridLineColor = const Color(0xffd1d5db),
    this.headerBackground = const Color(0xfff3f4f6),
    this.alternatingRowBackground = const Color(0xfff9fafb),
    this.selectionBackground = const Color(0xffdbeafe),
  });

  /// Default density for controls.
  final FxControlSize controlSize;

  /// Default border radius for framed desktop controls.
  final double borderRadius;

  /// Default horizontal/vertical content padding for controls.
  final EdgeInsetsGeometry controlPadding;

  /// Grid and table separator color.
  final Color gridLineColor;

  /// Header background used by list and grid controls.
  final Color headerBackground;

  /// Alternating row background used by table-like controls.
  final Color alternatingRowBackground;

  /// Selection background used by table-like controls.
  final Color selectionBackground;

  /// Resolves the FxDesktop theme from [context] or returns defaults.
  static FxTheme of(BuildContext context) {
    return Theme.of(context).extension<FxTheme>() ?? const FxTheme();
  }

  @override
  FxTheme copyWith({
    FxControlSize? controlSize,
    double? borderRadius,
    EdgeInsetsGeometry? controlPadding,
    Color? gridLineColor,
    Color? headerBackground,
    Color? alternatingRowBackground,
    Color? selectionBackground,
  }) {
    return FxTheme(
      controlSize: controlSize ?? this.controlSize,
      borderRadius: borderRadius ?? this.borderRadius,
      controlPadding: controlPadding ?? this.controlPadding,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      headerBackground: headerBackground ?? this.headerBackground,
      alternatingRowBackground:
          alternatingRowBackground ?? this.alternatingRowBackground,
      selectionBackground: selectionBackground ?? this.selectionBackground,
    );
  }

  @override
  FxTheme lerp(ThemeExtension<FxTheme>? other, double t) {
    if (other is! FxTheme) {
      return this;
    }
    return FxTheme(
      controlSize: t < 0.5 ? controlSize : other.controlSize,
      borderRadius: _lerpDouble(borderRadius, other.borderRadius, t),
      controlPadding: EdgeInsetsGeometry.lerp(
        controlPadding,
        other.controlPadding,
        t,
      )!,
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      headerBackground: Color.lerp(
        headerBackground,
        other.headerBackground,
        t,
      )!,
      alternatingRowBackground: Color.lerp(
        alternatingRowBackground,
        other.alternatingRowBackground,
        t,
      )!,
      selectionBackground: Color.lerp(
        selectionBackground,
        other.selectionBackground,
        t,
      )!,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
