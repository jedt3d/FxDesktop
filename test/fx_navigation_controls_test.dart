import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/src/fx_navigation_controls.dart';

void main() {
  group('FxSegmentedButton', () {
    testWidgets('renders selected and disabled states', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxSegmentedButton<String>(
              value: 'list',
              options: const [
                FxSegmentedOption(
                  value: 'list',
                  label: 'List',
                  icon: Icon(Icons.view_list),
                ),
                FxSegmentedOption(value: 'grid', label: 'Grid'),
                FxSegmentedOption(
                  value: 'hidden',
                  label: 'Hidden',
                  enabled: false,
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final segmented = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );

      expect(segmented.selected, {'list'});
      expect(segmented.segments.elementAt(0).enabled, isTrue);
      expect(segmented.segments.elementAt(2).enabled, isFalse);
      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('changes value when a segment is tapped', (tester) async {
      var changedValue = 'list';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxSegmentedButton<String>(
              value: changedValue,
              options: const [
                FxSegmentedOption(value: 'list', label: 'List'),
                FxSegmentedOption(value: 'grid', label: 'Grid'),
              ],
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Grid'));
      await tester.pump();

      expect(changedValue, 'grid');
    });

    testWidgets('ignores taps when disabled', (tester) async {
      var changedValue = 'list';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxSegmentedButton<String>(
              value: changedValue,
              enabled: false,
              options: const [
                FxSegmentedOption(value: 'list', label: 'List'),
                FxSegmentedOption(value: 'grid', label: 'Grid'),
              ],
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      final segmented = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );
      expect(segmented.onSelectionChanged, isNull);
      expect(segmented.segments.every((segment) => !segment.enabled), isTrue);

      await tester.tap(find.text('Grid'));
      await tester.pump();

      expect(changedValue, 'list');
    });

    test('exposes DesktopSegmentedButton template metadata', () {
      expect(
        const FxSegmentedButton<String>(
          value: 'cards',
          options: [
            FxSegmentedOption(value: 'tabs', label: 'Tabs'),
            FxSegmentedOption(value: 'cards', label: 'Cards'),
          ],
        ).toTemplateMap(),
        {
          'component': 'FxSegmentedButton',
          'xojo_desktop_class': 'DesktopSegmentedButton',
          'selectedValue': 'cards',
          'optionCount': 2,
          'enabled': true,
        },
      );
    });
  });

  group('FxDisclosureTriangle', () {
    testWidgets('renders collapsed and calls callback when opened', (
      tester,
    ) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDisclosureTriangle(
              expanded: false,
              title: 'Advanced',
              onChanged: (value) => changedValue = value,
              child: const Text('Hidden settings'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_right), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Hidden settings'), findsNothing);

      await tester.tap(find.text('Advanced'));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('renders expanded and calls callback when closed', (
      tester,
    ) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDisclosureTriangle(
              expanded: true,
              title: 'Details',
              onChanged: (value) => changedValue = value,
              child: const Text('Visible settings'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsNothing);
      expect(find.text('Visible settings'), findsOneWidget);

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(changedValue, isFalse);
    });

    testWidgets('respects disabled state', (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDisclosureTriangle(
              expanded: false,
              title: 'Disabled',
              enabled: false,
              onChanged: (value) => changedValue = value,
              child: const Text('Disabled content'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(changedValue, isNull);
      expect(find.text('Disabled content'), findsNothing);
    });

    test('exposes DesktopDisclosureTriangle template metadata', () {
      expect(
        const FxDisclosureTriangle(
          expanded: true,
          title: 'Advanced',
          child: Text('Settings'),
        ).toTemplateMap(),
        {
          'component': 'FxDisclosureTriangle',
          'xojo_desktop_class': 'DesktopDisclosureTriangle',
          'expanded': true,
          'enabled': true,
        },
      );
    });
  });
}
