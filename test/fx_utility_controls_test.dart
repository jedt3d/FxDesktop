import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/src/fx_utility_controls.dart';

void main() {
  group('FxColorPicker', () {
    testWidgets('renders color swatch and value text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxColorPicker(label: 'Accent', value: Color(0xff336699)),
          ),
        ),
      );

      expect(find.text('Accent: #336699'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders no color state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FxColorPicker(label: 'Optional')),
        ),
      );

      expect(find.text('Optional: No color'), findsOneWidget);
    });

    testWidgets('uses injected picker and reports selected color', (
      tester,
    ) async {
      Color? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xff111111),
              onChanged: (value) => changedValue = value,
              picker: (context, selectedColor) async {
                expect(selectedColor, const Color(0xff111111));
                return const Color(0xff22cc88);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(changedValue, const Color(0xff22cc88));
    });

    testWidgets('uses injected picker and reports no color', (tester) async {
      Color? changedValue = const Color(0xff111111);
      var committed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xff111111),
              onChanged: (value) => changedValue = value,
              onCommit: (value) {
                committed = true;
                expect(value, isNull);
              },
              picker: (context, selectedColor) async {
                expect(selectedColor, const Color(0xff111111));
                return null;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(changedValue, isNull);
      expect(committed, isTrue);
    });

    testWidgets('default picker can explicitly select no color', (
      tester,
    ) async {
      Color? changedValue = const Color(0xff111111);
      var committed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xff111111),
              onChanged: (value) => changedValue = value,
              onCommit: (value) {
                committed = true;
                expect(value, isNull);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No Color'));
      await tester.pumpAndSettle();

      expect(changedValue, isNull);
      expect(committed, isTrue);
    });

    testWidgets('default picker applies RGB hex input', (tester) async {
      Color? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xff111111),
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '#336699');
      await tester.pumpAndSettle();

      expect(find.text('Preview: #336699'), findsOneWidget);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(changedValue, const Color(0xff336699));
    });

    testWidgets('default picker rejects invalid RGB hex input', (tester) async {
      Color? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xff111111),
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '#GGGGGG');
      await tester.pumpAndSettle();

      expect(find.text('Enter a color as #RRGGBB.'), findsOneWidget);

      final applyButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Apply'),
      );
      expect(applyButton.onPressed, isNull);
      expect(changedValue, isNull);
    });

    testWidgets('default picker applies HSV slider changes', (tester) async {
      Color? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Fill',
              value: const Color(0xffff0000),
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      tester.widget<Slider>(find.byType(Slider).first).onChanged?.call(180);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(changedValue, isNotNull);
      expect(changedValue, isNot(const Color(0xffff0000)));
    });

    testWidgets('ignores taps when disabled', (tester) async {
      Color? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Disabled',
              value: const Color(0xff111111),
              enabled: false,
              onChanged: (value) => changedValue = value,
              picker: (context, selectedColor) async {
                return const Color(0xff22cc88);
              },
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(changedValue, isNull);
    });

    test('exposes DesktopColorPicker template metadata', () {
      expect(
        const FxColorPicker(
          label: 'Accent',
          value: Color(0xff336699),
          enabled: false,
        ).toTemplateMap(),
        {
          'component': 'FxColorPicker',
          'xojo_desktop_class': 'DesktopColorPicker',
          'label': 'Accent',
          'value': '#FF336699',
          'enabled': false,
        },
      );
    });
  });

  group('FxProgressBar', () {
    testWidgets('renders normalized determinate progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FxProgressBar(value: 40, min: 20, max: 60)),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('clamps out-of-range and invalid values safely', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FxProgressBar(value: 150),
                FxProgressBar(value: -50),
                FxProgressBar(value: 10, min: 10, max: 10),
              ],
            ),
          ),
        ),
      );

      final indicators = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicators.elementAt(0).value, 1);
      expect(indicators.elementAt(1).value, 0);
      expect(indicators.elementAt(2).value, 0);
    });

    test('exposes DesktopProgressBar template metadata', () {
      expect(
        const FxProgressBar(
          value: 75,
          min: 50,
          max: 100,
          enabled: false,
        ).toTemplateMap(),
        {
          'component': 'FxProgressBar',
          'xojo_desktop_class': 'DesktopProgressBar',
          'value': 75.0,
          'min': 50.0,
          'max': 100.0,
          'normalizedValue': 0.5,
          'enabled': false,
        },
      );
    });
  });

  group('FxProgressWheel', () {
    testWidgets('renders indeterminate wheel with requested size', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FxProgressWheel(size: 32, strokeWidth: 4)),
        ),
      );

      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(box.width, 32);
      expect(box.height, 32);
      expect(indicator.value, isNull);
      expect(indicator.strokeWidth, 4);
    });

    testWidgets('dims disabled wheel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FxProgressWheel(enabled: false)),
        ),
      );

      expect(find.byType(Opacity), findsOneWidget);
    });

    test('exposes DesktopProgressWheel template metadata', () {
      expect(
        const FxProgressWheel(
          enabled: false,
          size: 32,
          strokeWidth: 4,
        ).toTemplateMap(),
        {
          'component': 'FxProgressWheel',
          'xojo_desktop_class': 'DesktopProgressWheel',
          'enabled': false,
          'size': 32.0,
          'strokeWidth': 4.0,
        },
      );
    });
  });

  group('FxSeparator', () {
    testWidgets('renders horizontal and vertical rules', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                FxSeparator(thickness: 2, color: Color(0xff123456)),
                FxSeparator(
                  orientation: FxSeparatorOrientation.vertical,
                  thickness: 3,
                ),
              ],
            ),
          ),
        ),
      );

      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(boxes.elementAt(0).height, 2);
      expect(boxes.elementAt(1).width, 3);
    });

    test('exposes DesktopSeparator template metadata', () {
      expect(
        const FxSeparator(
          orientation: FxSeparatorOrientation.vertical,
          thickness: 2,
          color: Color(0xff123456),
        ).toTemplateMap(),
        {
          'component': 'FxSeparator',
          'xojo_desktop_class': 'DesktopSeparator',
          'orientation': 'vertical',
          'thickness': 2.0,
          'color': '#FF123456',
        },
      );
    });
  });
}
