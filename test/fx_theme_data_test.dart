import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxThemeData color roles', () {
    test('light pins the brand color roles', () {
      final scheme = FxThemeData.lightColorScheme;
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, const Color(0xFF2563EB));
      expect(scheme.surface, const Color(0xFFFBFCFD));
      expect(scheme.onSurfaceVariant, const Color(0xFF43474E));
      expect(scheme.outlineVariant, const Color(0xFFD1D5DB));
      expect(scheme.error, const Color(0xFFDC2626));
    });

    test('dark uses the GitHub-style palette verbatim', () {
      final scheme = FxThemeData.darkColorScheme;
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, const Color(0xFF388BFD));
      expect(scheme.surface, const Color(0xFF0D1117));
      expect(scheme.onSurface, const Color(0xFFC9D1D9));
      expect(scheme.outlineVariant, const Color(0xFF30363D));
    });
  });

  group('FxThemeData profiles', () {
    test('desktop is Material 3 with compact density', () {
      final theme = FxThemeData.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.visualDensity, VisualDensity.compact);
      expect(theme.colorScheme.primary, const Color(0xFF2563EB));
    });

    test('comfortable relaxes density for touch', () {
      final theme = FxThemeData.light(profile: FxDensityProfile.comfortable);
      expect(theme.visualDensity, VisualDensity.comfortable);
      expect(
        theme.extension<FxRibbonThemeData>()!.density,
        FxRibbonDensity.comfortable,
      );
    });

    test('registers FxTheme and FxRibbonThemeData extensions', () {
      final theme = FxThemeData.dark();
      final fxTheme = theme.extension<FxTheme>();
      final ribbon = theme.extension<FxRibbonThemeData>();
      expect(fxTheme, isNotNull);
      expect(ribbon, isNotNull);
      // Crosswalk density/shape values are preserved.
      expect(fxTheme!.borderRadius, 4);
      expect(ribbon!.borderRadius, 2);
      // Dark tables derive grid tokens from the dark palette.
      expect(fxTheme.gridLineColor, const Color(0xFF30363D));
    });
  });

  group('FxThemeData typography', () {
    const base = Typography.blackMountainView;

    test('UI theme uses the bundled headless Thai face', () {
      final ui = FxThemeData.uiTextTheme(base);
      expect(ui.bodyMedium!.fontFamily, 'Noto Sans Thai');
      expect(ui.bodyMedium!.fontFamilyFallback, contains('Noto Sans'));
    });

    test('reading theme uses the looped face with extra line-height', () {
      final ui = FxThemeData.uiTextTheme(base);
      final reading = FxThemeData.readingTextTheme(base);
      expect(reading.bodyMedium!.fontFamily, 'Noto Sans Thai Looped');
      expect(
        reading.bodyMedium!.height ?? 1.0,
        greaterThan(ui.bodyMedium!.height ?? 1.0),
      );
    });

    test('mono style uses the bundled monospace face', () {
      expect(FxThemeData.monoTextStyle().fontFamily, 'Noto Sans Mono');
    });

    test('useBrandFonts:false keeps the ambient font', () {
      final theme = FxThemeData.light(useBrandFonts: false);
      expect(theme.textTheme.bodyMedium!.fontFamily, isNot('Noto Sans Thai'));
    });
  });
}
