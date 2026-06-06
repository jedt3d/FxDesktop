import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxRadioButton', () {
    testWidgets('maps selected, unselected, and disabled states', (
      tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FxRadioButton<String>(
                  label: 'Selected',
                  value: 'selected',
                  groupValue: 'selected',
                  onChanged: (value) => selected = value,
                ),
                FxRadioButton<String>(
                  label: 'Unselected',
                  value: 'unselected',
                  groupValue: 'selected',
                  onChanged: (value) => selected = value,
                ),
                const FxRadioButton<String>(
                  label: 'Disabled',
                  value: 'disabled',
                  selected: false,
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );

      final tiles = tester.widgetList<RadioListTile<String>>(
        find.byType(RadioListTile<String>),
      );

      expect(tiles.elementAt(0).selected, isTrue);
      expect(tiles.elementAt(1).selected, isFalse);
      expect(tiles.elementAt(2).enabled, isFalse);

      await tester.tap(find.text('Unselected'));
      expect(selected, 'unselected');
    });
  });

  group('FxRadioGroup', () {
    testWidgets('manages exclusive option selection', (tester) async {
      String? selected = 'small';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxRadioGroup<String>(
              value: selected,
              options: const [
                FxRadioOption(value: 'small', label: 'Small'),
                FxRadioOption(value: 'large', label: 'Large'),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Large'));
      expect(selected, 'large');
    });

    testWidgets('supports horizontal orientation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxRadioGroup<String>(
              value: 'left',
              orientation: FxChoiceOrientation.horizontal,
              spacing: 12,
              options: const [
                FxRadioOption(value: 'left', label: 'Left'),
                FxRadioOption(value: 'right', label: 'Right'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 12);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('disables all options when group is disabled', (tester) async {
      String? selected = 'a';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxRadioGroup<String>(
              value: selected,
              enabled: false,
              options: const [
                FxRadioOption(value: 'a', label: 'A'),
                FxRadioOption(value: 'b', label: 'B'),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      final tiles = tester.widgetList<RadioListTile<String>>(
        find.byType(RadioListTile<String>),
      );
      expect(tiles.every((tile) => tile.enabled == false), isTrue);

      await tester.tap(find.text('B'));
      expect(selected, 'a');
    });
  });

  group('FxSlider', () {
    testWidgets('maps range, divisions, current value, and label', (
      tester,
    ) async {
      double? changed;
      double? changeStart;
      double? changeEnd;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: FxSlider(
                value: 50,
                min: 0,
                max: 100,
                divisions: 10,
                valueLabel: '50%',
                onChanged: (value) => changed = value,
                onChangeStart: (value) => changeStart = value,
                onChangeEnd: (value) => changeEnd = value,
              ),
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 50);
      expect(slider.min, 0);
      expect(slider.max, 100);
      expect(slider.divisions, 10);
      expect(slider.label, '50%');
      expect(find.text('50%'), findsOneWidget);

      slider.onChanged?.call(60);
      slider.onChangeStart?.call(50);
      slider.onChangeEnd?.call(60);
      expect(changed, 60);
      expect(changeStart, 50);
      expect(changeEnd, 60);
    });

    testWidgets('disables when requested', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: FxSlider(value: 25, enabled: false, onChanged: null),
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNull);
    });

    testWidgets('supports FxSlider.range and calls callbacks', (tester) async {
      RangeValues? changed;
      RangeValues? changeStart;
      RangeValues? changeEnd;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: FxSlider.range(
                rangeValue: const RangeValues(20, 80),
                min: 0,
                max: 100,
                divisions: 10,
                valueLabel: '20-80',
                onRangeChanged: (val) => changed = val,
                onChangeStartRange: (val) => changeStart = val,
                onChangeEndRange: (val) => changeEnd = val,
              ),
            ),
          ),
        ),
      );

      final rangeSlider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(rangeSlider.values.start, 20);
      expect(rangeSlider.values.end, 80);
      expect(rangeSlider.min, 0);
      expect(rangeSlider.max, 100);
      expect(rangeSlider.divisions, 10);
      expect(find.text('20-80'), findsOneWidget);

      rangeSlider.onChanged?.call(const RangeValues(30, 70));
      rangeSlider.onChangeStart?.call(const RangeValues(20, 80));
      rangeSlider.onChangeEnd?.call(const RangeValues(30, 70));

      expect(changed?.start, 30);
      expect(changed?.end, 70);
      expect(changeStart?.start, 20);
      expect(changeStart?.end, 80);
      expect(changeEnd?.start, 30);
      expect(changeEnd?.end, 70);
    });
  });
}
