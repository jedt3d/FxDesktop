import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fx_ribbon_theme.dart';
import 'fx_theme.dart';

/// Selects which FxDesktop metric layer a generated [ThemeData] targets.
///
/// FxDesktop DS is Material 3 with two sibling metric layers on a shared
/// foundation (color roles, type scale, elevation, state layers). The profile
/// picks one without touching the foundation:
///
/// * [desktop] — mouse + keyboard. [VisualDensity.compact], 28/34/42 controls,
///   2–4px radii, ribbon. The default for FxDesktop.
/// * [comfortable] — touch / mobile. [VisualDensity.comfortable], larger hit
///   targets. A pristine Material 3 touch layer.
enum FxDensityProfile {
  /// Mouse + keyboard desktop metrics ([VisualDensity.compact]).
  desktop,

  /// Touch / mobile metrics ([VisualDensity.comfortable]).
  comfortable,
}

/// Brand theme factory for the FxDesktop design system.
///
/// Produces a Material 3 [ThemeData] seeded from the FxDesktop brand color
/// (`#2563EB`) with the pinned brand color roles, the Thai-first multi-script
/// type scale, the desktop density profile, and the [FxTheme] /
/// [FxRibbonThemeData] extensions registered.
///
/// This is additive: it does not change any widget's public API. Consumers wire
/// it into a [MaterialApp]:
///
/// ```dart
/// MaterialApp(
///   theme: FxThemeData.light(),
///   darkTheme: FxThemeData.dark(),
/// );
/// ```
///
/// Dark is the **GitHub-style** low-contrast palette (used verbatim), not
/// `ColorScheme.fromSeed(brightness: dark)`, per `references/crosswalk.md`.
abstract final class FxThemeData {
  /// The FxDesktop brand seed color (`#2563EB`).
  static const Color seedColor = Color(0xFF2563EB);

  /// Semantic success color (light / dark).
  static const Color successLight = Color(0xFF16A34A);

  /// Semantic success color for dark surfaces.
  static const Color successDark = Color(0xFF3FB950);

  /// Semantic warning color (light).
  static const Color warningLight = Color(0xFFB45309);

  /// Semantic warning color for dark surfaces.
  static const Color warningDark = Color(0xFFD29922);

  /// Light color scheme: `fromSeed(#2563EB)` with the brand roles pinned to the
  /// crosswalk values.
  static final ColorScheme lightColorScheme =
      ColorScheme.fromSeed(seedColor: seedColor).copyWith(
        primary: const Color(0xFF2563EB),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFDBEAFE),
        surface: const Color(0xFFFBFCFD),
        onSurface: const Color(0xFF1A1C1E),
        onSurfaceVariant: const Color(0xFF43474E),
        surfaceContainer: const Color(0xFFEEF0F2),
        outline: const Color(0xFF9AA2AD),
        outlineVariant: const Color(0xFFD1D5DB),
        error: const Color(0xFFDC2626),
      );

  /// Dark color scheme: the **GitHub-style** low-contrast palette, verbatim.
  static final ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF388BFD),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFF1F2F4D),
        surface: const Color(0xFF0D1117),
        onSurface: const Color(0xFFC9D1D9),
        onSurfaceVariant: const Color(0xFF8B949E),
        surfaceContainer: const Color(0xFF161B22),
        outline: const Color(0xFF484F58),
        outlineVariant: const Color(0xFF30363D),
        error: const Color(0xFFF85149),
      );

  /// Per-script fallback chain applied to every text role, so Thai renders from
  /// the primary face and JP / Devanagari / Arabic / Tamil each resolve through
  /// their Noto face. Latin (Vietnamese-capable) leads the chain.
  static final List<String> _scriptFallback = <String>[
    GoogleFonts.notoSans().fontFamily!,
    GoogleFonts.notoSansJp().fontFamily!,
    GoogleFonts.notoSansDevanagari().fontFamily!,
    GoogleFonts.notoSansArabic().fontFamily!,
    GoogleFonts.notoSansTamil().fontFamily!,
  ];

  /// UI / header / display type: **Noto Sans Thai** (headless) with the
  /// per-script fallback. Keeps each role's Material 3 size and line-height.
  ///
  /// Use for chrome, labels, buttons, tabs, table headers, and the ribbon.
  static TextTheme uiTextTheme(TextTheme base) => GoogleFonts.notoSansThaiTextTheme(
    base,
  ).apply(fontFamilyFallback: _scriptFallback);

  /// Reading / paragraph type: **Noto Sans Thai Looped** (head) with the
  /// per-script fallback and a ~+25% line-height on body roles, so Thai tone
  /// marks never collide with the descenders of the line above.
  ///
  /// Use for long-form text and read (non-edited) cell text.
  static TextTheme readingTextTheme(TextTheme base) {
    final looped = GoogleFonts.notoSansThaiLoopedTextTheme(
      base,
    ).apply(fontFamilyFallback: _scriptFallback);
    TextStyle? bump(TextStyle? style) =>
        style?.copyWith(height: (style.height ?? 1.4) * 1.25);
    return looped.copyWith(
      bodyLarge: bump(looped.bodyLarge),
      bodyMedium: bump(looped.bodyMedium),
      bodySmall: bump(looped.bodySmall),
    );
  }

  /// Monospace type for data / numbers / code: **Roboto Mono**. Never used for
  /// complex-script body (mono has no Thai/Arabic/Tamil shaping).
  static TextStyle monoTextStyle([TextStyle? base]) =>
      GoogleFonts.robotoMono(textStyle: base);

  /// The FxDesktop light theme.
  ///
  /// Set [useBrandFonts] to `false` to skip the google_fonts text theme and
  /// keep the ambient font — useful in tests / offline builds that cannot load
  /// web fonts, or for consumers that bundle their own. Color roles, density,
  /// shape, and extensions are unchanged either way.
  static ThemeData light({
    FxDensityProfile profile = FxDensityProfile.desktop,
    bool useBrandFonts = true,
  }) => _build(Brightness.light, profile, useBrandFonts);

  /// The FxDesktop dark theme (GitHub-style palette).
  ///
  /// See [light] for [useBrandFonts].
  static ThemeData dark({
    FxDensityProfile profile = FxDensityProfile.desktop,
    bool useBrandFonts = true,
  }) => _build(Brightness.dark, profile, useBrandFonts);

  static ThemeData _build(
    Brightness brightness,
    FxDensityProfile profile,
    bool useBrandFonts,
  ) {
    final scheme = brightness == Brightness.light
        ? lightColorScheme
        : darkColorScheme;
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final isDesktop = profile == FxDensityProfile.desktop;

    // Desktop uses the 4px control radius (comfortable relaxes to 8px). This
    // overrides Material 3's default StadiumBorder pills, which the desktop
    // profile forbids ("2–4px radii, no fully-rounded pills on desktop").
    final controlRadius = isDesktop ? 4.0 : 8.0;
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    final buttonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
    );

    return base.copyWith(
      visualDensity: isDesktop
          ? VisualDensity.compact
          : VisualDensity.comfortable,
      textTheme: useBrandFonts ? uiTextTheme(base.textTheme) : base.textTheme,
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
      textButtonTheme: TextButtonThemeData(style: buttonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
      extensions: <ThemeExtension<dynamic>>[
        _fxTheme(scheme, isDesktop, brightness),
        FxRibbonThemeData(
          density: isDesktop
              ? FxRibbonDensity.regular
              : FxRibbonDensity.comfortable,
        ),
      ],
    );
  }

  /// Builds the [FxTheme] table/grid tokens for the given [brightness].
  ///
  /// Light keeps the crosswalk defaults (which match the light scheme); dark
  /// derives the grid tokens from the GitHub palette so tables stay legible.
  static FxTheme _fxTheme(
    ColorScheme scheme,
    bool isDesktop,
    Brightness brightness,
  ) {
    final controlSize = isDesktop ? FxControlSize.regular : FxControlSize.large;
    if (brightness == Brightness.light) {
      return FxTheme(controlSize: controlSize);
    }
    return FxTheme(
      controlSize: controlSize,
      gridLineColor: scheme.outlineVariant,
      headerBackground: scheme.surfaceContainer,
      alternatingRowBackground: scheme.surfaceContainerHigh,
      selectionBackground: scheme.primaryContainer,
    );
  }
}
