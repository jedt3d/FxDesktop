import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pumps [theme] and returns the resolved [ThemeData] seen by a descendant.
///
/// Building the theme resolves fonts through google_fonts, which schedules
/// async loads. Pumping inside the widget lifecycle (rather than
/// `tester.runAsync`) lets those futures settle in the test's fake-async zone,
/// where google_fonts swallows the "font not bundled" error internally.
Future<ThemeData> _resolveTheme(WidgetTester tester, ThemeData theme) async {
  late ThemeData resolved;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          resolved = Theme.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return resolved;
}

void main() {
  // The theme resolves fonts through google_fonts. Keep tests deterministic and
  // offline: never fetch at runtime (falls back to the ambient test font).
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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
    testWidgets('desktop is Material 3 with compact density', (tester) async {
      final theme = await _resolveTheme(tester, FxThemeData.light());
      expect(theme.useMaterial3, isTrue);
      expect(theme.visualDensity, VisualDensity.compact);
      expect(theme.colorScheme.primary, const Color(0xFF2563EB));
    });

    testWidgets('comfortable relaxes density for touch', (tester) async {
      final theme = await _resolveTheme(
        tester,
        FxThemeData.light(profile: FxDensityProfile.comfortable),
      );
      expect(theme.visualDensity, VisualDensity.comfortable);
      expect(
        theme.extension<FxRibbonThemeData>()!.density,
        FxRibbonDensity.comfortable,
      );
    });

    testWidgets('registers FxTheme and FxRibbonThemeData extensions', (
      tester,
    ) async {
      final theme = await _resolveTheme(tester, FxThemeData.dark());
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
}
