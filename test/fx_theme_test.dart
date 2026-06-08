import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxTheme Tests', () {
    test('FxControlSize values and heights', () {
      expect(FxControlSize.compact.height, 28);
      expect(FxControlSize.regular.height, 34);
      expect(FxControlSize.large.height, 42);
    });

    test('FxTheme constructor defaults', () {
      const theme = FxTheme();
      expect(theme.controlSize, FxControlSize.regular);
      expect(theme.borderRadius, 4);
      expect(theme.controlPadding, const EdgeInsets.symmetric(horizontal: 10));
      expect(theme.gridLineColor, const Color(0xffd1d5db));
      expect(theme.headerBackground, const Color(0xfff3f4f6));
      expect(theme.alternatingRowBackground, const Color(0xfff9fafb));
      expect(theme.selectionBackground, const Color(0xffdbeafe));
    });

    testWidgets('FxTheme.of resolves from context or defaults', (tester) async {
      late FxTheme resolvedTheme;
      await tester.pumpWidget(
        Material(
          child: Builder(
            builder: (context) {
              resolvedTheme = FxTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      // Default fallback when not provided
      expect(resolvedTheme.controlSize, FxControlSize.regular);

      await tester.pumpWidget(
        Theme(
          data: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              FxTheme(controlSize: FxControlSize.compact),
            ],
          ),
          child: Builder(
            builder: (context) {
              resolvedTheme = FxTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      // Resolved custom extension
      expect(resolvedTheme.controlSize, FxControlSize.compact);
    });

    test('FxTheme copyWith updates only specified fields', () {
      const theme = FxTheme();
      final updated = theme.copyWith(
        controlSize: FxControlSize.large,
        borderRadius: 8.0,
      );

      expect(updated.controlSize, FxControlSize.large);
      expect(updated.borderRadius, 8.0);
      expect(updated.gridLineColor, theme.gridLineColor); // unchanged
    });

    test('FxTheme lerp interpolates correctly', () {
      const themeA = FxTheme(
        controlSize: FxControlSize.compact,
        borderRadius: 2.0,
        gridLineColor: Color(0xff000000),
      );
      const themeB = FxTheme(
        controlSize: FxControlSize.large,
        borderRadius: 6.0,
        gridLineColor: Color(0xffffffff),
      );

      // lerp with non-FxTheme or null returns this
      expect(themeA.lerp(null, 0.5), themeA);

      // lerp with t < 0.5
      final lerpUnder = themeA.lerp(themeB, 0.25);
      expect(lerpUnder.controlSize, FxControlSize.compact);
      expect(lerpUnder.borderRadius, 3.0);
      expect(
        lerpUnder.gridLineColor,
        Color.lerp(const Color(0xff000000), const Color(0xffffffff), 0.25),
      );

      // lerp with t >= 0.5
      final lerpOver = themeA.lerp(themeB, 0.75);
      expect(lerpOver.controlSize, FxControlSize.large);
      expect(lerpOver.borderRadius, 5.0);
      expect(
        lerpOver.gridLineColor,
        Color.lerp(const Color(0xff000000), const Color(0xffffffff), 0.75),
      );
    });
  });
}
